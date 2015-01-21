should = require 'should'
db = require '../lib/db'
fs = require 'fs'
importStream = require '../lib/import'

client = undefined

describe 'Distance', ->

  before (next) ->
    this.timeout 10000
    client = db "#{__dirname}/../db/tmp"
    fs
    .createReadStream "#{__dirname}/../ratp_stops_with_routes.csv"
    .on 'end', () ->
      #console.log 'Import finished'
      next()
    .pipe importStream client, 'csv', 'stops', objectMode: true

  describe 'After importing stops', ->

    it 'Get the 10th closest stops', (next) ->
      client.stops.getByLineType 'RER', (err, stops) ->
        return next err if err
        console.log stops.length
        #48.853661, 2.288933
        logStop = (i) ->
          if i < stops.length
            client.stops.get stops[i].id, (err, stop) ->
              return next err if err
              ###console.log stop.id
              console.log stop.name
              console.log stop.desc
              console.log stop.lat
              console.log stop.lon
              console.log stop.lineType
              console.log stop.lineName###
              logStop i+1
          else
            client.close()
            next()

        logStop 0
