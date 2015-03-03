# Up class inheriting from Abstract class

    AbstractModel = require '../abstract'
    Down = require './down'
    TripSearch = require './tripSearch'

    User = require '../../entity/user'
    Trip = require '../../entity/trip'
    TripCriteria = require '../../entity/tripCriteria'

    moment = require 'moment'
    geolib = require 'geolib'

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
          client.close()
          callback err
        else
          client.users.get user.id, (err, user) ->
            if err
              client.close()
              callback err
            else if user.email is usr.email and user.password is usr.password
              client.close()
              callback null, {result: true, data: null, user: user}
            else
              client.close()
              callback null, {result: false, data: "Email ou mot de passe incorrect"}

    Up.prototype.checkPassword = (usr, callback) ->
      client = Down this.path + "/user"
      client.users.get usr.id, (err, user) ->
        if err
          client.close()
          callback err
        else if user.id is usr.id and user.password is usr.password
          client.close()
          callback null, {result: true, data: null}
        else
          client.close()
          callback null, {result: false, data: null}

    Up.prototype.signUp = (usr, callback) ->
      client = Down this.path + "/user"
      client.users.getByEmail usr.email, (err, user) ->
        if err
          client.close()
          callback err
        else if user.email is usr.email
          client.close()
          callback null, {result: false, data: "L'email n'est plus disponible"}
        else
          client.users.getMaxId (err, maxId) ->
            if err
              client.close()
              callback err
            else
              usr.id = (++maxId).toString()
              client.users.set usr.id, usr.get(), (err) ->
                if err
                  client.close()
                  callback err
                else
                  client.users.setByEmail usr.email, usr.get(), (err) ->
                    if err
                      client.close()
                      callback err
                    else
                      client.close()
                      callback null, {result: true, data: null, user: usr.get()}

    Up.prototype.updateEmail = (usr, callback) ->
      client = Down this.path + "/user"
      client.users.getByEmail usr.email, (err, user) ->
        if err
          client.close()
          callback err
        else if user.email is usr.email
          client.close()
          callback null, {result: false, data: "L'email n'est plus disponible"}
        else
          client.users.get usr.id, (err, user) ->
            if err
              client.close()
              callback err
            else
              client.users.delByEmail user.email, user, (err) ->
                if err
                  client.close()
                  callback err
                else
                  client.users.set usr.id, usr.get(), (err) ->
                    if err
                      client.close()
                      callback err
                    else
                      client.users.setByEmail usr.email, usr.get(), (err) ->
                        if err
                          client.close()
                          callback err
                        else
                          client.close()
                          callback null, {result: true, data: null}

    Up.prototype.update = (usr, callback) ->
      client = Down this.path + "/user"
      client.users.set usr.id, usr.get(), (err) ->
        if err
          client.close()
          callback err
        else
          client.close()
          callback null, {result: true, data: null}

    Up.prototype.get = (usr, callback) ->
      client = Down this.path + "/user"
      client.users.get usr.id, (err, user) ->
        if err
          client.close()
          callback err
        else
          client.close()
          usr.set user
          callback null, {result: true, data: usr.getPrivate()}

    Up.prototype.getById = (usr, callback) ->
      client = Down this.path + "/user"
      client.users.get usr.id, (err, user) ->
        if err
          client.close()
          callback err
        else if user.id
          client.close()
          usr.set user
          callback null, {result: true, data: usr.getPublic()}
        else
          client.close()
          callback null, {result: false, data: "L'utilisateur n'existe pas"}

    Up.prototype.delete = (usr, callback) ->
      client = Down this.path + "/user"
      client.users.get usr.id, (err, user) ->
        if err
          client.close()
          callback err
        else
          client.users.del user.id, user, (err) ->
            if err
              client.close()
              callback err
            else
              client.users.delByEmail user.email, user, (err) ->
                if err
                  client.close()
                  callback err
                else
                  client.close()
                  callback null, {result: true, data: null}

