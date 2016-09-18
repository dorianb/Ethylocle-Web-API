# Ride criteria entity

    RideCriteria = (rideCriteria) ->
      return new RideCriteria rideCriteria unless this instanceof RideCriteria
      if rideCriteria
        this.addressStart = rideCriteria.addressStart
        this.latStart = rideCriteria.latStart
        this.lonStart = rideCriteria.lonStart
        this.addressEnd = rideCriteria.addressEnd
        this.latEnd = rideCriteria.latEnd
        this.lonEnd = rideCriteria.lonEnd
        this.dateTime = rideCriteria.dateTime
        this.numberOfPeople = rideCriteria.numberOfPeople

    RideCriteria.prototype.get = () ->
      result = {}
      for k, v of this
        if v and typeof v is 'string'
          result[k]=v
      return result

    RideCriteria.prototype.toString = () ->
      result = "Ride criteria"
      for k, v of this.get()
        result += " " + k + ":" + v
      return result

    module.exports = RideCriteria
