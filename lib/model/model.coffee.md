# Model abstract class

    Model = () ->
      throw new Error "Can't instantiate abstract class !" if this.constructor is Model

    Model.prototype.get = () ->
      throw new Error "Abstract method !"

    Model.prototype.toString = () ->
      throw new Error "Abstract method !"

    module.exports = Model
