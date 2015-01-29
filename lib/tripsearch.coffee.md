# Trip search

    level = require 'level'
    stream = require 'stream'
    moment = require 'moment'
    geolib = require 'geolib'
    lexi = require 'lexinum'
    database = require '../lib/db'

    tripSearch = (db="#{__dirname}../db", userId, criteria, callback) ->
      trip = {}
      now = new moment()
      limit = now.add 20, 'm'
      date = moment criteria.dateTime, "DD-MM-YYYY hh:mm"
      limit = date if date > limit
      if typeof db is 'string'
        tripsearchClient = database db + "/tripsearch"
        tripClient = level db + "/trip"
        tripClient.createReadStream
          gte: "trips:"
          lte: "trips:\xff"
        .on 'data', (data) ->
          [_, id, key] = data.key.split ':'
          #console.log "Trip: " + id + " data: " + data.value
          if trip.id
            unless trip.id is id
              date = moment trip.dateTime, "DD-MM-YYYY hh:mm"
              if date.toDate() > limit.toDate() and criteria.numberOfPeople <= 4-trip.numberOfPeople
                distanceStart = geolib.getDistance {latitude: criteria.latStart, longitude: criteria.lonStart}, {latitude: trip.latStart, longitude: trip.lonStart}
                distanceEnd = geolib.getDistance {latitude: criteria.latEnd, longitude: criteria.lonEnd}, {latitude: trip.latEnd, longitude: trip.lonEnd}
                tripsearchClient.tripsearch.set userId, lexi(distanceStart + distanceEnd), trip.id, (err) ->
                  callback err, null if err
                  #console.log "Insert in tripsearch"
          trip.id = id
          trip[key] = data.value
        .on 'error', (err) ->
          callback err, null
        .on 'end', ->
          tripClient.close()
          date = moment trip.dateTime, "DD-MM-YYYY hh:mm"
          if date.toDate() > limit.toDate() and criteria.numberOfPeople <= 4-trip.numberOfPeople
            distanceStart = geolib.getDistance {latitude: criteria.latStart, longitude: criteria.lonStart}, {latitude: trip.latStart, longitude: trip.lonStart}
            distanceEnd = geolib.getDistance {latitude: criteria.latEnd, longitude: criteria.lonEnd}, {latitude: trip.latEnd, longitude: trip.lonEnd}
            tripsearchClient.tripsearch.set userId, lexi(distanceStart + distanceEnd), trip.id, (err) ->
              #console.log "Insert in tripsearch"
              callback err, null if err
              tripsearchClient.close()
              trips = []
              tripsearchClient = level db + "/tripsearch"
              tripsearchClient.createReadStream
                gte: "tripsearch:#{userId}:"
                lte: "tripsearch:#{userId}:\xff"
                limit: 10
              .on 'data', (data) ->
                [_, userId, distance, tripId, key] = data.key.split ':'
                trips.push tripId
                #console.log "User: " + userId + " trip: " + tripId + " distance: " + distance
              .on 'error', (err) ->
                callback err, null
              .on 'end', ->
                tripsearchClient.close()
                callback null, trips

    module.exports = tripSearch
