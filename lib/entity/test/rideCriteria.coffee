should = require 'should'
RideCriteria = require '../rideCriteria'

describe 'Ride criteria entity', ->

  it 'Create ride criteria', (next) ->
    data =
      latStart: '48.853611'
      lonStart: '2.287546'
      latEnd: '48.860359'
      lonEnd: '2.352949'
      dateTime: '22-01-2015 16:30'
      numberOfPeople: '2'
    rideCriteria = RideCriteria data
    rideCriteria.latStart.should.eql data.latStart
    rideCriteria.lonStart.should.eql data.lonStart
    rideCriteria.latEnd.should.eql data.latEnd
    rideCriteria.lonEnd.should.eql data.lonEnd
    rideCriteria.dateTime.should.eql data.dateTime
    rideCriteria.numberOfPeople.should.eql data.numberOfPeople
    next()

  it 'Get rideCriteria', (next) ->
    data =
      latStart: '48.853611'
      lonStart: '2.287546'
      latEnd: '48.860359'
      lonEnd: '2.352949'
      dateTime: '22-01-2015 16:30'
      numberOfPeople: '2'
    rideCriteria = RideCriteria data
    rideCriteria = rideCriteria.get()
    rideCriteria.latStart.should.eql data.latStart
    rideCriteria.lonStart.should.eql data.lonStart
    rideCriteria.latEnd.should.eql data.latEnd
    rideCriteria.lonEnd.should.eql data.lonEnd
    rideCriteria.dateTime.should.eql data.dateTime
    rideCriteria.numberOfPeople.should.eql data.numberOfPeople
    next()

  it 'Ride criteria toString', (next) ->
    data =
      latStart: '48.853611'
      lonStart: '2.287546'
      latEnd: '48.860359'
      lonEnd: '2.352949'
      dateTime: '22-01-2015 16:30'
      numberOfPeople: '2'
    rideCriteria = RideCriteria data
    string = rideCriteria.toString()
    string.should.eql "Ride criteria latStart:48.853611 lonStart:2.287546 latEnd:48.860359 lonEnd:2.352949 dateTime:22-01-2015 16:30 numberOfPeople:2"
    next()
