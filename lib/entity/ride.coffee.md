# Ride entity

    geolib = require 'geolib'

    Ride = (ride) ->
      return new Ride ride unless this instanceof Ride
      if ride
        this.id = ride.id
        this.addressStart = ride.addressStart
        this.latStart = ride.latStart
        this.lonStart = ride.lonStart
        this.addressEnd = ride.addressEnd
        this.latEnd = ride.latEnd
        this.lonEnd = ride.lonEnd
        this.dateTime = ride.dateTime
        this.price = ride.price
        this.numberOfPassenger = ride.numberOfPassenger
        this.passenger_1 = ride.passenger_1
        this.passenger_2 = ride.passenger_2
        this.passenger_3 = ride.passenger_3
        this.passenger_4 = ride.passenger_4

    Ride.prototype.get = () ->
      result = {}
      for k, v of this
        if v and typeof v is 'string'
          result[k]=v
      return result

    Ride.prototype.getPrivate = () ->
      result = {}
      for k, v of this.get()
        result[k] = v unless k is "price"
      result.maxPrice = this.getPricePerParty()
      return result

    Ride.prototype.getPublic = () ->
      result = {}
      for k, v of this.get()
        result[k] = v if k in ["id", "addressStart", "latStart", "lonStart", "addressEnd", "latEnd", "lonEnd", "dateTime", "numberOfPassenger"]
      result.maxPrice = this.getPricePerPartyPlusOne()
      return result

    Ride.prototype.set = (ride) ->
      for k, v of ride
        this[k] = v if v and typeof v is 'string'

    Ride.prototype.setFrom = (ride) ->
      for k, v of ride
        if v and typeof v is 'string'
          this[k] = v unless this[k]

    Ride.prototype.toString = () ->
      result = "Ride"
      for k, v of this.get()
        result += " " + k + ":" + v
      return result

    Ride.prototype.setPrice = () ->
      distance = geolib.getDistance {latitude: this.latStart, longitude: this.lonStart}, {latitude: this.latEnd, longitude: this.lonEnd}
      ratio = 5
      this.price = (ratio*distance/1000).toFixed 2

    Ride.prototype.getPricePerParty = () ->
      nbParty = 1
      i = 1
      while i < +this.numberOfPassenger
        unless this["passenger_" + i] is this["passenger_" + (i+1)]
          nbParty++
        i++
      if nbParty is 1
        #Pas de réduction pour une seule partie prenante
        return this.price if nbParty is 1
      else
        #On gagne de l'argent lorsqu'on regroupe des personnes
        #Plus le nombre de parties sur un trajet est grand, plus on gagne de l'argent
        return (this.price/nbParty/1.1).toFixed 2

    Ride.prototype.getPricePerPartyPlusOne = () ->
      nbParty = 2
      i = 1
      while i < +this.numberOfPassenger
        unless this["passenger_" + i] is this["passenger_" + (i+1)]
          nbParty++
        i++
      return (this.price/nbParty/1.1).toFixed 2

    module.exports = Ride
