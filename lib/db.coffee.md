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
            gt: "users:#{email}:"
          .on 'data', (data) ->
            [_, email, key] = data.key.split ':'
            user.email ?= email
            user[key] ?= data.value if user.email is email
            #console.log "User: " + user.email + " key: " + key + " value: " + user[key]
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
        del: (username, callback) ->
          # TODO

    module.exports = database
