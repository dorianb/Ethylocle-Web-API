# Show

    level = require 'level'
    stream = require 'stream'

    show = (path, type, callback) ->
      source = path + "/" + type
      if type is 'user'
        nbRows = 0
        user = {}
        source = level source if typeof source is 'string'
        source.createReadStream
          gte: "users:"
          lte: "users:\xff"
        .on 'data', (data) ->
          [_, id, key] = data.key.split ':'
          if user.id
            unless user.id is id
              counter = 1
              length = Object.keys(user).length
              chunk = ""
              for k, v of user
                chunk += k + ":" + v
                chunk += ' ' unless length is counter
                delete user[k]
                counter++
              nbRows++
              console.log chunk
          user.id = id
          user[key] = data.value
        .on 'error', (err) ->
          callback err
        .on 'end', ->
          source.close (error) ->
            callback error if error
            if user.id
              counter = 1
              length = Object.keys(user).length
              chunk = ""
              for k, v of user
                chunk += k + ":" + v
                chunk += ' ' unless length is counter
                counter++
              console.log chunk if chunk
              nbRows++
            callback null, type + ": " + nbRows
      else if type is 'ride'
        nbRows = 0
        ride = {}
        source = level source if typeof source is 'string'
        source.createReadStream
          gte: "rides:"
          lte: "rides:\xff"
        .on 'data', (data) ->
          [_, id, key] = data.key.split ':'
          if ride.id
            unless ride.id is id
              counter = 1
              length = Object.keys(ride).length
              chunk = ""
              for k, v of ride
                chunk += k + ":" + v
                chunk += ' ' unless length is counter
                delete ride[k]
                counter++
              nbRows++
              console.log chunk
          ride.id = id
          ride[key] = data.value
        .on 'error', (err) ->
          callback err
        .on 'end', ->
          source.close (error) ->
            callback error if error
            if ride.id
              counter = 1
              length = Object.keys(ride).length
              chunk = ""
              for k, v of ride
                chunk += k + ":" + v
                chunk += ' ' unless length is counter
                counter++
              console.log chunk if chunk
              nbRows++
            callback null, type + ": " + nbRows
      else if type is 'ridesearch'
        callback null, "This type is not implemented yet"
      else if type is 'stop'
        callback null, "This type is not implemented yet"
      else
        callback null, "This type is not supported"

    module.exports = show
