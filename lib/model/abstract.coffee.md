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

## Ride methods

    Model.prototype.hasRide = (usr, callback) ->
      throw new Error "Abstract method !"

    Model.prototype.searchRide = (usr, rideCriteria, callback) ->
      throw new Error "Abstract method !"

    Model.prototype.joinRide = (usr, rd, rideCriteria, callback) ->
      throw new Error "Abstract method !"

    Model.prototype.createRide = (usr, rd, callback) ->
      throw new Error "Abstract method !"

    Model.prototype.getRide = (usr, callback) ->
      throw new Error "Abstract method !"

    Model.prototype.getRideById = (rd, callback) ->
      throw new Error "Abstract method !"

## Tool methods

    Model.prototype.show = (type, callback) ->
      throw new Error "Abstract method !"

    Model.prototype.import = (format, type, input, callback) ->
      throw new Error "Abstract method !"

    Model.prototype.export = (format, type, output, callback) ->
      throw new Error "Abstract method !"

    module.exports = Model
