# Up class inheriting from Abstract class

    AbstractModel = require '../abstract'
    Down = require './down'
    RideSearch = require './rideSearch'

    show = require './tool/show'
    importStream = require './tool/import'
    exportStream = require './tool/export'

    User = require '../../entity/user'
    Ride = require '../../entity/ride'
    RideCriteria = require '../../entity/rideCriteria'

    moment = require 'moment'
    geolib = require 'geolib'
    fs = require 'fs'
    level = require 'level'

    Up = (path="#{__dirname}/../../../db") ->
      return new Up path unless this instanceof Up
      AbstractModel.apply this, [path]

    Up.prototype = Object.create AbstractModel.prototype
    Up.prototype.constructor = Up

## User methods

    Up.prototype.signIn = (usr, callback) ->
      client = Down this.path + "/user"
      client.users.getByEmail usr.email, (err, user) ->
        if err
          client.close (error) ->
            callback err
        else
          client.users.get user.id, (err, user) ->
            if err
              client.close (error) ->
                callback err
            else if user.email is usr.email and user.password is usr.password
              client.close (error) ->
                callback null, {result: true, data: null, user: user}
            else
              client.close (error) ->
                callback null, {result: false, data: "Email ou mot de passe incorrect"}

    Up.prototype.checkPassword = (usr, callback) ->
      client = Down this.path + "/user"
      client.users.get usr.id, (err, user) ->
        if err
          client.close (error) ->
            callback err
        else if user.id is usr.id and user.password is usr.password
          client.close (error) ->
            callback null, {result: true, data: null}
        else
          client.close (error) ->
            callback null, {result: false, data: null}

    Up.prototype.signUp = (usr, callback) ->
      client = Down this.path + "/user"
      client.users.getByEmail usr.email, (err, user) ->
        if err
          client.close (error) ->
            callback err
        else if user.email is usr.email
          client.close (error) ->
            callback null, {result: false, data: "L'email n'est plus disponible"}
        else
          client.users.getMaxId (err, maxId) ->
            if err
              client.close (error) ->
                callback err
            else
              usr.id = (++maxId).toString()
              client.users.set usr.id, usr.get(), (err) ->
                if err
                  client.close (error) ->
                    callback err
                else
                  client.users.setByEmail usr.email, usr.get(), (err) ->
                    if err
                      client.close (error) ->
                        callback err
                    else
                      client.close (error) ->
                        callback null, {result: true, data: null, user: usr.get()}

    Up.prototype.updateEmail = (usr, callback) ->
      client = Down this.path + "/user"
      client.users.getByEmail usr.email, (err, user) ->
        if err
          client.close (error) ->
            callback err
        else if user.email is usr.email
          client.close (error) ->
            callback null, {result: false, data: "L'email n'est plus disponible"}
        else
          client.users.get usr.id, (err, user) ->
            if err
              client.close (error) ->
                callback err
            else
              client.users.delByEmail user.email, user, (err) ->
                if err
                  client.close (error) ->
                    callback err
                else
                  client.users.set usr.id, usr.get(), (err) ->
                    if err
                      client.close (error) ->
                        callback err
                    else
                      client.users.setByEmail usr.email, usr.get(), (err) ->
                        if err
                          client.close (error) ->
                            callback err
                        else
                          client.close (error) ->
                            callback null, {result: true, data: null}

    Up.prototype.update = (usr, callback) ->
      client = Down this.path + "/user"
      client.users.set usr.id, usr.get(), (err) ->
        if err
          client.close (error) ->
            callback err
        else
          client.close (error) ->
            callback null, {result: true, data: null}

    Up.prototype.get = (usr, callback) ->
      client = Down this.path + "/user"
      client.users.get usr.id, (err, user) ->
        if err
          client.close (error) ->
            callback err
        else
          client.close (error) ->
            usr.set user
            callback null, {result: true, data: usr.getPrivate()}

    Up.prototype.getById = (usr, callback) ->
      client = Down this.path + "/user"
      client.users.get usr.id, (err, user) ->
        if err
          client.close (error) ->
            callback err
        else if user.id
          client.close (error) ->
            usr.set user
            callback null, {result: true, data: usr.getPublic()}
        else
          client.close (error) ->
            callback null, {result: false, data: "L'utilisateur n'existe pas"}

    Up.prototype.delete = (usr, callback) ->
      client = Down this.path + "/user"
      client.users.get usr.id, (err, user) ->
        if err
          client.close (error) ->
            callback err
        else
          client.users.del user.id, user, (err) ->
            if err
              client.close (error) ->
                callback err
            else
              client.users.delByEmail user.email, user, (err) ->
                if err
                  client.close (error) ->
                    callback err
                else
                  client.close () ->
                    callback null, {result: true, data: null}

