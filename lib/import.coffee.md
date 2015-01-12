# Import

    stream = require 'stream'
    util = require 'util'
    parse = require 'csv-parse'

    importStream = (destination, format = format: 'csv', options) ->
      return new importStream destination, format, options unless this instanceof importStream
      this.destination = destination
      this.format = format.format
      stream.Writable.call this, options

    util.inherits importStream, stream.Writable
    importStream.prototype._write = (chunk, encoding, done) ->
      that = this
      if this.format is 'csv'
        parse chunk.toString(), (err, users) ->
          for k, v of users
            do (v) ->
              that.destination.users.set v[0],
                lastname: v[1]
                firstname: v[2]
                email: v[3]
                password: v[4]
              , (err) ->
                that.destination.users.setByEmail v[3],
                  username: v[0]
                , (err) ->
                  console.log err if err
          console.log "Parsing finished"
      if this.format is 'json'
        users = JSON.parse chunk.toString()
        for k, v of users
          do (v) ->
            that.destination.users.set v.username,
              lastname: v.lastname
              firstname: v.firstname
              email: v.email
              password: v.password
            , (err) ->
              that.destination.users.setByEmail v.email,
                username: v.username
              , (err) ->
                console.log err if err
      console.log "Done"
      done()

    importStream.prototype.end = () ->
      console.log 'ImportStream ended'

    module.exports = importStream
