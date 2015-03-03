should = require 'should'
TripCriteria = require '../tripCriteria'

describe 'Trip criteria entity', ->

  it 'Create trip criteria', (next) ->
    data =
      latStart: '48.853611'
      lonStart: '2.287546'
      latEnd: '48.860359'
      lonEnd: '2.352949'
      dateTime: '22-01-2015 16:30'
      numberOfPeople: '2'
    tripCriteria = TripCriteria data
    tripCriteria.latStart.should.eql data.latStart
    tripCriteria.lonStart.should.eql data.lonStart
    tripCriteria.latEnd.should.eql data.latEnd
    tripCriteria.lonEnd.should.eql data.lonEnd
    tripCriteria.dateTime.should.eql data.dateTime
    tripCriteria.numberOfPeople.should.eql data.numberOfPeople
    next()

  it 'Get tripCriteria', (next) ->
    data =
      latStart: '48.853611'
      lonStart: '2.287546'
      latEnd: '48.860359'
      lonEnd: '2.352949'
      dateTime: '22-01-2015 16:30'
      numberOfPeople: '2'
    tripCriteria = TripCriteria data
    tripCriteria = tripCriteria.get()
    tripCriteria.latStart.should.eql data.latStart
    tripCriteria.lonStart.should.eql data.lonStart
    tripCriteria.latEnd.should.eql data.latEnd
    tripCriteria.lonEnd.should.eql data.lonEnd
    tripCriteria.dateTime.should.eql data.dateTime
    tripCriteria.numberOfPeople.should.eql data.numberOfPeople
    next()

  it 'Trip criteria toString', (next) ->
    data =
      latStart: '48.853611'
      lonStart: '2.287546'
      latEnd: '48.860359'
      lonEnd: '2.352949'
      dateTime: '22-01-2015 16:30'
      numberOfPeople: '2'
    tripCriteria = TripCriteria data
    string = tripCriteria.toString()
    string.should.eql "Trip criteria latStart:48.853611 lonStart:2.287546 latEnd:48.860359 lonEnd:2.352949 dateTime:22-01-2015 16:30 numberOfPeople:2"
    next()
