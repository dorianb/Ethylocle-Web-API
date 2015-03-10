###rimraf = require 'rimraf'
should = require 'should'
fs = require 'fs'
importStream = require '../import'
db = require '../../factory/model'

describe 'Import', ->

  beforeEach (next) ->
    rimraf "#{__dirname}/../../../db/tmp/user", ->
      rimraf "#{__dirname}/../../../db/tmp/stop", next

  it 'Import users from csv', (next) ->
    client = db "#{__dirname}/../../../db/tmp/user"
    fs
    .createReadStream "#{__dirname}/../../../resource/user sample.csv"
    .pipe importStream client, 'csv', 'user'
    .on 'finish', ->
      this.iterator.should.eql 3
      client.users.getByEmail "dorian@ethylocle.com", (err, user) ->
        return next err if err
        client.users.get user.id, (err, user) ->
          return next err if err
          user.email.should.eql "dorian@ethylocle.com"
          user.picture.should.eql "null"
          user.lastname.should.eql "Bagur"
          user.firstname.should.eql "Dorian"
          user.birthDate.should.eql "07-08-1992"
          user.gender.should.eql "M"
          user.weight.should.eql "75.5"
          user.address.should.eql "162 Boulevard du Général de Gaulle"
          user.zipCode.should.eql "78700"
          user.city.should.eql "Conflans-Sainte-Honorine"
          user.country.should.eql "France"
          user.phone.should.eql "+330619768399"
          user.password.should.eql "1234"
          user.latitude.should.eql "48.888"
          user.longitude.should.eql "70.55"
          user.lastKnownPositionDate.should.eql "15-01-2015 15:05:30"
          user.bac.should.eql "0.56"
          user.lastBacKnownDate.should.eql "15-01-2015 15:05:30"
          client.users.getByEmail "maoqiao@ethylocle.com", (err, user) ->
            return next err if err
            client.users.get user.id, (err, user) ->
              return next err if err
              user.email.should.eql "maoqiao@ethylocle.com"
              user.picture.should.eql "null"
              user.lastname.should.eql "Zhou"
              user.firstname.should.eql "Maoqiao"
              user.birthDate.should.eql "07-08-1992"
              user.gender.should.eql "M"
              user.weight.should.eql "75.5"
              user.address.should.eql "null"
              user.zipCode.should.eql "75000"
              user.city.should.eql "Paris"
              user.country.should.eql "France"
              user.phone.should.eql "+330619768399"
              user.password.should.eql "1234"
              user.latitude.should.eql "48.888"
              user.longitude.should.eql "70.55"
              user.lastKnownPositionDate.should.eql "15-01-2015 15:05:30"
              user.bac.should.eql "0.56"
              user.lastBacKnownDate.should.eql "15-01-2015 15:05:30"
              client.users.getByEmail "robin@ethylocle.com", (err, user) ->
                return next err if err
                client.users.get user.id, (err, user) ->
                  return next err if err
                  user.email.should.eql "robin@ethylocle.com"
                  user.picture.should.eql "null"
                  user.lastname.should.eql "Biondi"
                  user.firstname.should.eql "Robin"
                  user.birthDate.should.eql "07-08-1992"
                  user.gender.should.eql "M"
                  user.weight.should.eql "75.5"
                  user.address.should.eql "null"
                  user.zipCode.should.eql "75000"
                  user.city.should.eql "Paris"
                  user.country.should.eql "France"
                  user.phone.should.eql "+330619768399"
                  user.password.should.eql "1234"
                  user.latitude.should.eql "48.888"
                  user.longitude.should.eql "70.55"
                  user.lastKnownPositionDate.should.eql "15-01-2015 15:05:30"
                  user.bac.should.eql "0.56"
                  user.lastBacKnownDate.should.eql "15-01-2015 15:05:30"
                  client.close()
                  next()

  it 'Import users from json', (next) ->
    client = db "#{__dirname}/../../../db/tmp/user"
    fs
    .createReadStream "#{__dirname}/../../../resource/user sample.json"
    .pipe importStream client, 'json', 'user'
    .on 'finish', ->
      this.iterator.should.eql 3
      client.users.getByEmail "dorian@ethylocle.com", (err, user) ->
        return next err if err
        client.users.get user.id, (err, user) ->
          return next err if err
          user.email.should.eql "dorian@ethylocle.com"
          user.picture.should.eql "null"
          user.lastname.should.eql "Bagur"
          user.firstname.should.eql "Dorian"
          user.birthDate.should.eql "07-08-1992"
          user.gender.should.eql "M"
          user.weight.should.eql "75.5"
          user.address.should.eql "162 Boulevard du Général de Gaulle"
          user.zipCode.should.eql "78700"
          user.city.should.eql "Conflans-Sainte-Honorine"
          user.country.should.eql "France"
          user.phone.should.eql "+330619768399"
          user.password.should.eql "1234"
          user.latitude.should.eql "48.888"
          user.longitude.should.eql "70.55"
          user.lastKnownPositionDate.should.eql "15-01-2015 15:05:30"
          user.bac.should.eql "0.56"
          user.lastBacKnownDate.should.eql "15-01-2015 15:05:30"
          client.users.getByEmail "maoqiao@ethylocle.com", (err, user) ->
            return next err if err
            client.users.get user.id, (err, user) ->
              return next err if err
              user.email.should.eql "maoqiao@ethylocle.com"
              user.picture.should.eql "null"
              user.lastname.should.eql "Zhou"
              user.firstname.should.eql "Maoqiao"
              user.birthDate.should.eql "07-08-1992"
              user.gender.should.eql "M"
              user.weight.should.eql "75.5"
              user.address.should.eql "null"
              user.zipCode.should.eql "75000"
              user.city.should.eql "Paris"
              user.country.should.eql "France"
              user.phone.should.eql "+330619768399"
              user.password.should.eql "1234"
              user.latitude.should.eql "48.888"
              user.longitude.should.eql "70.55"
              user.lastKnownPositionDate.should.eql "15-01-2015 15:05:30"
              user.bac.should.eql "0.56"
              user.lastBacKnownDate.should.eql "15-01-2015 15:05:30"
              client.users.getByEmail "robin@ethylocle.com", (err, user) ->
                return next err if err
                client.users.get user.id, (err, user) ->
                  return next err if err
                  user.email.should.eql "robin@ethylocle.com"
                  user.picture.should.eql "null"
                  user.lastname.should.eql "Biondi"
                  user.firstname.should.eql "Robin"
                  user.birthDate.should.eql "07-08-1992"
                  user.gender.should.eql "M"
                  user.weight.should.eql "75.5"
                  user.address.should.eql "null"
                  user.zipCode.should.eql "75000"
                  user.city.should.eql "Paris"
                  user.country.should.eql "France"
                  user.phone.should.eql "+330619768399"
                  user.password.should.eql "1234"
                  user.latitude.should.eql "48.888"
                  user.longitude.should.eql "70.55"
                  user.lastKnownPositionDate.should.eql "15-01-2015 15:05:30"
                  user.bac.should.eql "0.56"
                  user.lastBacKnownDate.should.eql "15-01-2015 15:05:30"
                  client.close()
                  next()

  it 'Import stops from csv', (next) ->
    this.timeout 10000
    client = db "#{__dirname}/../../../db/tmp/stop"
    fs
    .createReadStream "#{__dirname}/../../../resource/ratp_stops_with_routes.csv"
    .pipe importStream client, 'csv', 'stop'
    .on 'finish', ->
      this.iterator.should.eql 26621
      client.stops.get '4035172', (err, stop) ->
        return next err if err
        stop.stop_name.should.eql 'REPUBLIQUE - DEFORGES'
        stop.stop_desc.should.eql 'FACE 91 AVENUE DE LA REPUBLIQUE - 92020'
        stop.stop_lat.should.eql '48.80383802353411'
        stop.stop_lon.should.eql '2.2978373453843948'
        stop.line_type.should.eql 'BUS'
        stop.line_name.should.eql 'BUS N63'
        client.stops.get '1724', (err, stop) ->
          return next err if err
          stop.stop_name.should.eql 'Saint-Lazare'
          stop.stop_desc.should.eql 'Saint-Lazare (97 rue) - 75108'
          stop.stop_lat.should.eql '48.876067814352574'
          stop.stop_lon.should.eql '2.324188100771013'
          stop.line_type.should.eql 'M;M'
          stop.line_name.should.eql 'M 13;M 13'
          client.stops.get '3663555', (err, stop) ->
            return next err if err
            stop.stop_name.should.eql '8 MAI 1945'
            stop.stop_desc.should.eql '7 RUE DES MARTYRS DE LA DEPORTATION - 93007'
            stop.stop_lat.should.eql '48.94760765462246'
            stop.stop_lon.should.eql '2.438002324652052'
            stop.line_type.should.eql 'BUS'
            stop.line_name.should.eql 'BUS 148'
            client.stops.get '4035339', (err, stop) ->
              return next err if err
              stop.stop_name.should.eql "VAL D'OR"
              stop.stop_desc.should.eql '20 BOULEVARD LOUIS LOUCHEUR - 92073'
              stop.stop_lat.should.eql '48.860042582683505'
              stop.stop_lon.should.eql '2.2133715937731506'
              stop.line_type.should.eql 'BUS'
              stop.line_name.should.eql 'BUS N53'
              client.close()
              next()###
