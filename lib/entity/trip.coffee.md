# Trip entity

    geolib = require 'geolib'

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

    Trip.prototype.getPrivate = () ->
      result = {}
      for k, v of this.get()
        result[k] = v unless k is "price"
      result.maxPrice = this.getPricePerParty()
      return result

    Trip.prototype.getPublic = () ->
      result = {}
      for k, v of this.get()
        result[k] = v if k in ["id", "addressStart", "latStart", "lonStart", "addressEnd", "latEnd", "lonEnd", "dateTime", "numberOfPassenger"]
      result.maxPrice = this.getPricePerPartyPlusOne()
      return result

    Trip.prototype.set = (trip) ->
      for k, v of trip
        this[k] = v if v and typeof v is 'string'

    Trip.prototype.setFrom = (trip) ->
      for k, v of trip
        if v and typeof v is 'string'
          this[k] = v unless this[k]

    Trip.prototype.toString = () ->
      result = "Trip"
      for k, v of this.get()
        result += " " + k + ":" + v
      return result

    Trip.prototype.setPrice = () ->
      distance = geolib.getDistance {latitude: this.latStart, longitude: this.lonStart}, {latitude: this.latEnd, longitude: this.lonEnd}
      ratio = 5
      this.price = (ratio*distance/1000).toFixed 2

    Trip.prototype.getPricePerParty = () ->
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
        #On gagne de l'argent lorsqu'on regroupe des personnes #Plus le nombre de parties sur un trajet est grand, plus on gagne de l'argent
        return (this.price/nbParty/1.1).toFixed 2

    Trip.prototype.getPricePerPartyPlusOne = () ->
      nbParty = 2
      i = 1
      while i < +this.numberOfPassenger
        unless this["passenger_" + i] is this["passenger_" + (i+1)]
          nbParty++
        i++
      return (this.price/nbParty/1.1).toFixed 2

    module.exports = Trip
