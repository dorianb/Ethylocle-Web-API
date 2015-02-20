# Entity abstract class

    Entity = (entity) ->
      throw new Error "Can't instantiate abstract class !" if this.constructor is Entity
      if entity
        this.id = entity.id

    Entity.prototype.get = () ->
      throw new Error "Abstract method !"

    Entity.prototype.toString = () ->
      throw new Error "Abstract method !"

    module.exports = Entity
