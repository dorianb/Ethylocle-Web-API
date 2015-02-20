rimraf = require 'rimraf'
should = require 'should'
db = require '../../lib/factory/model'
fs = require 'fs'
importStream = require '../../lib/tool/import'

client = undefined

describe 'Stop', ->

  beforeEach (next) ->
    rimraf "#{__dirname}/../../db/tmp/stop", next

  it 'Insert and get a stop', (next) ->
    client = db "#{__dirname}/../../db/tmp/stop"
    client.stops.set '4035172',
      name: 'REPUBLIQUE - DEFORGES'
      desc: 'FACE 91 AVENUE DE LA REPUBLIQUE - 92020'
      lat: '48.80383802353411'
      lon: '2.2978373453843948'
      lineType: 'BUS'
      lineName: 'BUS N63'
    , (err) ->
      return next err if err
      client.stops.get '4035172', (err, stop) ->
        return next err if err
        stop.name.should.eql 'REPUBLIQUE - DEFORGES'
        stop.desc.should.eql 'FACE 91 AVENUE DE LA REPUBLIQUE - 92020'
        stop.lat.should.eql '48.80383802353411'
        stop.lon.should.eql '2.2978373453843948'
        stop.lineType.should.eql 'BUS'
        stop.lineName.should.eql 'BUS N63'
        client.close()
        next()

  it 'Insert and get a single stop', (next) ->
    client = db "#{__dirname}/../../db/tmp/stop"
    client.stops.set '4035172',
      name: 'REPUBLIQUE - DEFORGES'
      desc: 'FACE 91 AVENUE DE LA REPUBLIQUE - 92020'
      lat: '48.80383802353411'
      lon: '2.2978373453843948'
      lineType: 'BUS'
      lineName: 'BUS N63'
    , (err) ->
      return next err if err
      client.stops.set '1832',
        name: 'Nation'
        desc: 'Nation (terre-plein face au 3 place de la) - 75112'
        lat: '48.84811123157566'
        lon: '2.3980040127977436'
        lineType: 'M'
        lineName: 'M 1'
      , (err) ->
        return next err if err
        client.stops.get '4035172', (err, stop) ->
          return next err if err
          stop.name.should.eql 'REPUBLIQUE - DEFORGES'
          stop.desc.should.eql 'FACE 91 AVENUE DE LA REPUBLIQUE - 92020'
          stop.lat.should.eql '48.80383802353411'
          stop.lon.should.eql '2.2978373453843948'
          stop.lineType.should.eql 'BUS'
          stop.lineName.should.eql 'BUS N63'
          client.close()
          next()

  it 'Insert and get a stop by line type', (next) ->
    client = db "#{__dirname}/../../db/tmp/stop"
    client.stops.set '4035172',
      name: 'REPUBLIQUE - DEFORGES'
      desc: 'FACE 91 AVENUE DE LA REPUBLIQUE - 92020'
      lat: '48.80383802353411'
      lon: '2.2978373453843948'
      lineType: 'BUS'
      lineName: 'BUS N63'
    , (err) ->
      return next err if err
      client.stops.setByLineType 'BUS', '4035172', (err) ->
        return next err if err
        client.stops.getByLineType 'BUS', (err, stops) ->
          return next err if err
          for k, v of stops
            stops[k].id.should.eql '4035172'
            stops[k].lineType.should.eql 'BUS'
            client.stops.get '4035172', (err, stop) ->
              return next err if err
              stop.name.should.eql 'REPUBLIQUE - DEFORGES'
              stop.desc.should.eql 'FACE 91 AVENUE DE LA REPUBLIQUE - 92020'
              stop.lat.should.eql '48.80383802353411'
              stop.lon.should.eql '2.2978373453843948'
              stop.lineType.should.eql 'BUS'
              stop.lineName.should.eql 'BUS N63'
              client.close()
              next()

  it 'Insert and get stops by line type', (next) ->
    client = db "#{__dirname}/../../db/tmp/stop"
    client.stops.set '4035172',
      name: 'REPUBLIQUE - DEFORGES'
      desc: 'FACE 91 AVENUE DE LA REPUBLIQUE - 92020'
      lat: '48.80383802353411'
      lon: '2.2978373453843948'
      lineType: 'BUS'
      lineName: 'BUS N63'
    , (err) ->
      return next err if err
      client.stops.setByLineType 'BUS', '4035172', (err) ->
        return next err if err
        client.stops.set '1832',
          name: 'Nation'
          desc: 'Nation (terre-plein face au 3 place de la) - 75112'
          lat: '48.84811123157566'
          lon: '2.3980040127977436'
          lineType: 'M'
          lineName: 'M 1'
        , (err) ->
          return next err if err
          client.stops.setByLineType 'M', '1832', (err) ->
            return next err if err
            client.stops.set '4035207',
              name: 'CHATILLON - MONTROUGE-METRO'
              desc: 'PISTE GARE ROUTIERE - 92020'
              lat: '48.81008571048087'
              lon: '2.301547557964941'
              lineType: 'BUS'
              lineName: 'BUS N63'
            , (err) ->
              return next err if err
              client.stops.setByLineType 'BUS', '4035207', (err) ->
                return next err if err
                client.stops.getByLineType 'BUS', (err, stops) ->
                  return next err if err
                  stops[0].id.should.eql '4035172'
                  stops[0].lineType.should.eql 'BUS'
                  stops[1].id.should.eql '4035207'
                  stops[1].lineType.should.eql 'BUS'
                  should.not.exists stops[2]
                  client.stops.get stops[0].id, (err, stop) ->
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
                      next()

###describe 'Find nearest stop test', ->

  before (next) ->
    this.timeout 10000
    client = db "#{__dirname}/../../db/tmp/stop"
    fs
    .createReadStream "#{__dirname}/../../ratp_stops_with_routes.csv"
    .on 'end', () ->
      #console.log 'Import finished'
      next()
    .pipe importStream client, 'csv', 'stops', objectMode: true

  describe 'Stops imported', ->
    it 'Get the 10th closest stops', (next) ->
      client.stops.getByLineType 'RER', (err, stops) ->
        return next err if err
        #console.log stops.length
        #48.853661, 2.288933
        logStop = (i) ->
          if i < stops.length
            client.stops.get stops[i].id, (err, stop) ->
              return next err if err
              console.log stop.id
              console.log stop.name
              console.log stop.desc
              console.log stop.lat
              console.log stop.lon
              console.log stop.lineType
              console.log stop.lineName
              logStop i+1
          else
            client.close()
            next()

        logStop 0###
