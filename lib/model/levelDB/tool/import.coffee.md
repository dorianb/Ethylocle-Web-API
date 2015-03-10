# Import

    stream = require 'stream'
    util = require 'util'
    parse = require 'csv-parse'

    ImportStream = (destination, format = 'csv', type, options) ->
      return new ImportStream destination, format, type, options unless this instanceof ImportStream
      this.destination = destination
      this.format = format
      this.type = type
      stream.Writable.call this, options
      this.iterator = 0

    util.inherits ImportStream, stream.Writable

    ImportStream.prototype._write = (chunk, encoding, done) ->
      that = this
      if this.format is 'csv'
        if this.type is 'user'
          parse chunk, delimiter: ';', (err, users) ->
            storeCSVUser = (i) ->
              if i < users.length
                that.destination.users.getMaxId (err, maxId) ->
                  console.log err.message if err
                  that.destination.users.set ++maxId,
                    email: users[i][0]
                    picture: users[i][1]
                    lastname: users[i][2]
                    firstname: users[i][3]
                    birthDate: users[i][4]
                    gender: users[i][5]
                    weight: users[i][6]
                    address: users[i][7]
                    zipCode: users[i][8]
                    city: users[i][9]
                    country: users[i][10]
                    phone: users[i][11]
                    password: users[i][12]
                    latitude: users[i][13]
                    longitude: users[i][14]
                    lastKnownPositionDate: users[i][15]
                    bac: users[i][16]
                    lastBacKnownDate: users[i][17]
                  , (err) ->
                      console.log err.message if err
                      that.destination.users.setByEmail users[i][0],
                        id: maxId
                      , (err) ->
                          console.log err.message if err
                          that.iterator++
                          storeCSVUser i+1
              else
                #console.log "Done " + that.iterator
                done()
            storeCSVUser 0
        else if this.type is 'stop'
          parse chunk, delimiter: ';', (err, stops) ->
            storeCSVStop = (i) ->
              if i is 0
                if that.data
                  counter = 1
                  length = Object.keys(stops[i]).length
                  for k, v of stops[i]
                    that.data += v
                    that.data += ';' unless length is counter
                    that.data += '\n' if length is counter
                    counter++
                  #console.log that.iterator + " First element: " + that.data
                  parse that.data, delimiter: ';', (err, stops) ->
                    that.data = ""
                    data = {}
                    for k, v of stops[0]
                      if v
                        data[that.fields[k]] = v
                      else
                        data[that.fields[k]] = 'null'
                    that.destination.stops.set data.stop_id, data, (err) ->
                      console.log "Error setting data: " + err.message if err
                      that.destination.stops.setByLineType data.line_type, data.stop_id, (err) ->
                        console.log "Error indexing by line type: " + err.message if err
                        that.iterator++
                        storeCSVStop i+1
                else unless that.fields
                  that.fields = stops[i]
                  storeCSVStop i+1
              else if i is stops.length-1
                counter = 1
                length = Object.keys(stops[i]).length
                that.data = ""
                for k, v of stops[i]
                  that.data += v
                  that.data += ';' unless length is counter
                  counter++
                #console.log that.iterator + " Last element: " + that.data
                storeCSVStop i+1
              else if i < stops.length-1
                data = {}
                for k, v of stops[i]
                  if v
                    data[that.fields[k]] = v
                  else
                    data[that.fields[k]] = 'null'
                that.destination.stops.set data.stop_id, data, (err) ->
                  console.log "Error setting data: " + err.message if err
                  that.destination.stops.setByLineType data.line_type, data.stop_id, (err) ->
                    console.log "Error indexing by line type: " + err.message if err
                    that.iterator++
                    storeCSVStop i+1
              else
                #console.log "Done " + that.iterator
                done()
            storeCSVStop 0
      if this.format is 'json'
        if this.type is 'user'
          users = JSON.parse chunk
          storeJSONUser = (i) ->
            if i < users.length
              that.destination.users.getMaxId (err, maxId) ->
                console.log err.message if err
                that.destination.users.set ++maxId, users[i], (err) ->
                  console.log err.message if err
                  that.destination.users.setByEmail users[i].email, id: maxId, (err) ->
                    console.log err.message if err
                    that.iterator++
                    storeJSONUser i+1
            else
              #console.log "Done " + that.iterator
              done()
          storeJSONUser 0

    module.exports = ImportStream
