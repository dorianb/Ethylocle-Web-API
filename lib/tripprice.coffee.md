# Trip price

    geolib = require 'geolib'

    tripPrice = ->
      getGlobalPriceFromTaxiAPI: (trip, callback) ->
        #For test purpose, it estimates trip price from flight distance to travel
        callback null, 30
      getActualPrice: (trip, callback) ->
        callback null, 15
      getPresumedPrice: (trip, callback) ->
        callback null, 10

    module.exports = tripPrice
