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
      stops:
        get: (id, callback) ->
          stop = {}
          db.createReadStream
            gte: "stops:#{id}:"
            lte: "stops:#{id}:\xff"
          .on 'data', (data) ->
            [_, id, key] = data.key.split ':'
            stop.id = id
            user[key] = data.value
          .on 'error', (err) ->
            callback err
          .on 'end', ->
            callback null, stop
        set: (id, stop, callback) ->
          ops = for k, v of stop
            continue if k is 'id'
            type: 'put'
            key: "stops:#{id}:#{k}"
            value: v
          db.batch ops, (err) ->
            callback err
        getByLineType: (lineType, callback) ->
          stops = []
          db.createReadStream
            gte: "stopsByLineType:#{lineType}:"
            lte: "stopsByLineType:#{lineType}:\xff"
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
          op =
            type: 'put'
            key: "stopsByLineType:#{lineType}:#{id}"
          db.batch op, (err) ->
            callback err

    module.exports = database
