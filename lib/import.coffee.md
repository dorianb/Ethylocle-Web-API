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
                  console.log err if err
          console.log "Parsing finished"
      if this.format is 'json'
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
                console.log err if err
      console.log "Done"
      done()

    importStream.prototype.end = () ->
      console.log 'ImportStream ended'

    module.exports = importStream
