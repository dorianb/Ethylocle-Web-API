# Up class inheriting from Abstract class

    AbstractModel = require '../abstract'
    Down = require './down'

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
