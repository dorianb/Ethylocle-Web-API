# User class inheriting from Entity class

    Entity = require './entity'

    User = (user) ->
      return new User user unless this instanceof User
      Entity.apply this, [user]
      if user
        this.email = user.email
        this.image = user.image
        this.lastName = user.lastName
        this.firstName = user.firstName
        this.birthDate = user.birthDate
        this.gender = user.gender
        this.weight = user.weight
        this.address = user.address
        this.zipCode = user.zipCode
        this.city = user.city
        this.country = user.country
        this.phone = user.phone
        this.password = user.password
        this.latitude = user.latitude
        this.longitude = user.longitude
        this.positionDate = user.positionDate
        this.bac = user.bac
        this.bacDate = user.bacDate

    User.prototype = Object.create Entity.prototype
    User.prototype.constructor = User

    User.prototype.get = () ->
      result = {}
      for k, v of this
        if v and typeof v is 'string'
          result[k]=v
      return result

    User.prototype.toString = () ->
      result = "User"
      for k, v of this.get()
        result += " " + k + ":" + v
      return result

    module.exports = User
