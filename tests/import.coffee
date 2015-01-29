rimraf = require 'rimraf'
should = require 'should'
fs = require 'fs'
importStream = require '../lib/import'
db = require '../lib/db'

describe 'import', ->

  beforeEach (next) ->
    rimraf "#{__dirname}/../db/tmp", next

  it 'Import users from csv', (next) ->
    client = db "#{__dirname}/../db/tmp/user"
    fs
    .createReadStream "#{__dirname}/../user sample.csv"
    .on 'end', ->
      #console.log "End"
      #client.close()
      next()
      ###client.users.getByEmail "dorian@ethylocle.com", (err, user) ->
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
                  next()###
    .pipe importStream client, 'csv', 'user', objectMode: true

  it 'Import users from json', (next) ->
    client = db "#{__dirname}/../db/tmp/user"
    fs
    .createReadStream "#{__dirname}/../user sample.json"
    .on 'end', ->
      #console.log "End"
      #client.close()
      next()
      ###client.users.getByEmail "dorian@ethylocle.com", (err, user) ->
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
                  next()###
    .pipe importStream client, 'json', 'user', objectMode: true

  ###it 'Import stops from csv', (next) ->
    this.timeout 10000
    client = db "#{__dirname}/../db/tmp/user"
    fs
    .createReadStream "#{__dirname}/../ratp_stops_with_routes.csv"
    .on 'end', () ->
      console.log "End"
      client.close()
      next()
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
    .pipe importStream client, 'csv', 'stop', objectMode: true###
