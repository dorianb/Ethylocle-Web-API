# Show

    level = require 'level'
    stream = require 'stream'

    show = (source, type, callback) ->
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
          callback err, null
        .on 'end', ->
          source.close()
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
          callback null, nbRows
      else if type is 'trip'
        nbRows = 0
        trip = {}
        source = level source if typeof source is 'string'
        source.createReadStream
          gte: "trips:"
          lte: "trips:\xff"
        .on 'data', (data) ->
          [_, id, key] = data.key.split ':'
          if trip.id
            unless trip.id is id
              counter = 1
              length = Object.keys(trip).length
              chunk = ""
              for k, v of trip
                chunk += k + ":" + v
                chunk += ' ' unless length is counter
                delete trip[k]
                counter++
              nbRows++
              console.log chunk
          trip.id = id
          trip[key] = data.value
        .on 'error', (err) ->
          callback err, null
        .on 'end', ->
          source.close()
          if trip.id
            counter = 1
            length = Object.keys(trip).length
            chunk = ""
            for k, v of trip
              chunk += k + ":" + v
              chunk += ' ' unless length is counter
              counter++
            console.log chunk if chunk
            nbRows++
          callback null, nbRows
      else if type is 'tripsearch'
        callback null, 0
      else if type is 'stop'
        callback null, 0
      else
        callback message: "This type of data is not supported", null

    module.exports = show
