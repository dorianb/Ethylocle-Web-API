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
      if this.format is 'csv'
        if this.type is 'users'
          parse chunk.toString(), (err, users) ->
            for k, v of users
              do (v) ->
                that.destination.users.set v[0],
                  picture: v[1]
                  lastname: v[2]
                  firstname: v[3]
                  birthDate: v[4]
                  gender: v[5]
                  weight: v[6]
                  address: v[7]
                  zipCode: v[8]
                  city: v[9]
                  country: v[10]
                  phone: v[11]
                  vehicul: v[12]
                  password: v[13]
                  latitude: v[14]
                  longitude: v[15]
                  lastKnownPositionDate: v[16]
                  bac: v[17]
                  lastBacKnownDate: v[18]
                , (err) ->
                    console.log err.message if err
        else if this.type is 'stops'
          parse chunk.toString(), {delimiter: ';'}, (err, stops) ->
            for k, v of stops
              do (v) ->
                data = {}
                for k, d of v
                  if d
                    data[k] = d
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
                  console.log err.message if err
                  that.destination.stops.setByLineType data[11], data[0], (err) ->
                    console.log err.message if err
      if this.format is 'json'
        if this.type is 'users'
          users = JSON.parse chunk.toString()
          for k, v of users
            do (v) ->
              that.destination.users.set v.email,
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
                vehicul: v.vehicul
                password: v.password
                latitude: v.latitude
                longitude: v.longitude
                lastKnownPositionDate: v.lastKnownPositionDate
                bac: v.bac
                lastBacKnownDate: v.lastBacKnownDate
              , (err) ->
                  console.log err.message if err
      done()

    importStream.prototype.end = () ->
      #console.log 'ImportStream ended'

    module.exports = importStream
