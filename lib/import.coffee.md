# Import

    stream = require 'stream'
    util = require 'util'
    parse = require 'csv-parse'

    importStream = (destination, format = 'csv', type, options) ->
      return new importStream destination, format, type, options unless this instanceof importStream
      this.destination = destination
      this.format = format
      this.type = type
      stream.Writable.call this, options

    util.inherits importStream, stream.Writable
    importStream.prototype._write = (chunk, encoding, done) ->
      that = this
      console.log "Writing"
      if this.format is 'csv'
        if this.type is 'users'
          parse chunk.toString(), {delimiter: ';'}, (err, users) ->
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
                          storeCSVUser i+1
              else
                console.log "done"
                done()
            storeCSVUser 0
        else if this.type is 'stops'
          parse chunk.toString(), {delimiter: ';'}, (err, stops) ->
            storeCSVStop = (i) ->
              if i < stops.length
                data = {}
                for k, v of stops[i]
                  if v
                    data[k] = v
                  else
                    data[k] = 'null'
                that.destination.stops.set data[0],
                  name: data[1]
                  desc: data[2]
                  lat: data[3]
                  lon: data[4]
                  lineType: data[11]
                  lineName: data[12]
                , (err) ->
                    #console.log "Error setting data: " + err.message if err
                    that.destination.stops.setByLineType data[11], data[0], (err) ->
                      #console.log "Error indexing by line type: " + err.message if err
                      #console.log i if i%10 is 0
                      storeCSVStop i+1
              else
                done()
            storeCSVStop 0
      if this.format is 'json'
        if this.type is 'users'
          users = JSON.parse chunk.toString()
          storeJSONUser = (i) ->
            if i < users.length
              that.destination.users.getMaxId (err, maxId) ->
                console.log err.message if err
                that.destination.users.set ++maxId,
                  email: v.email
                  picture: v.picture
                  lastname: v.lastname
                  firstname: v.firstname
                  birthDate: v.birthDate
                  gender: v.gender
                  weight: v.weight
                  address: v.address
                  zipCode: v.zipCode
                  city: v.city
                  country: v.country
                  phone: v.phone
                  password: v.password
                  latitude: v.latitude
                  longitude: v.longitude
                  lastKnownPositionDate: v.lastKnownPositionDate
                  bac: v.bac
                  lastBacKnownDate: v.lastBacKnownDate
                , (err) ->
                    console.log err.message if err
                    that.destination.users.setByEmail v.email,
                      id: maxId
                    , (err) ->
                        console.log err.message if err
                        storeJSONUser i+1
            else
              done()
          storeJSONUser 0

    importStream.prototype.end = () ->
      console.log 'ImportStream ended'

    module.exports = importStream
