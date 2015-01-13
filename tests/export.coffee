rimraf = require 'rimraf'
should = require 'should'
fs = require 'fs'
exportStream = require '../lib/export'
db = require '../lib/db'

###describe 'export', ->

  beforeEach (next) ->
    rimraf "#{__dirname}/../db/tmp", next

  it 'Export to sample.csv', (next) ->
    client = db "#{__dirname}/../db/tmp"
    client.users.set 'dorianb',
      lastname: 'Bagur'
      firstname: 'Dorian'
      password: '1234'
      email: 'alfred@ethylocle.com'
    , (err) ->
      return next err if err
      client.users.setByEmail 'alfred@ethylocle.com',
        username: 'dorianb'
      , (err) ->
        return next err if err
        client.users.set 'maoqiaoz',
          lastname: 'Zhou'
          firstname: 'Maoqiao'
          password: '4321'
          email: 'gilbert@ethylocle.com'
        , (err) ->
          return next err if err
          client.users.setByEmail 'gilbert@ethylocle.com',
            username: 'maoqiaoz'
          , (err) ->
            return next err if err
            exportStream client, format: 'csv', objectMode: true
            .on 'end', () ->
              client.close()
              next()
            .pipe fs.createWriteStream "#{__dirname}/../exportation.csv"

  it 'Export to sample.json', (next) ->
    client = db "#{__dirname}/../db/tmp"
    fs
    .createReadStream "#{__dirname}/../sample.json"
    .on 'end', () ->
      client.users.get 'dorianb', (err, user) ->
        return next err if err
        user.username.should.eql 'dorianb'
        user.lastname.should.eql 'Bagur'
        user.firstname.should.eql 'Dorian'
        user.email.should.eql 'dorian@ethylocle.com'
        user.password.should.eql '1234'
        client.users.get 'maoqiaoz', (err, user) ->
          return next err if err
          user.username.should.eql 'maoqiaoz'
          user.lastname.should.eql 'Zhou'
          user.firstname.should.eql 'Maoqiao'
          user.email.should.eql 'maoqiao@ethylocle.com'
          user.password.should.eql '1234'
          client.close()
          next()
    .pipe importStream client, format: 'json'
    next()###
