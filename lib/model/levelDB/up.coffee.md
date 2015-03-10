# Up class inheriting from Abstract class

    AbstractModel = require '../abstract'
    Down = require './down'
    TripSearch = require './tripSearch'

    show = require './tool/show'

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

## Trip methods

    Up.prototype.hasTrip = (usr, callback) ->
      client = Down this.path + "/trip"
      client.trips.getByPassengerTripInProgress usr.id, moment(), (err, trip) ->
        if err
          client.close () ->
            callback err
        else if trip.id
          client.close () ->
            callback null, {result: true, data: null}
        else
          client.close () ->
            callback null, {result: false, data: "Aucun trajet en cours"}

    Up.prototype.searchTrip = (usr, tripCriteria, callback) ->
      that = this
      TripSearch this.path, usr.id, tripCriteria.get(), (err, trips) ->
        client = Down that.path + "/tripsearch"
        client.tripsearch.getByUser usr.id, (err, result) ->
          if err
            client.close (error) ->
              callback err
          else
            delTripSearchByUser = (i) ->
              if i < result.length
                client.tripsearch.del result[i].userId, result[i].distance, result[i].tripId, (err) ->
                  if err
                    client.close (error) ->
                      callback err
                  else
                    delTripSearchByUser i+1
              else
                client.close (err) ->
                  callback err if err
                  client = Down that.path + "/trip"
                  data = []
                  getTripDetails = (i) ->
                    if i < trips.length
                      client.trips.get trips[i], (err, trip) ->
                        if err
                          client.close (error) ->
                            callback err
                        else
                          trip = Trip trip
                          datum = trip.getPublic()
                          datum.distanceToStart = geolib.getDistance({latitude: tripCriteria.latStart, longitude: tripCriteria.lonStart}, {latitude: trip.latStart, longitude: trip.lonStart})/1000
                          datum.distanceToEnd = geolib.getDistance({latitude: tripCriteria.latEnd, longitude: tripCriteria.lonEnd}, {latitude: trip.latEnd, longitude: trip.lonEnd})/1000
                          data.push datum
                          getTripDetails i+1
                    else
                      client.close (error) ->
                        callback null, {result: true, data: data}
                  getTripDetails 0
            delTripSearchByUser 0

    Up.prototype.joinTrip = (usr, trp, tripCriteria, callback) ->
      client = Down this.path + "/trip"
      client.trips.get trp.id, (err, trip) ->
        if err
          client.close (error) ->
            callback err
        else if trip.id
          if +tripCriteria.numberOfPeople <= 4 - +trip.numberOfPassenger
            data = {}
            data.numberOfPassenger = +trip.numberOfPassenger + +tripCriteria.numberOfPeople
            i = +trip.numberOfPassenger
            while i < data.numberOfPassenger
              data["passenger_" + ++i] = usr.id
            client.trips.set trip.id, data, (err) ->
              if err
                client.close (error) ->
                  callback err
              else
                client.trips.get trip.id, (err, trip) ->
                  if err
                    client.close (error) ->
                      callback err
                  else
                    client.trips.setByPassenger usr.id, trip, (err) ->
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

    Up.prototype.createTrip = (usr, trp, callback) ->
      client = Down this.path + "/trip"
      client.trips.getMaxId (err, maxId) ->
        if err
          client.close (error) ->
            callback err
        else
          client.trips.set ++maxId, trp.get(), (err) ->
            if err
              client.close (error) ->
                callback err
            else
              client.trips.get maxId, (err, trip) ->
                if err
                  client.close (error) ->
                    callback err
                else
                  client.trips.setByPassenger usr.id, trip, (err) ->
                    if err
                      client.close (error) ->
                        callback err
                    else
                      client.close (error) ->
                        callback null, {result: true, data: null}

    Up.prototype.getTrip = (usr, callback) ->
      client = Down this.path + "/trip"
      client.trips.getByPassengerTripInProgress usr.id, moment(), (err, trip) ->
        if err
          client.close (error) ->
            callback err
        else if trip.id
          client.trips.get trip.id, (err, trip) ->
            if err
              client.close (error) ->
                callback err
            else
              client.close (error) ->
                trip = Trip trip
                data = trip.getPrivate()
                callback null, {result: true, data: data}
        else
          client.close (error) ->
            callback null, {result: false, data: "Aucun trajet en cours"}

    Up.prototype.getTripById = (trp, callback) ->
      client = Down this.path + "/trip"
      client.trips.get trp.id, (err, trip) ->
        if err
          client.close (error) ->
            callback err
        else if trip.id
          client.close (error) ->
            trip = Trip trip
            data = trip.getPublic()
            callback null, {result: true, data: data}
        else
          client.close (error) ->
            callback null, {result: false, data: "Le trajet n'existe plus"}

## Tool methods

    Up.prototype.show = (type, callback) ->
      show this.path, type, callback
      #argv['_'][0] + ": " + nbRows

    Up.prototype.import = (format, type, callback) ->
      #TO DO
      ###
      var path = __dirname + "/../db/" + argv['type']
      if((argv['format'] == 'csv') || (argv['format'] == 'json'))
      {
        if(argv['_'][0] != null)
        {
          var client = db(path);
          fs
          .createReadStream(argv['_'][0])
          .on('end', function(){
            console.log('Import finished');
          })
          .pipe(importStream(client, argv['format'], argv['type'], {objectMode: true}));
        }
      }
      else
      {
        console.log('This format is not supported');
      }###

    Up.prototype.export = (format, type, callback) ->
      #TO DO
      ###
      if((argv['format'] == 'csv') || (argv['format'] == 'json'))
      {
        exportStream(__dirname + "/../db/user", argv['format'], {objectMode: true})
        .on('end', function(){
          console.log('Export finished');
        })
        .pipe(fs.createWriteStream(argv['_'][0]));
      }
      else
      {
        console.log('This format is not supported');
      }###

    module.exports = Up
