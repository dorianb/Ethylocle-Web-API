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
      numberOfPeople: '1'
    trippriceEngine = tripPrice()
    trippriceEngine.getActualPrice trip, (err, price) ->
      next()

  it 'Get actual price', (next) ->
    next()

  it 'Get presumed price', (next) ->
    next()
