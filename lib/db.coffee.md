# Database with level up

    level = require 'level'

    database = (db="#{__dirname}../db") ->
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
            maxId = id if id > maxId
          .on 'error', (err) ->
            callback err
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
            callback err
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
            callback err
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
            maxId = id if id > maxId
          .on 'error', (err) ->
            callback err
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
            callback err
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
            callback err
          .on 'end', ->
            callback null, stop
        set: (id, stop, callback) ->
          ops = for k, v of stop
            continue if k is 'id'
            v = 'null' unless v
            type: 'put'
            key: "stops:#{id}:#{k}"
            value: v
          db.batch ops, (err) ->
            callback err
        getByLineType: (lineType, callback) ->
          stops = []
          db.createReadStream
            gte: "stops:#{lineType}:"
            lte: "stops:#{lineType}:\xff"
          .on 'data', (data) ->
            [_, lineType, id] = data.key.split ':'
            stop = {}
            stop.lineType = lineType
            stop.id = id
            stops[stops.length] = stop
          .on 'error', (err) ->
            callback err
          .on 'end', ->
            callback null, stops
        setByLineType: (lineType, id, callback) ->
          op = [
            type: 'put'
            key: "stops:#{lineType}:#{id}"
            value: id
          ]
          db.batch op, (err) ->
            callback err

    module.exports = database