## Ride methods

    Up.prototype.hasRide = (usr, callback) ->
      client = Down this.path + "/ride"
      client.rides.getByPassengerRideInProgress usr.id, moment(), (err, ride) ->
        if err
          client.close () ->
            callback err
        else if ride.id
          client.close () ->
            callback null, {result: true, data: null}
        else
          client.close () ->
            callback null, {result: false, data: "Aucun trajet en cours"}

    Up.prototype.searchRide = (usr, rideCriteria, callback) ->
      that = this
      RideSearch this.path, usr.id, rideCriteria.get(), (err, rides) ->
        client = Down that.path + "/ridesearch"
        client.ridesearch.getByUser usr.id, (err, result) ->
          if err
            client.close (error) ->
              callback err
          else
            delRideSearchByUser = (i) ->
              if i < result.length
                client.ridesearch.del result[i].userId, result[i].distance, result[i].rideId, (err) ->
                  if err
                    client.close (error) ->
                      callback err
                  else
                    delRideSearchByUser i+1
              else
                client.close (err) ->
                  callback err if err
                  client = Down that.path + "/ride"
                  data = []
                  getRideDetails = (i) ->
                    if i < rides.length
                      client.rides.get rides[i], (err, ride) ->
                        if err
                          client.close (error) ->
                            callback err
                        else
                          ride = Ride ride
                          datum = ride.getPublic()
                          datum.distanceToStart = geolib.getDistance({latitude: rideCriteria.latStart, longitude: rideCriteria.lonStart}, {latitude: ride.latStart, longitude: ride.lonStart})/1000
                          datum.distanceToEnd = geolib.getDistance({latitude: rideCriteria.latEnd, longitude: rideCriteria.lonEnd}, {latitude: ride.latEnd, longitude: ride.lonEnd})/1000
                          data.push datum
                          getRideDetails i+1
                    else
                      client.close (error) ->
                        callback null, {result: true, data: data}
                  getRideDetails 0
            delRideSearchByUser 0

    Up.prototype.joinRide = (usr, rd, rideCriteria, callback) ->
      client = Down this.path + "/ride"
      client.rides.get rd.id, (err, ride) ->
        if err
          client.close (error) ->
            callback err
        else if ride.id
          if +rideCriteria.numberOfPeople <= 4 - +ride.numberOfPassenger
            data = {}
            data.numberOfPassenger = +ride.numberOfPassenger + +rideCriteria.numberOfPeople
            i = +ride.numberOfPassenger
            while i < data.numberOfPassenger
              data["passenger_" + ++i] = usr.id
            client.rides.set ride.id, data, (err) ->
              if err
                client.close (error) ->
                  callback err
              else
                client.rides.get ride.id, (err, ride) ->
                  if err
                    client.close (error) ->
                      callback err
                  else
                    client.rides.setByPassenger usr.id, ride, (err) ->
                      if err
                        client.close (error) ->
                          callback err
                      else
                        client.close (error) ->
                          callback null, {result: true, data: null}
          else
            client.close (error) ->
              callback null, {result: false, data: "Il n'y a plus assez de places disponibles pour ce trajet"}
        else
          client.close (error) ->
            callback null, {result: false, data: "Le trajet n'existe plus"}

    Up.prototype.createRide = (usr, rd, callback) ->
      client = Down this.path + "/ride"
      client.rides.getMaxId (err, maxId) ->
        if err
          client.close (error) ->
            callback err
        else
          client.rides.set ++maxId, rd.get(), (err) ->
            if err
              client.close (error) ->
                callback err
            else
              client.rides.get maxId, (err, ride) ->
                if err
                  client.close (error) ->
                    callback err
                else
                  client.rides.setByPassenger usr.id, ride, (err) ->
                    if err
                      client.close (error) ->
                        callback err
                    else
                      client.close (error) ->
                        callback null, {result: true, data: null}

    Up.prototype.getRide = (usr, callback) ->
      client = Down this.path + "/ride"
      client.rides.getByPassengerRideInProgress usr.id, moment(), (err, ride) ->
        if err
          client.close (error) ->
            callback err
        else if ride.id
          client.rides.get ride.id, (err, ride) ->
            if err
              client.close (error) ->
                callback err
            else
              client.close (error) ->
                ride = Ride ride
                data = ride.getPrivate()
                callback null, {result: true, data: data}
        else
          client.close (error) ->
            callback null, {result: false, data: "Aucun trajet en cours"}

    Up.prototype.getRideById = (rd, callback) ->
      client = Down this.path + "/ride"
      client.rides.get rd.id, (err, ride) ->
        if err
          client.close (error) ->
            callback err
        else if ride.id
          client.close (error) ->
            ride = Ride ride
            data = ride.getPublic()
            callback null, {result: true, data: data}
        else
          client.close (error) ->
            callback null, {result: false, data: "Le trajet n'existe plus"}

## Tool methods

    Up.prototype.show = (type, callback) ->
      show this.path, type, callback

    Up.prototype.import = (format, type, input, callback) ->
      return callback null, "This format is not supported" unless format is 'csv' or format is 'json'
      return callback null, "This type is not implemented yet" unless type is 'user' or type is 'stop'
      client = Down this.path + "/" + type
      fs
      .createReadStream input
      .on 'error', (err) ->
        callback err
      .pipe importStream client, format, type, objectMode: true
      .on 'finish', () ->
        client.close (error) ->
          callback error if error
          callback null, "Import finished"

    Up.prototype.export = (format, type, output, callback) ->
      return callback null, "This format is not supported" unless format is 'csv'
      return callback null, "This type is not implemented yet" unless type is 'user' or type is 'stop'
      if type is 'user'
        client = level this.path + "/" + type
        client.createReadStream
          gte: "users:"
          lte: "users:\xff"
        .pipe exportStream format, objectMode: true
        .pipe fs.createWriteStream output
        .on 'finish', () ->
          client.close (error) ->
            callback error if error
            callback null, "Export finished"
      else if type is 'stop'
        client = level this.path + "/" + type
        client.createReadStream
          gte: "stops:"
          lte: "stops:\xff"
        .pipe exportStream format, objectMode: true
        .pipe fs.createWriteStream output
        .on 'finish', () ->
          client.close (error) ->
            callback error if error
            callback null, "Export finished"

    module.exports = Up
