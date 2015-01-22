# Database with level up

    level = require 'level'

    database = (db="#{__dirname}../db") ->
      db = level db if typeof db is 'string'
      close: (callback) ->
        db.close callback
      users:
        get: (email, callback) ->
          user = {}
          db.createReadStream
            gte: "users:#{email}:"
            lte: "users:#{email}:\xff"
          .on 'data', (data) ->
            [_, email, key] = data.key.split ':'
            user.email = email
            user[key] = data.value
          .on 'error', (err) ->
            callback err
          .on 'end', ->
            callback null, user
        set: (email, user, callback) ->
          ops = for k, v of user
            continue if k is 'email'
            type: 'put'
            key: "users:#{email}:#{k}"
            value: v
          db.batch ops, (err) ->
            callback err
        del: (email, user, callback) ->
          ops = for k, v of user
            continue if k is 'email'
            type: 'del'
            key: "users:#{email}:#{k}"
          db.batch ops, (err) ->
            callback err
      trips:
        get: (owner, callback) ->
          trip = {}
          db.createReadStream
            gte: "trips:#{owner}:"
            lte: "trips:#{owner}:\xff"
          .on 'data', (data) ->
            [_, owner, key] = data.key.split ':'
            trip.owner = owner
            trip[key] = data.value
          .on 'error', (err) ->
            callback err
          .on 'end', ->
            callback null, trip
        set: (owner, trip, callback) ->
          ops = for k, v of trip
            continue if k is 'owner'
            type: 'put'
            key: "trips:#{owner}:#{k}"
            value: v
          db.batch ops, (err) ->
            callback err
        del: (owner, trip, callback) ->
          ops = for k, v of trip
            continue if k is 'owner'
            type: 'del'
            key: "trips:#{owner}:#{k}"
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
