# Database with level up

    level = require 'level'

    database = (db="#{__dirname}../db") ->
      db = level db if typeof db is 'string'
      close: (callback) ->
        db.close callback
      users:
        getAll: (callback) ->
          usrs = {}
          db.createReadStream
            gt: "users:"
          .on 'data', (data) ->
            [_, username, key] = data.key.split ':'
            user = {}
            user.username = username
            user[key] = data.value
            usrs = usrs + user
            console.log usrs
            console.log user
            console.log "Username: " + user.username + " key: " + key + " value: " + user[key]
          .on 'error', (err) ->
            callback err
          .on 'end', ->
            callback null, usrs
        get: (username, callback) ->
          user = {}
          db.createReadStream
            gt: "users:#{username}:"
          .on 'data', (data) ->
            [_, username, key] = data.key.split ':'
            user.username ?= username
            user[key] ?= data.value if user.username is username
            #console.log "Username: " + user.username + " key: " + key + " value: " + user[key]
          .on 'error', (err) ->
            callback err
          .on 'end', ->
            callback null, user
        set: (username, user, callback) ->
          ops = for k, v of user
            continue if k is 'username'
            type: 'put'
            key: "users:#{username}:#{k}"
            value: v
          db.batch ops, (err) ->
            callback err
        getByEmail: (email, callback) ->
          user = {}
          db.createReadStream
            gt: "users_by_email:#{email}:"
          .on 'data', (data) ->
            [_, email, key] = data.key.split ':'
            user.email ?= email
            user[key] ?= data.value if user.email is email
          .on 'error', (err) ->
            callback err
          .on 'end', ->
            callback null, user
        setByEmail: (email, user, callback) ->
          ops = for k, v of user
            continue if k is 'email'
            type: 'put'
            key: "users_by_email:#{email}:#{k}"
            value: v
          db.batch ops, (err) ->
            callback err
        del: (username, callback) ->
          # TODO

    module.exports = database
