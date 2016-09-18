should = require 'should'
Ride = require '../ride'

describe 'Ride entity', ->

  it 'Create ride', (next) ->
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
    ride = Ride data
    ride.id.should.eql data.id
    should.not.exists ride.addressStart
    ride.latStart.should.eql data.latStart
    ride.lonStart.should.eql data.lonStart
    should.not.exists ride.addressEnd
    ride.latEnd.should.eql data.latEnd
    ride.lonEnd.should.eql data.lonEnd
    ride.dateTime.should.eql data.dateTime
    ride.price.should.eql data.price
    ride.passenger_1.should.eql data.passenger_1
    ride.passenger_2.should.eql data.passenger_2
    should.not.exists ride.passenger_3
    should.not.exists ride.passenger_4
    next()

  it 'Get ride', (next) ->
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
    ride = Ride data
    ride = ride.get()
    ride.id.should.eql data.id
    should.not.exists ride.addressStart
    ride.latStart.should.eql data.latStart
    ride.lonStart.should.eql data.lonStart
    should.not.exists ride.addressEnd
    ride.latEnd.should.eql data.latEnd
    ride.lonEnd.should.eql data.lonEnd
    ride.dateTime.should.eql data.dateTime
    ride.price.should.eql data.price
    ride.passenger_1.should.eql data.passenger_1
    ride.passenger_2.should.eql data.passenger_2
    should.not.exists ride.passenger_3
    should.not.exists ride.passenger_4
    next()

  it 'Ride toString', (next) ->
    data =
      id: '0'
      latStart: '48.853611'
      passenger_1: '0'
      passenger_2: '0'
    ride = Ride data
    string = ride.toString()
    string.should.eql "Ride id:0 latStart:48.853611 passenger_1:0 passenger_2:0"
    next()

  it 'Set price', (next) ->
    data =
      latStart: '48.856470'
      lonStart: '2.286001'
      latEnd: '48.865314'
      lonEnd: '2.321514'
      dateTime: '22-01-2015 16:30'
      numberOfPassenger: '1'
    ride = Ride data
    ride.setPrice()
    ride.price.should.eql '13.93'
    next()

  it 'Get price per party with 1 passenger', (next) ->
    ride =
      latStart: '48.856470'
      lonStart: '2.286001'
      latEnd: '48.865314'
      lonEnd: '2.321514'
      dateTime: '22-01-2015 16:30'
      numberOfPassenger: '1'
      price: '13.93'
      passenger_1: '3'
    ride = Ride ride
    ride.getPricePerParty().should.eql '13.93'
    next()

  it 'Get price per party with 2 passengers and 2 parties', (next) ->
    ride =
      latStart: '48.856470'
      lonStart: '2.286001'
      latEnd: '48.865314'
      lonEnd: '2.321514'
      dateTime: '22-01-2015 16:30'
      numberOfPassenger: '2'
      price: '13.93'
      passenger_1: '3'
      passenger_2: '1'
    ride = Ride ride
    ride.getPricePerParty().should.eql (13.93/2/1.1).toFixed 2
    next()

  it 'Get price per party with 2 passengers and 1 party', (next) ->
    ride =
      latStart: '48.856470'
      lonStart: '2.286001'
      latEnd: '48.865314'
      lonEnd: '2.321514'
      dateTime: '22-01-2015 16:30'
      numberOfPassenger: '2'
      price: '13.93'
      passenger_1: '3'
      passenger_2: '3'
    ride = Ride ride
    ride.getPricePerParty().should.eql '13.93'
    next()

  it 'Get price per party with 3 passengers and 2 parties', (next) ->
    ride =
      latStart: '48.856470'
      lonStart: '2.286001'
      latEnd: '48.865314'
      lonEnd: '2.321514'
      dateTime: '22-01-2015 16:30'
      numberOfPassenger: '3'
      price: '13.93'
      passenger_1: '3'
      passenger_2: '1'
      passenger_3: '1'
    ride = Ride ride
    ride.getPricePerParty().should.eql (13.93/2/1.1).toFixed 2
    next()

  it 'Get price per party with 4 passengers and 2 parties', (next) ->
    ride =
      latStart: '48.856470'
      lonStart: '2.286001'
      latEnd: '48.865314'
      lonEnd: '2.321514'
      dateTime: '22-01-2015 16:30'
      numberOfPassenger: '4'
      price: '13.93'
      passenger_1: '3'
      passenger_2: '1'
      passenger_3: '1'
      passenger_4: '1'
    ride = Ride ride
    ride.getPricePerParty().should.eql (13.93/2/1.1).toFixed 2
    next()

  it 'Get price per party with 4 passengers and 3 parties', (next) ->
    ride =
      latStart: '48.856470'
      lonStart: '2.286001'
      latEnd: '48.865314'
      lonEnd: '2.321514'
      dateTime: '22-01-2015 16:30'
      numberOfPassenger: '4'
      price: '13.93'
      passenger_1: '3'
      passenger_2: '1'
      passenger_3: '1'
      passenger_4: '2'
    ride = Ride ride
    ride.getPricePerParty().should.eql (13.93/3/1.1).toFixed 2
    next()

  it 'Get price per party with 4 passengers and 3 parties', (next) ->
    ride =
      latStart: '48.856470'
      lonStart: '2.286001'
      latEnd: '48.865314'
      lonEnd: '2.321514'
      dateTime: '22-01-2015 16:30'
      numberOfPassenger: '4'
      price: '13.93'
      passenger_1: '3'
      passenger_2: '1'
      passenger_3: '2'
      passenger_4: '2'
    ride = Ride ride
    ride.getPricePerParty().should.eql (13.93/3/1.1).toFixed 2
    next()

  it 'Get price per party with 4 passengers and 4 parties', (next) ->
    ride =
      latStart: '48.856470'
      lonStart: '2.286001'
      latEnd: '48.865314'
      lonEnd: '2.321514'
      dateTime: '22-01-2015 16:30'
      numberOfPassenger: '4'
      price: '13.93'
      passenger_1: '3'
      passenger_2: '1'
      passenger_3: '0'
      passenger_4: '2'
    ride = Ride ride
    ride.getPricePerParty().should.eql (13.93/4/1.1).toFixed 2
    next()

  it 'Get price per party plus one', (next) ->
    ride =
      latStart: '48.856470'
      lonStart: '2.286001'
      latEnd: '48.865314'
      lonEnd: '2.321514'
      dateTime: '22-01-2015 16:30'
      numberOfPassenger: '1'
      price: '13.93'
      passenger_1: '3'
    ride = Ride ride
    ride.getPricePerPartyPlusOne().should.eql (13.93/2/1.1).toFixed 2
    next()

  it 'Get private ride data', (next) ->
    data =
      id: '0'
      latStart: '48.856470'
      lonStart: '2.286001'
      latEnd: '48.865314'
      lonEnd: '2.321514'
      dateTime: '22-01-2015 16:30'
      numberOfPassenger: '1'
      price: '13.93'
      passenger_1: '3'
    ride = Ride data
    ride = ride.getPrivate()
    ride.id.should.eql data.id
    should.not.exists ride.addressStart
    ride.latStart.should.eql data.latStart
    ride.lonStart.should.eql data.lonStart
    should.not.exists ride.addressEnd
    ride.latEnd.should.eql data.latEnd
    ride.lonEnd.should.eql data.lonEnd
    ride.dateTime.should.eql data.dateTime
    should.not.exists ride.price
    ride.maxPrice.should.eql '13.93'
    ride.passenger_1.should.eql data.passenger_1
    should.not.exists ride.passenger_2
    should.not.exists ride.passenger_3
    should.not.exists ride.passenger_4
    next()

  it 'Get public ride data', (next) ->
    data =
      id: '0'
      latStart: '48.856470'
      lonStart: '2.286001'
      latEnd: '48.865314'
      lonEnd: '2.321514'
      dateTime: '22-01-2015 16:30'
      numberOfPassenger: '1'
      price: '13.93'
      passenger_1: '3'
    ride = Ride data
    ride = ride.getPublic()
    ride.id.should.eql data.id
    should.not.exists ride.addressStart
    ride.latStart.should.eql data.latStart
    ride.lonStart.should.eql data.lonStart
    should.not.exists ride.addressEnd
    ride.latEnd.should.eql data.latEnd
    ride.lonEnd.should.eql data.lonEnd
    ride.dateTime.should.eql data.dateTime
    should.not.exists ride.price
    ride.maxPrice.should.eql (13.93/2/1.1).toFixed 2
    should.not.exists ride.passenger_1
    should.not.exists ride.passenger_2
    should.not.exists ride.passenger_3
    should.not.exists ride.passenger_4
    next()
