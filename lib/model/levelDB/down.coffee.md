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
      rides:
        getMaxId: (callback) ->
          maxId = '-1'
          db.createReadStream
            gte: "rides:"
            lte: "rides:\xff"
          .on 'data', (data) ->
            [_, id, key] = data.key.split ':'
            maxId = id if +id > +maxId
          .on 'error', (err) ->
            callback err, null
          .on 'end', ->
            callback null, maxId
        get: (id, callback) ->
          ride = {}
          db.createReadStream
            gte: "rides:#{id}:"
            lte: "rides:#{id}:\xff"
          .on 'data', (data) ->
            [_, id, key] = data.key.split ':'
            ride.id = id
            ride[key] = data.value
          .on 'error', (err) ->
            callback err, null
          .on 'end', ->
            callback null, ride
        set: (id, ride, callback) ->
          ops = for k, v of ride
            continue if k is 'id'
            type: 'put'
            key: "rides:#{id}:#{k}"
            value: v
          db.batch ops, (err) ->
            callback err
        del: (id, ride, callback) ->
          ops = for k, v of ride
            continue if k is 'id'
            type: 'del'
            key: "rides:#{id}:#{k}"
          db.batch ops, (err) ->
            callback err
        getByPassengerRideInProgress: (userId, now, callback) ->
          ride = {}
          db.createReadStream
            gte: "ridesPassengerIndex:#{userId}:"
            lte: "ridesPassengerIndex:#{userId}:\xff"
          .on 'data', (data) ->
            [_, userId, rideId, key] = data.key.split ':'
            if moment(data.value, "DD-MM-YYYY H:mm") > now
              ride.id = rideId
              ride[key] = data.value
          .on 'error', (err) ->
            callback err, null
          .on 'end', ->
            callback null, ride
        getByPassenger: (userId, callback) ->
          rides = []
          db.createReadStream
            gte: "ridesPassengerIndex:#{userId}:"
            lte: "ridesPassengerIndex:#{userId}:\xff"
          .on 'data', (data) ->
            [_, userId, rideId, key] = data.key.split ':'
            ride = {}
            ride.id = rideId
            ride[key] = data.value
            rides.push ride
          .on 'error', (err) ->
            callback err, null
          .on 'end', ->
            callback null, rides
        setByPassenger: (userId, ride, callback) ->
          ops = for k, v of ride
              continue unless k is 'dateTime'
              type: 'put'
              key: "ridesPassengerIndex:#{userId}:#{ride.id}:#{k}"
              value: v
          db.batch ops, (err) ->
            callback err
        delByPassenger: (userId, ride, callback) ->
          ops = for k, v of ride
            continue unless k is 'dateTime'
            type: 'del'
            key: "ridesPassengerIndex:#{userId}:#{ride.id}:#{k}"
          db.batch ops, (err) ->
            callback err
      ridesearch:
        get: (userId, distance, rideId, callback) ->
          result = {}
          db.createReadStream
            gte: "ridesearch:#{userId}:#{distance}:#{rideId}"
            lte: "ridesearch:#{userId}:#{distance}:#{rideId}"
          .on 'data', (data) ->
            [_, userId, distance, rideId, key] = data.key.split ':'
            result.userId = userId
            result.distance = distance
            result.rideId = rideId
          .on 'error', (err) ->
            callback err, null
          .on 'end', ->
            callback null, result
        set: (userId, distance, rideId, callback) ->
          op = [
            type: 'put'
            key: "ridesearch:#{userId}:#{distance}:#{rideId}"
            value: rideId
          ]
          db.batch op, (err) ->
            callback err
        del: (userId, distance, rideId, callback) ->
          op = [
            type: 'del'
            key: "ridesearch:#{userId}:#{distance}:#{rideId}"
          ]
          db.batch op, (err) ->
            callback err
        getByUser: (userId, callback) ->
          result = []
          db.createReadStream
            gte: "ridesearch:#{userId}:"
            lte: "ridesearch:#{userId}:\xff"
          .on 'data', (data) ->
            row = {}
            [_, userId, distance, rideId, key] = data.key.split ':'
            row.userId = userId
            row.distance = distance
            row.rideId = rideId
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
