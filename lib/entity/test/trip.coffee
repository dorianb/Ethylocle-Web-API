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
    trip = Trip data
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
    trip = Trip data
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

  it 'Set price', (next) ->
    data =
      latStart: '48.856470'
      lonStart: '2.286001'
      latEnd: '48.865314'
      lonEnd: '2.321514'
      dateTime: '22-01-2015 16:30'
      numberOfPassenger: '1'
    trip = Trip data
    trip.setPrice()
    trip.price.should.eql '13.93'
    next()

  it 'Get price per party with 1 passenger', (next) ->
    trip =
      latStart: '48.856470'
      lonStart: '2.286001'
      latEnd: '48.865314'
      lonEnd: '2.321514'
      dateTime: '22-01-2015 16:30'
      numberOfPassenger: '1'
      price: '13.93'
      passenger_1: '3'
    trip = Trip trip
    trip.getPricePerParty().should.eql '13.93'
    next()

  it 'Get price per party with 2 passengers and 2 parties', (next) ->
    trip =
      latStart: '48.856470'
      lonStart: '2.286001'
      latEnd: '48.865314'
      lonEnd: '2.321514'
      dateTime: '22-01-2015 16:30'
      numberOfPassenger: '2'
      price: '13.93'
      passenger_1: '3'
      passenger_2: '1'
    trip = Trip trip
    trip.getPricePerParty().should.eql (13.93/2/1.1).toFixed 2
    next()

  it 'Get price per party with 2 passengers and 1 party', (next) ->
    trip =
      latStart: '48.856470'
      lonStart: '2.286001'
      latEnd: '48.865314'
      lonEnd: '2.321514'
      dateTime: '22-01-2015 16:30'
      numberOfPassenger: '2'
      price: '13.93'
      passenger_1: '3'
      passenger_2: '3'
    trip = Trip trip
    trip.getPricePerParty().should.eql '13.93'
    next()

  it 'Get price per party with 3 passengers and 2 parties', (next) ->
    trip =
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
    trip = Trip trip
    trip.getPricePerParty().should.eql (13.93/2/1.1).toFixed 2
    next()

  it 'Get price per party with 4 passengers and 2 parties', (next) ->
    trip =
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
    trip = Trip trip
    trip.getPricePerParty().should.eql (13.93/2/1.1).toFixed 2
    next()

  it 'Get price per party with 4 passengers and 3 parties', (next) ->
    trip =
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
    trip = Trip trip
    trip.getPricePerParty().should.eql (13.93/3/1.1).toFixed 2
    next()

  it 'Get price per party with 4 passengers and 3 parties', (next) ->
    trip =
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
    trip = Trip trip
    trip.getPricePerParty().should.eql (13.93/3/1.1).toFixed 2
    next()

  it 'Get price per party with 4 passengers and 4 parties', (next) ->
    trip =
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
    trip = Trip trip
    trip.getPricePerParty().should.eql (13.93/4/1.1).toFixed 2
    next()

  it 'Get price per party plus one', (next) ->
    trip =
      latStart: '48.856470'
      lonStart: '2.286001'
      latEnd: '48.865314'
      lonEnd: '2.321514'
      dateTime: '22-01-2015 16:30'
      numberOfPassenger: '1'
      price: '13.93'
      passenger_1: '3'
    trip = Trip trip
    trip.getPricePerPartyPlusOne().should.eql (13.93/2/1.1).toFixed 2
    next()

  it 'Get private trip data', (next) ->
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
    trip = Trip data
    trip = trip.getPrivate()
    trip.id.should.eql data.id
    should.not.exists trip.addressStart
    trip.latStart.should.eql data.latStart
    trip.lonStart.should.eql data.lonStart
    should.not.exists trip.addressEnd
    trip.latEnd.should.eql data.latEnd
    trip.lonEnd.should.eql data.lonEnd
    trip.dateTime.should.eql data.dateTime
    should.not.exists trip.price
    trip.maxPrice.should.eql '13.93'
    trip.passenger_1.should.eql data.passenger_1
    should.not.exists trip.passenger_2
    should.not.exists trip.passenger_3
    should.not.exists trip.passenger_4
    next()

  it 'Get public trip data', (next) ->
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
    trip = Trip data
    trip = trip.getPublic()
    trip.id.should.eql data.id
    should.not.exists trip.addressStart
    trip.latStart.should.eql data.latStart
    trip.lonStart.should.eql data.lonStart
    should.not.exists trip.addressEnd
    trip.latEnd.should.eql data.latEnd
    trip.lonEnd.should.eql data.lonEnd
    trip.dateTime.should.eql data.dateTime
    should.not.exists trip.price
    trip.maxPrice.should.eql (13.93/2/1.1).toFixed 2
    should.not.exists trip.passenger_1
    should.not.exists trip.passenger_2
    should.not.exists trip.passenger_3
    should.not.exists trip.passenger_4
    next()