## Trip methods

    Up.prototype.hasTrip = (usr, callback) ->
      client = Down this.path + "/trip"
      client.trips.getByPassengerTripInProgress usr.id, moment(), (err, trip) ->
        if err
          client.close()
          callback err
        else if trip.id
          client.close()
          callback null, {result: true, data: null}
        else
          client.close()
          callback null, {result: false, data: "Aucun trajet en cours"}

    Up.prototype.searchTrip = (usr, tripCriteria, callback) ->
      tripSearch this.path, usr.id, tripCriteria.get(), (err, trips) ->
        client = Down this.path + "/tripsearch"
        client.tripsearch.getByUser usr.id, (err, result) ->
          if err
            client.close()
            callback err
          else
            delTripSearchByUser = (i) ->
              if i < result.length
                client.tripsearch.del result[i].userId, result[i].distance, result[i].tripId, (err) ->
                  if err
                    client.close()
                    callback err
                  else
                    delTripSearchByUser i+1
              else
                client.close (err) ->
                  callback err if err
                  client = Down this.path + "/trip"
                  data = []
                  getTripDetails = (i) ->
                    if i < trips.length
                      client.trips.get trips[i], (err, trip) ->
                        if err
                          client.close()
                          callback err
                        else
                          trip = Trip trip
                          datum = trip.getPublic()
                          datum.distanceToStart = geolib.getDistance({latitude: tripCriteria.latStart, longitude: tripCriteria.lonStart}, {latitude: trip.latStart, longitude: trip.lonStart})/1000
                          datum.distanceToEnd = geolib.getDistance({latitude: tripCriteria.latEnd, longitude: tripCriteria.lonEnd}, {latitude: trip.latEnd, longitude: trip.lonEnd})/1000
                          data.push datum
                          getTripDetails i+1
                    else
                      client.close()
                      callback null, {result: true, data: data}
                  getTripDetails 0
            delTripSearchByUser 0

    Up.prototype.joinTrip = (usr, trp, tripCriteria, callback) ->
      this.hasTrip usr, (err, message) ->
        return callback err if err
        return callback null, {result: false, data: "Vous avez déjà un trajet en cours"} if message.result
        client = Down this.path + "/trip"
        client.trips.get trp.id, (err, trip) ->
          if err
            client.close()
            callback err
          else if trip.id
            if tripCriteria.numberOfPeople <= 4 - +trip.numberOfPassenger
              data = {}
              data.numberOfPassenger = +trip.numberOfPassenger + +tripCriteria.numberOfPeople
              i = trip.numberOfPassenger
              while i < data.numberOfPassenger
                data["passenger_" + ++i] = usr.id
              client.trips.set trip.id, data, (err) ->
                if err
                  client.close()
                  callback err
                else
                  client.trips.get trip.id, (err, trip) ->
                    if err
                      client.close()
                      callback err
                    else
                      client.trips.setByPassenger req.session.userId, trip, (err) ->
                        if err
                          client.close()
                          callback err
                        else
                          client.close()
                          callback null, {result: true, data: null}
            else
              client.close()
              callback null, {result: false, data: "Il n'y a plus assez de places disponibles pour ce trajet"}
          else
            client.close()
            callback null, {result: false, data: "Le trajet n'existe plus"}

    Up.prototype.createTrip = (usr, trp, callback) ->
      client = Down this.path + "/trip"
      client.trips.getMaxId (err, maxId) ->
        if err
          client.close()
          callback err
        else
          client.trips.set ++maxId, trp.get(), (err) ->
            if err
              client.close()
              callback err
            else
              client.trips.get maxId, (err, trip) ->
                if err
                  client.close()
                  callback err
                else
                  client.trips.setByPassenger usr.id, trip, (err) ->
                    if err
                      client.close()
                      callback err
                    else
                      client.close()
                      callback null, {result: true, data: null}

    Up.prototype.getTrip = (usr, callback) ->
      client = Down this.path + "/trip"
      client.trips.getByPassengerTripInProgress usr.id, moment(), (err, trip) ->
        if err
          client.close()
          callback err
        else if trip.id
          client.trips.get trip.id, (err, trip) ->
            if err
              client.close()
              callback err
            else
              client.close()
              trip = Trip trip
              data = trip.getPrivate()
              callback null, {result: true, data: data}
        else
          client.close()
          callback null, {result: false, data: "Aucun trajet en cours"}

    Up.prototype.getTripById = (trp, callback) ->
      client = Down this.path + "/trip"
      client.trips.get trp.id, (err, trip) ->
        if err
          client.close()
          callback err
        else if trip.id
          client.close()
          trip = Trip trip
          data = trip.getPublic()
          callback null, {result: true, data: data}
        else
          client.close()
          callback null, {result: false, data: "Le trajet n'existe plus"}

    module.exports = Up
