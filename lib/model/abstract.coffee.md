# Model abstract class

    Model = (model) ->
      throw new Error "Can't instantiate abstract class !" if this.constructor is Model
      if model
        this.path = model

## User methods

    Model.prototype.signIn = (usr, callback) ->
      throw new Error "Abstract method !"

    Model.prototype.checkPassword = (usr, callback) ->
      throw new Error "Abstract method !"

    Model.prototype.signUp = (usr, callback) ->
      throw new Error "Abstract method !"

    Model.prototype.updateEmail = (usr, callback) ->
      throw new Error "Abstract method !"

    Model.prototype.update = (usr, callback) ->
      throw new Error "Abstract method !"

    Model.prototype.get = (usr, callback) ->
      throw new Error "Abstract method !"

    Model.prototype.getById = (usr, callback) ->
      throw new Error "Abstract method !"

    Model.prototype.delete = (usr, callback) ->
      throw new Error "Abstract method !"

## Trip methods

    Model.prototype.hasTrip = (usr, callback) ->
      throw new Error "Abstract method !"

    Model.prototype.searchTrip = (usr, tripCriteria, callback) ->
      throw new Error "Abstract method !"

    Model.prototype.joinTrip = (usr, trp, tripCriteria, callback) ->
      throw new Error "Abstract method !"

    Model.prototype.createTrip = (usr, trp, callback) ->
      throw new Error "Abstract method !"

    Model.prototype.getTrip = (usr, callback) ->
      throw new Error "Abstract method !"

    Model.prototype.getTripById = (trp, callback) ->
      throw new Error "Abstract method !"

    module.exports = Model
