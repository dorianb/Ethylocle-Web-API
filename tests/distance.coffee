should = require 'should'
db = require '../lib/db'
fs = require 'fs'
importStream = require '../lib/import'

describe 'Distance', ->

  before (next) ->
    this.timeout 10000
    client = db "#{__dirname}/../db/tmp"
    fs
    .createReadStream "#{__dirname}/../ratp_stops_with_routes.csv"
    .on 'end', () ->
      console.log 'Import finished'
      client.close()
      next()
    .pipe importStream client, 'csv', 'stops', objectMode: true

  it 'Get stops by line type', (next) ->
    client = db "#{__dirname}/../db/tmp"
    client.stops.getByLineType 'BUS', (err, stops) ->
      return next err if err
      console.log stops.length
      client.close()
      next()

      ###client.stops.get stops[0].id, (err, stop) ->
        return next err if err
        stop.name.should.eql 'REPUBLIQUE - DEFORGES'
        stop.desc.should.eql 'FACE 91 AVENUE DE LA REPUBLIQUE - 92020'
        stop.lat.should.eql '48.80383802353411'
        stop.lon.should.eql '2.2978373453843948'
        stop.lineType.should.eql 'BUS'
        stop.lineName.should.eql 'BUS N63'
        client.stops.get stops[1].id, (err, stop) ->
          return next err if err
          stop.name.should.eql 'CHATILLON - MONTROUGE-METRO'
          stop.desc.should.eql 'PISTE GARE ROUTIERE - 92020'
          stop.lat.should.eql '48.81008571048087'
          stop.lon.should.eql '2.301547557964941'
          stop.lineType.should.eql 'BUS'
          stop.lineName.should.eql 'BUS N63'
          client.close()
          next()###
