# Trip criteria entity

    TripCriteria = (tripCriteria) ->
      return new TripCriteria tripCriteria unless this instanceof TripCriteria
      if tripCriteria
        this.addressStart = tripCriteria.addressStart
        this.latStart = tripCriteria.latStart
        this.lonStart = tripCriteria.lonStart
        this.addressEnd = tripCriteria.addressEnd
        this.latEnd = tripCriteria.latEnd
        this.lonEnd = tripCriteria.lonEnd
        this.dateTime = tripCriteria.dateTime
        this.numberOfPeople = tripCriteria.numberOfPeople

    TripCriteria.prototype.get = () ->
      result = {}
      for k, v of this
        if v and typeof v is 'string'
          result[k]=v
      return result

    TripCriteria.prototype.toString = () ->
      result = "Trip criteria"
      for k, v of this.get()
        result += " " + k + ":" + v
      return result

    module.exports = TripCriteria
