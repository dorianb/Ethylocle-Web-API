# Trip entity

    Trip = (trip) ->
      return new Trip trip unless this instanceof Trip
      if trip
        this.id = trip.id
        this.addressStart = trip.addressStart
        this.latStart = trip.latStart
        this.lonStart = trip.lonStart
        this.addressEnd = trip.addressEnd
        this.latEnd = trip.latEnd
        this.lonEnd = trip.lonEnd
        this.dateTime = trip.dateTime
        this.price = trip.price
        this.numberOfPassenger = trip.numberOfPassenger
        this.passenger_1 = trip.passenger_1
        this.passenger_2 = trip.passenger_2
        this.passenger_3 = trip.passenger_3
        this.passenger_4 = trip.passenger_4

    Trip.prototype.get = () ->
      result = {}
      for k, v of this
        if v and typeof v is 'string'
          result[k]=v
      return result

    Trip.prototype.toString = () ->
      result = "Trip"
      for k, v of this.get()
        result += " " + k + ":" + v
      return result

    module.exports = Trip
