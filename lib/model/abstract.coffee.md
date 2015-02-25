# Model abstract class

    Model = (model) ->
      throw new Error "Can't instantiate abstract class !" if this.constructor is Model
      if model
        this.path = model

## User methods

    Model.prototype.signIn = (user, callback) ->
      throw new Error "Abstract method !"

    Model.prototype.checkPassword = (user, callback) ->
      throw new Error "Abstract method !"

    Model.prototype.signUp = (user, callback) ->
      throw new Error "Abstract method !"

    Model.prototype.updateEmail = (user, callback) ->
      throw new Error "Abstract method !"

    Model.prototype.update = (user, callback) ->
      throw new Error "Abstract method !"

    Model.prototype.get = (user, callback) ->
      throw new Error "Abstract method !"

    Model.prototype.getById = (user, callback) ->
      throw new Error "Abstract method !"

    Model.prototype.delete = (user, callback) ->
      throw new Error "Abstract method !"

## Trip methods

    Model.prototype.hasTrip = (user, callback) ->
      throw new Error "Abstract method !"

    Model.prototype.searchTrip = (user, tripCriteria, callback) ->
      throw new Error "Abstract method !"

    Model.prototype.joinTrip = (user, trip, tripCriteria, callback) ->
      throw new Error "Abstract method !"

    Model.prototype.createTrip = (user, trip, callback) ->
      throw new Error "Abstract method !"

    Model.prototype.getTrip = (user, callback) ->
      throw new Error "Abstract method !"

    Model.prototype.getTripById = (trip, callback) ->
      throw new Error "Abstract method !"

    module.exports = Model
