# User class

    User = (user) ->
      return new User user unless this instanceof User
      if user
        this.id = user.id
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

    User.prototype.get = () ->
      result = {}
      for k, v of this
        if v and typeof v is 'string'
          result[k] = v
      return result

    User.prototype.set = (user) ->
      for k, v of user
        this[k] = v if v and typeof v is 'string'

    User.prototype.setFrom = (user) ->
      for k, v of user
        if v and typeof v is 'string'
          this[k] = v unless this[k]

    User.prototype.toString = () ->
      result = "User"
      for k, v of this.get()
        result += " " + k + ":" + v
      return result

    User.prototype.isEmail = () ->
      return false unless this.email
      regEmail = new RegExp '^[0-9a-z._-]+@{1}[0-9a-z.-]{2,}[.]{1}[a-z]{2,5}$', 'i'
      regEmail.test this.email

    User.prototype.isPassword = () ->
      return false unless this.password
      score = 0
      match = new RegExp "[a-z]+", ""
      if match.test this.password
        score++
      match = new RegExp "[A-Z]+", ""
      if match.test this.password
        score++
      match = new RegExp "[0-9]+", ""
      if match.test this.password
        score++
      match = new RegExp "[^A-Za-z0-9]+", ""
      if match.test this.password
        score++
      score += this.password.length
      if score > 8
        return true
      else
        return false

    module.exports = User
