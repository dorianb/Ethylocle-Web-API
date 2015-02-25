# Down

    level = require 'level'
    moment = require 'moment'

    Down = (db) ->
      db = level db if typeof db is 'string'
      close: (callback) ->
        db.close callback
      users:
        getMaxId: (callback) ->
          maxId = '-1'
          db.createReadStream
            gte: "users:"
            lte: "users:\xff"
          .on 'data', (data) ->
            [_, id, key] = data.key.split ':'
            maxId = id if +id > +maxId
          .on 'error', (err) ->
            callback err, null
          .on 'end', ->
            callback null, maxId
        get: (id, callback) ->
          user = {}
          db.createReadStream
            gte: "users:#{id}:"
            lte: "users:#{id}:\xff"
          .on 'data', (data) ->
            [_, id, key] = data.key.split ':'
            user.id = id
            user[key] = data.value
          .on 'error', (err) ->
            callback err, null
          .on 'end', ->
            callback null, user
        set: (id, user, callback) ->
          ops = for k, v of user
            continue if k is 'id'
            type: 'put'
            key: "users:#{id}:#{k}"
            value: v
          db.batch ops, (err) ->
            callback err
        del: (id, user, callback) ->
          ops = for k, v of user
            continue if k is 'id'
            type: 'del'
            key: "users:#{id}:#{k}"
          db.batch ops, (err) ->
            callback err
        getByEmail: (email, callback) ->
          user = {}
          db.createReadStream
            gte: "usersEmailIndex:#{email}:"
            lte: "usersEmailIndex:#{email}:\xff"
          .on 'data', (data) ->
            [_, email, key] = data.key.split ':'
            user.email = email
            user[key] = data.value
          .on 'error', (err) ->
            callback err, null
          .on 'end', ->
            callback null, user
        setByEmail: (email, user, callback) ->
          ops = for k, v of user
              continue unless k is 'id'
              type: 'put'
              key: "usersEmailIndex:#{email}:#{k}"
              value: v
          db.batch ops, (err) ->
            callback err
        delByEmail: (email, user, callback) ->
          ops = for k, v of user
            continue unless k is 'id'
            type: 'del'
            key: "usersEmailIndex:#{email}:#{k}"
          db.batch ops, (err) ->
            callback err
      trips:
        getMaxId: (callback) ->
          maxId = '-1'
          db.createReadStream
            gte: "trips:"
            lte: "trips:\xff"
          .on 'data', (data) ->
            [_, id, key] = data.key.split ':'
            maxId = id if +id > +maxId
          .on 'error', (err) ->
            callback err, null
          .on 'end', ->
            callback null, maxId
        get: (id, callback) ->
          trip = {}
          db.createReadStream
            gte: "trips:#{id}:"
            lte: "trips:#{id}:\xff"
          .on 'data', (data) ->
            [_, id, key] = data.key.split ':'
            trip.id = id
            trip[key] = data.value
          .on 'error', (err) ->
            callback err, null
          .on 'end', ->
            callback null, trip
        set: (id, trip, callback) ->
          ops = for k, v of trip
            continue if k is 'id'
            type: 'put'
            key: "trips:#{id}:#{k}"
            value: v
          db.batch ops, (err) ->
            callback err
        del: (id, trip, callback) ->
          ops = for k, v of trip
            continue if k is 'id'
            type: 'del'
            key: "trips:#{id}:#{k}"
          db.batch ops, (err) ->
            callback err
        getByPassengerTripInProgress: (userId, now, callback) ->
          trip = {}
          db.createReadStream
            gte: "tripsPassengerIndex:#{userId}:"
            lte: "tripsPassengerIndex:#{userId}:\xff"
          .on 'data', (data) ->
            [_, userId, tripId, key] = data.key.split ':'
            if moment(data.value, "DD-MM-YYYY H:mm") > now
              trip.id = tripId
              trip[key] = data.value
          .on 'error', (err) ->
            callback err, null
          .on 'end', ->
            callback null, trip
        getByPassenger: (userId, callback) ->
          trips = []
          db.createReadStream
            gte: "tripsPassengerIndex:#{userId}:"
            lte: "tripsPassengerIndex:#{userId}:\xff"
          .on 'data', (data) ->
            [_, userId, tripId, key] = data.key.split ':'
            trip = {}
            trip.id = tripId
            trip[key] = data.value
            trips.push trip
          .on 'error', (err) ->
            callback err, null
          .on 'end', ->
            callback null, trips
        setByPassenger: (userId, trip, callback) ->
          ops = for k, v of trip
              continue unless k is 'dateTime'
              type: 'put'
              key: "tripsPassengerIndex:#{userId}:#{trip.id}:#{k}"
              value: v
          db.batch ops, (err) ->
            callback err
        delByPassenger: (userId, trip, callback) ->
          ops = for k, v of trip
            continue unless k is 'dateTime'
            type: 'del'
            key: "tripsPassengerIndex:#{userId}:#{trip.id}:#{k}"
          db.batch ops, (err) ->
            callback err
      tripsearch:
        get: (userId, distance, tripId, callback) ->
          result = {}
          db.createReadStream
            gte: "tripsearch:#{userId}:#{distance}:#{tripId}"
            lte: "tripsearch:#{userId}:#{distance}:#{tripId}"
          .on 'data', (data) ->
            [_, userId, distance, tripId, key] = data.key.split ':'
            result.userId = userId
            result.distance = distance
            result.tripId = tripId
          .on 'error', (err) ->
            callback err, null
          .on 'end', ->
            callback null, result
        set: (userId, distance, tripId, callback) ->
          op = [
            type: 'put'
            key: "tripsearch:#{userId}:#{distance}:#{tripId}"
            value: tripId
          ]
          db.batch op, (err) ->
            callback err
        del: (userId, distance, tripId, callback) ->
          op = [
            type: 'del'
            key: "tripsearch:#{userId}:#{distance}:#{tripId}"
          ]
          db.batch op, (err) ->
            callback err
        getByUser: (userId, callback) ->
          result = []
          db.createReadStream
            gte: "tripsearch:#{userId}:"
            lte: "tripsearch:#{userId}:\xff"
          .on 'data', (data) ->
            row = {}
            [_, userId, distance, tripId, key] = data.key.split ':'
            row.userId = userId
            row.distance = distance
            row.tripId = tripId
            result.push row
          .on 'error', (err) ->
            callback err, null
          .on 'end', ->
            callback null, result
      stops:
        get: (id, callback) ->
          stop = {}
          db.createReadStream
            gte: "stops:#{id}:"
            lte: "stops:#{id}:\xff"
          .on 'data', (data) ->
            [_, id, key] = data.key.split ':'
            stop.id = id
            stop[key] = data.value
          .on 'error', (err) ->
            callback err, null
          .on 'end', ->
            callback null, stop
        set: (id, stop, callback) ->
          ops = for k, v of stop
            continue if k is 'stop_id'
            v = 'null' unless v
            type: 'put'
            key: "stops:#{id}:#{k}"
            value: v
          db.batch ops, (err) ->
            callback err
        getByLineType: (lineType, callback) ->
          stops = []
          db.createReadStream
            gte: "stopsLineTypeIndex:#{lineType}:"
            lte: "stopsLineTypeIndex:#{lineType}:\xff"
          .on 'data', (data) ->
            [_, lineType, id] = data.key.split ':'
            stop = {}
            stop.lineType = lineType
            stop.id = id
            stops[stops.length] = stop
          .on 'error', (err) ->
            callback err, null
          .on 'end', ->
            callback null, stops
        setByLineType: (lineType, id, callback) ->
          op = [
            type: 'put'
            key: "stopsLineTypeIndex:#{lineType}:#{id}"
            value: id
          ]
          db.batch op, (err) ->
            callback err

    module.exports = Down
