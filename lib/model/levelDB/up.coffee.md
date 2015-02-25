# Up class inheriting from Abstract class

    AbstractModel = require '../abstract'
    Down = require './down'

    Up = (path="#{__dirname}/../../../db") ->
      return new Up path unless this instanceof Up
      AbstractModel.apply this, [path]

    Up.prototype = Object.create AbstractModel.prototype
    Up.prototype.constructor = Up

## User methods

    Up.prototype.signIn = (body, callback) ->
      client = Down this.path + "/user"
      client.users.getByEmail body.email, (err, user) ->
        if err
          client.close()
          callback err
        else
          client.users.get user.id, (err, user) ->
            if err
              client.close()
              callback err
            else if user.email is body.email and user.password is body.password
              client.close()
              callback null, {result: true, data: null, user: user}
            else
              client.close()
              callback null, {result: false, data: "Email ou mot de passe incorrect"}

    Up.prototype.checkPassword = (body, callback) ->
      client = Down this.path + "/user"
      client.users.get body.id, (err, user) ->
        if err
          client.close()
          callback err
        else if user.id is body.id and user.password is body.password
          client.close()
          callback null, {result: true, data: null}
        else
          client.close()
          callback null, {result: false, data: null}

    Up.prototype.signUp = (user, callback) ->
      #TO DO

    Up.prototype.updateEmail = (user, callback) ->
      #TO DO

    Up.prototype.update = (user, callback) ->
      #TO DO

    Up.prototype.get = (user, callback) ->
      #TO DO

    Up.prototype.getById = (user, callback) ->
      #TO DO

    Up.prototype.delete = (user, callback) ->
      #TO DO

## Trip methods

    Up.prototype.hasTrip = (user, callback) ->
      #TO DO

    Up.prototype.searchTrip = (user, tripCriteria, callback) ->
      #TO DO

    Up.prototype.joinTrip = (user, trip, tripCriteria, callback) ->
      #TO DO

    Up.prototype.createTrip = (user, trip, callback) ->
      #TO DO

    Up.prototype.getTrip = (user, callback) ->
      #TO DO

    Up.prototype.getTripById = (trip, callback) ->
      #TO DO


    module.exports = Up
