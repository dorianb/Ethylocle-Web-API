should = require 'should'
Trip = require '../trip'

describe 'Trip entity', ->

  it 'Create trip', (next) ->
    data =
      id: '0'
      latStart: '48.853611'
      lonStart: '2.287546'
      latEnd: '48.860359'
      lonEnd: '2.352949'
      dateTime: '22-01-2015 16:30'
      price: '30'
      passenger_1: '0'
      passenger_2: '0'
    trip = new Trip data
    trip.id.should.eql data.id
    should.not.exists trip.addressStart
    trip.latStart.should.eql data.latStart
    trip.lonStart.should.eql data.lonStart
    should.not.exists trip.addressEnd
    trip.latEnd.should.eql data.latEnd
    trip.lonEnd.should.eql data.lonEnd
    trip.dateTime.should.eql data.dateTime
    trip.price.should.eql data.price
    trip.passenger_1.should.eql data.passenger_1
    trip.passenger_2.should.eql data.passenger_2
    should.not.exists trip.passenger_3
    should.not.exists trip.passenger_4
    next()

  it 'Get trip', (next) ->
    data =
      id: '0'
      latStart: '48.853611'
      lonStart: '2.287546'
      latEnd: '48.860359'
      lonEnd: '2.352949'
      dateTime: '22-01-2015 16:30'
      price: '30'
      passenger_1: '0'
      passenger_2: '0'
    trip = new Trip data
    trip = trip.get()
    trip.id.should.eql data.id
    should.not.exists trip.addressStart
    trip.latStart.should.eql data.latStart
    trip.lonStart.should.eql data.lonStart
    should.not.exists trip.addressEnd
    trip.latEnd.should.eql data.latEnd
    trip.lonEnd.should.eql data.lonEnd
    trip.dateTime.should.eql data.dateTime
    trip.price.should.eql data.price
    trip.passenger_1.should.eql data.passenger_1
    trip.passenger_2.should.eql data.passenger_2
    should.not.exists trip.passenger_3
    should.not.exists trip.passenger_4
    next()

  it 'Trip toString', (next) ->
    data =
      id: '0'
      latStart: '48.853611'
      passenger_1: '0'
      passenger_2: '0'
    trip = Trip data
    string = trip.toString()
    string.should.eql "Trip id:0 latStart:48.853611 passenger_1:0 passenger_2:0"
    next()
