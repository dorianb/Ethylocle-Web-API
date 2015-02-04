# Trip price

    geolib = require 'geolib'

    tripPrice = ->
      getGlobalPriceFromTaxiAPI: (trip, callback) ->
        #For test purpose, it estimates trip price from flight-bird distance to travel
          #distance/1000 (km)
          #ratio = 5 (€/km)
          #price = ratio*distance/1000
        distance = geolib.getDistance {latitude: trip.latStart, longitude: trip.lonStart}, {latitude: trip.latEnd, longitude: trip.lonEnd}
        ratio = 5
        callback null, ratio*distance/1000
      getActualPrice: (trip, callback) ->
        #On majore le prix payé à Taxi G7 de 5% (Pour gagner de l'argent bon dieu !)
        majoration = 1.05
        actualPrice = +trip.price*majoration
        #On récupère le nombre de parties prenantes
        nbParty = 1
        i = 1
        while i < +trip.numberOfPassenger
          unless trip["passenger_" + i] is trip["passenger_" + (i+1)]
            nbParty++
          i++
        callback null, actualPrice/nbParty
      getPresumedPrice: (trip, callback) ->
        #On majore le prix payé à Taxi G7 de 5% (Pour gagner de l'argent bon dieu !)
        majoration = 1.05
        actualPrice = +trip.price*majoration
        #On récupère le nombre de parties prenantes
        nbParty = 1
        i = 1
        while i < +trip.numberOfPassenger
          unless trip["passenger_" + i] is trip["passenger_" + (i+1)]
            nbParty++
          i++
        nbParty++
        callback null, actualPrice/nbParty

    module.exports = tripPrice
