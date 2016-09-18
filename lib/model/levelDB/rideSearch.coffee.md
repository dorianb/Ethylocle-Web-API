# Ride search

    level = require 'level'
    stream = require 'stream'
    moment = require 'moment'
    geolib = require 'geolib'
    lexi = require 'lexinum'
    database = require './down'

    rideSearchSorting = (db, userId, callback) ->
        rides = []
        ridesearchClient = level db
        ridesearchClient.createReadStream
          gte: "ridesearch:#{userId}:"
          lte: "ridesearch:#{userId}:\xff"
          limit: 5
        .on 'data', (data) ->
          [_, userId, distance, rideId, key] = data.key.split ':'
          rides.push rideId
        .on 'error', (err) ->
          callback err
        .on 'end', ->
          ridesearchClient.close (err) ->
            callback err if err
            callback null, rides

    rideSearch = (db, userId, criteria, callback) ->
      ride = {}
      limit = moment()
      limit = moment(criteria.dateTime, "DD-MM-YYYY H:mm") if moment(criteria.dateTime, "DD-MM-YYYY H:mm").isAfter limit
      if typeof db is 'string'
        ridesearchClient = database db + "/ridesearch"
        rideClient = level db + "/ride"
        rideClient.createReadStream
          gte: "rides:"
          lte: "rides:\xff"
        .on 'data', (data) ->
          [_, id, key] = data.key.split ':'
          if ride.id
            unless ride.id is id
              if moment(ride.dateTime, "DD-MM-YYYY H:mm").isAfter(limit) and criteria.numberOfPeople <= 4 - +ride.numberOfPassenger
                distanceStart = geolib.getDistance {latitude: criteria.latStart, longitude: criteria.lonStart}, {latitude: ride.latStart, longitude: ride.lonStart}
                distanceEnd = geolib.getDistance {latitude: criteria.latEnd, longitude: criteria.lonEnd}, {latitude: ride.latEnd, longitude: ride.lonEnd}
                ridesearchClient.ridesearch.set userId, lexi(distanceStart + distanceEnd), ride.id, (err) ->
                  callback err if err
          ride.id = id
          ride[key] = data.value
        .on 'error', (err) ->
          callback err
        .on 'end', ->
          rideClient.close (err) ->
            callback err if err
            date = moment ride.dateTime, "DD-MM-YYYY H:mm"
            if date > limit and criteria.numberOfPeople <= 4 - +ride.numberOfPassenger
              distanceStart = geolib.getDistance {latitude: criteria.latStart, longitude: criteria.lonStart}, {latitude: ride.latStart, longitude: ride.lonStart}
              distanceEnd = geolib.getDistance {latitude: criteria.latEnd, longitude: criteria.lonEnd}, {latitude: ride.latEnd, longitude: ride.lonEnd}
              ridesearchClient.ridesearch.set userId, lexi(distanceStart + distanceEnd), ride.id, (err) ->
                callback err if err
                ridesearchClient.close (err) ->
                  callback err if err
                  rideSearchSorting db + "/ridesearch", userId, (err, rides) ->
                    callback err if err
                    callback null, rides
            else
              ridesearchClient.close (err) ->
                callback err if err
                rideSearchSorting db + "/ridesearch", userId, (err, rides) ->
                  callback err if err
                  callback null, rides

    module.exports = rideSearch
