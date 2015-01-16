rimraf = require 'rimraf'
should = require 'should'
fs = require 'fs'
importStream = require '../lib/import'
db = require '../lib/db'

describe 'import', ->

  beforeEach (next) ->
    rimraf "#{__dirname}/../db/tmp", next

  it 'Import sample.csv', (next) ->
    client = db "#{__dirname}/../db/tmp"
    fs
    .createReadStream "#{__dirname}/../sample.csv"
    .on 'end', () ->
      console.log "End"
      client.users.get "dorian@ethylocle.com", (err, user) ->
        return next err if err
        user.email.should.eql "dorian@ethylocle.com"
        user.picture.should.eql "null"
        user.lastname.should.eql "Bagur"
        user.firstname.should.eql "Dorian"
        user.birthDate.should.eql "22"
        user.gender.should.eql "M"
        user.weight.should.eql "75.5"
        user.address.should.eql "162 Boulevard du Général de Gaulle"
        user.zipCode.should.eql "78700"
        user.city.should.eql "Conflans-Sainte-Honorine"
        user.country.should.eql "France"
        user.phone.should.eql "+330619768399"
        user.vehicul.should.eql "Renault mégane"
        user.password.should.eql "1234"
        user.latitude.should.eql "48.888"
        user.longitude.should.eql "70.55"
        user.lastKnownPositionDate.should.eql "15-01-2015 15:05:30"
        user.bac.should.eql "0.56"
        user.lastBacKnownDate.should.eql "15-01-2015 15:05:30"
        client.users.get "maoqiao@ethylocle.com", (err, user) ->
          return next err if err
          user.email.should.eql "maoqiao@ethylocle.com"
          user.picture.should.eql "null"
          user.lastname.should.eql "Zhou"
          user.firstname.should.eql "Maoqiao"
          user.birthDate.should.eql "22"
          user.gender.should.eql "M"
          user.weight.should.eql "75.5"
          user.address.should.eql "null"
          user.zipCode.should.eql "75000"
          user.city.should.eql "Paris"
          user.country.should.eql "France"
          user.phone.should.eql "+330619768399"
          user.vehicul.should.eql "Toyota Prius"
          user.password.should.eql "1234"
          user.latitude.should.eql "48.888"
          user.longitude.should.eql "70.55"
          user.lastKnownPositionDate.should.eql "15-01-2015 15:05:30"
          user.bac.should.eql "0.56"
          user.lastBacKnownDate.should.eql "15-01-2015 15:05:30"
          client.users.get "robin@ethylocle.com", (err, user) ->
            return next err if err
            user.email.should.eql "robin@ethylocle.com"
            user.picture.should.eql "null"
            user.lastname.should.eql "Biondi"
            user.firstname.should.eql "Robin"
            user.birthDate.should.eql "22"
            user.gender.should.eql "M"
            user.weight.should.eql "75.5"
            user.address.should.eql "null"
            user.zipCode.should.eql "75000"
            user.city.should.eql "Paris"
            user.country.should.eql "France"
            user.phone.should.eql "+330619768399"
            user.vehicul.should.eql "Audi R8"
            user.password.should.eql "1234"
            user.latitude.should.eql "48.888"
            user.longitude.should.eql "70.55"
            user.lastKnownPositionDate.should.eql "15-01-2015 15:05:30"
            user.bac.should.eql "0.56"
            user.lastBacKnownDate.should.eql "15-01-2015 15:05:30"
            client.close()
            next()
    .pipe importStream client, format: 'csv', objectMode: true

  it 'Import sample.json', (next) ->
    client = db "#{__dirname}/../db/tmp"
    fs
    .createReadStream "#{__dirname}/../sample.json"
    .on 'end', () ->
      console.log "End"
      client.users.get "dorian@ethylocle.com", (err, user) ->
        return next err if err
        user.email.should.eql "dorian@ethylocle.com"
        user.picture.should.eql "null"
        user.lastname.should.eql "Bagur"
        user.firstname.should.eql "Dorian"
        user.birthDate.should.eql "22"
        user.gender.should.eql "M"
        user.weight.should.eql "75.5"
        user.address.should.eql "162 Boulevard du Général de Gaulle"
        user.zipCode.should.eql "78700"
        user.city.should.eql "Conflans-Sainte-Honorine"
        user.country.should.eql "France"
        user.phone.should.eql "+330619768399"
        user.vehicul.should.eql "Renault mégane"
        user.password.should.eql "1234"
        user.latitude.should.eql "48.888"
        user.longitude.should.eql "70.55"
        user.lastKnownPositionDate.should.eql "15-01-2015 15:05:30"
        user.bac.should.eql "0.56"
        user.lastBacKnownDate.should.eql "15-01-2015 15:05:30"
        client.users.get "maoqiao@ethylocle.com", (err, user) ->
          return next err if err
          user.email.should.eql "maoqiao@ethylocle.com"
          user.picture.should.eql "null"
          user.lastname.should.eql "Zhou"
          user.firstname.should.eql "Maoqiao"
          user.birthDate.should.eql "22"
          user.gender.should.eql "M"
          user.weight.should.eql "75.5"
          user.address.should.eql "null"
          user.zipCode.should.eql "75000"
          user.city.should.eql "Paris"
          user.country.should.eql "France"
          user.phone.should.eql "+330619768399"
          user.vehicul.should.eql "Toyota Prius"
          user.password.should.eql "1234"
          user.latitude.should.eql "48.888"
          user.longitude.should.eql "70.55"
          user.lastKnownPositionDate.should.eql "15-01-2015 15:05:30"
          user.bac.should.eql "0.56"
          user.lastBacKnownDate.should.eql "15-01-2015 15:05:30"
          client.users.get "robin@ethylocle.com", (err, user) ->
            return next err if err
            user.email.should.eql "robin@ethylocle.com"
            user.picture.should.eql "null"
            user.lastname.should.eql "Biondi"
            user.firstname.should.eql "Robin"
            user.birthDate.should.eql "22"
            user.gender.should.eql "M"
            user.weight.should.eql "75.5"
            user.address.should.eql "null"
            user.zipCode.should.eql "75000"
            user.city.should.eql "Paris"
            user.country.should.eql "France"
            user.phone.should.eql "+330619768399"
            user.vehicul.should.eql "Audi R8"
            user.password.should.eql "1234"
            user.latitude.should.eql "48.888"
            user.longitude.should.eql "70.55"
            user.lastKnownPositionDate.should.eql "15-01-2015 15:05:30"
            user.bac.should.eql "0.56"
            user.lastBacKnownDate.should.eql "15-01-2015 15:05:30"
            client.close()
            next()
    .pipe importStream client, format: 'json', objectMode: true
