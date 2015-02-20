should = require 'should'
Stop = require '../stop'

describe 'Stop entity', ->

  it 'Create stop', (next) ->
    data =
      id: '0'
      lat: '48.853611'
      lon: '2.287546'
      desc: 'En face du Mac Do'
      name: 'Saint-Lazare'
      lineType: 'BUS'
      lineName: 'BUS 231'
    stop = new Stop data
    stop.id.should.eql data.id
    stop.lat.should.eql data.lat
    stop.lon.should.eql data.lon
    stop.desc.should.eql data.desc
    stop.name.should.eql data.name
    stop.lineType.should.eql data.lineType
    stop.lineName.should.eql data.lineName
    next()

  it 'Get stop', (next) ->
    data =
      id: '0'
      lat: '48.853611'
      lon: '2.287546'
      desc: 'En face du Mac Do'
      name: 'Saint-Lazare'
      lineType: 'BUS'
      lineName: 'BUS 231'
    stop = new Stop data
    stop = stop.get()
    stop.id.should.eql data.id
    stop.lat.should.eql data.lat
    stop.lon.should.eql data.lon
    stop.desc.should.eql data.desc
    stop.name.should.eql data.name
    stop.lineType.should.eql data.lineType
    stop.lineName.should.eql data.lineName
    next()

  it 'Stop toString', (next) ->
    data =
      id: '0'
      lat: '48.853611'
      lon: '2.287546'
    stop = Stop data
    string = stop.toString()
    string.should.eql "Stop id:0 lat:48.853611 lon:2.287546"
    next()
