# Trip search

    level = require 'level'
    stream = require 'stream'
    moment = require 'moment'
    geolib = require 'geolib'
    lexi = require 'lexinum'
    database = require './down'

    tripSearchSorting = (db, userId, callback) ->
        trips = []
        tripsearchClient = level db
        tripsearchClient.createReadStream
          gte: "tripsearch:#{userId}:"
          lte: "tripsearch:#{userId}:\xff"
          limit: 5
        .on 'data', (data) ->
          [_, userId, distance, tripId, key] = data.key.split ':'
          trips.push tripId
        .on 'error', (err) ->
          callback err
        .on 'end', ->
          tripsearchClient.close (err) ->
            callback err if err
            callback null, trips

    tripSearch = (db, userId, criteria, callback) ->
      trip = {}
      limit = moment()
      limit = moment(criteria.dateTime, "DD-MM-YYYY H:mm") if moment(criteria.dateTime, "DD-MM-YYYY H:mm").isAfter limit
      if typeof db is 'string'
        tripsearchClient = database db + "/tripsearch"
        tripClient = level db + "/trip"
        tripClient.createReadStream
          gte: "trips:"
          lte: "trips:\xff"
        .on 'data', (data) ->
          [_, id, key] = data.key.split ':'
          if trip.id
            unless trip.id is id
              if moment(trip.dateTime, "DD-MM-YYYY H:mm").isAfter(limit) and criteria.numberOfPeople <= 4 - +trip.numberOfPassenger
                distanceStart = geolib.getDistance {latitude: criteria.latStart, longitude: criteria.lonStart}, {latitude: trip.latStart, longitude: trip.lonStart}
                distanceEnd = geolib.getDistance {latitude: criteria.latEnd, longitude: criteria.lonEnd}, {latitude: trip.latEnd, longitude: trip.lonEnd}
                tripsearchClient.tripsearch.set userId, lexi(distanceStart + distanceEnd), trip.id, (err) ->
                  callback err if err
          trip.id = id
          trip[key] = data.value
        .on 'error', (err) ->
          callback err
        .on 'end', ->
          tripClient.close (err) ->
            callback err if err
            date = moment trip.dateTime, "DD-MM-YYYY H:mm"
            if date > limit and criteria.numberOfPeople <= 4 - +trip.numberOfPassenger
              distanceStart = geolib.getDistance {latitude: criteria.latStart, longitude: criteria.lonStart}, {latitude: trip.latStart, longitude: trip.lonStart}
              distanceEnd = geolib.getDistance {latitude: criteria.latEnd, longitude: criteria.lonEnd}, {latitude: trip.latEnd, longitude: trip.lonEnd}
              tripsearchClient.tripsearch.set userId, lexi(distanceStart + distanceEnd), trip.id, (err) ->
                callback err if err
                tripsearchClient.close (err) ->
                  callback err if err
                  tripSearchSorting db + "/tripsearch", userId, (err, trips) ->
                    callback err if err
                    callback null, trips
            else
              tripsearchClient.close (err) ->
                callback err if err
                tripSearchSorting db + "/tripsearch", userId, (err, trips) ->
                  callback err if err
                  callback null, trips

    module.exports = tripSearch
