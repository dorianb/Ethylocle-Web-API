should = require 'should'
tripPrice = require '../lib/tripprice'

describe 'Trip price', ->

  it 'Get global price', (next) ->
    trip =
      latStart: '48.856470'
      lonStart: '2.286001'
      latEnd: '48.865314'
      lonEnd: '2.321514'
      dateTime: '22-01-2015 16:30'
      numberOfPassenger: '1'
    tripPrice().getGlobalPriceFromTaxiAPI trip, (err, price) ->
      price.should.eql 13.925
      next()

  it 'Get actual price with 1 passenger', (next) ->
    trip =
      latStart: '48.856470'
      lonStart: '2.286001'
      latEnd: '48.865314'
      lonEnd: '2.321514'
      dateTime: '22-01-2015 16:30'
      numberOfPassenger: '1'
      price: '13.925'
      passenger_1: '3'
    tripPrice().getActualPrice trip, (err, price) ->
      price.should.eql 13.925*1.05
      next()

  it 'Get actual price with 2 passengers and 2 parties', (next) ->
    trip =
      latStart: '48.856470'
      lonStart: '2.286001'
      latEnd: '48.865314'
      lonEnd: '2.321514'
      dateTime: '22-01-2015 16:30'
      numberOfPassenger: '2'
      price: '13.925'
      passenger_1: '3'
      passenger_2: '1'
    tripPrice().getActualPrice trip, (err, price) ->
      price.should.eql 13.925*1.05/2
      next()

  it 'Get actual price with 2 passengers and 1 party', (next) ->
    trip =
      latStart: '48.856470'
      lonStart: '2.286001'
      latEnd: '48.865314'
      lonEnd: '2.321514'
      dateTime: '22-01-2015 16:30'
      numberOfPassenger: '2'
      price: '13.925'
      passenger_1: '3'
      passenger_2: '3'
    tripPrice().getActualPrice trip, (err, price) ->
      price.should.eql 13.925*1.05
      next()

  it 'Get actual price with 3 passengers and 2 parties', (next) ->
    trip =
      latStart: '48.856470'
      lonStart: '2.286001'
      latEnd: '48.865314'
      lonEnd: '2.321514'
      dateTime: '22-01-2015 16:30'
      numberOfPassenger: '3'
      price: '13.925'
      passenger_1: '3'
      passenger_2: '1'
      passenger_3: '1'
    tripPrice().getActualPrice trip, (err, price) ->
      price.should.eql 13.925*1.05/2
      next()

  it 'Get actual price with 4 passengers and 2 parties', (next) ->
    trip =
      latStart: '48.856470'
      lonStart: '2.286001'
      latEnd: '48.865314'
      lonEnd: '2.321514'
      dateTime: '22-01-2015 16:30'
      numberOfPassenger: '4'
      price: '13.925'
      passenger_1: '3'
      passenger_2: '1'
      passenger_3: '1'
      passenger_4: '1'
    tripPrice().getActualPrice trip, (err, price) ->
      price.should.eql 13.925*1.05/2
      next()

  it 'Get actual price with 4 passengers and 3 parties', (next) ->
    trip =
      latStart: '48.856470'
      lonStart: '2.286001'
      latEnd: '48.865314'
      lonEnd: '2.321514'
      dateTime: '22-01-2015 16:30'
      numberOfPassenger: '4'
      price: '13.925'
      passenger_1: '3'
      passenger_2: '1'
      passenger_3: '1'
      passenger_4: '2'
    tripPrice().getActualPrice trip, (err, price) ->
      price.should.eql 13.925*1.05/3
      next()

  it 'Get actual price with 4 passengers and 3 parties', (next) ->
    trip =
      latStart: '48.856470'
      lonStart: '2.286001'
      latEnd: '48.865314'
      lonEnd: '2.321514'
      dateTime: '22-01-2015 16:30'
      numberOfPassenger: '4'
      price: '13.925'
      passenger_1: '3'
      passenger_2: '1'
      passenger_3: '2'
      passenger_4: '2'
    tripPrice().getActualPrice trip, (err, price) ->
      price.should.eql 13.925*1.05/3
      next()

  it 'Get actual price with 4 passengers and 4 parties', (next) ->
    trip =
      latStart: '48.856470'
      lonStart: '2.286001'
      latEnd: '48.865314'
      lonEnd: '2.321514'
      dateTime: '22-01-2015 16:30'
      numberOfPassenger: '4'
      price: '13.925'
      passenger_1: '3'
      passenger_2: '1'
      passenger_3: '0'
      passenger_4: '2'
    tripPrice().getActualPrice trip, (err, price) ->
      price.should.eql 13.925*1.05/4
      next()

  it 'Get presumed price', (next) ->
    trip =
      latStart: '48.856470'
      lonStart: '2.286001'
      latEnd: '48.865314'
      lonEnd: '2.321514'
      dateTime: '22-01-2015 16:30'
      numberOfPassenger: '1'
      price: '13.925'
      passenger_1: '3'
    tripPrice().getPresumedPrice trip, (err, price) ->
      price.should.eql 13.925*1.05/2
      next()
