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
      login = 'dorian@ethylocle.com'
      password = '1234'
      client.users.get login, (err, user) ->
        return next err if err
        assertion = user.username is login and user.password is password
        if assertion
          assertion.should.eql true
          client.close()
          next()
        else
          assertion.should.eql false
          client.users.getByEmail login, (err, userByEmail) ->
            return next err if err
            client.users.get userByEmail.username, (err, user) ->
              return next err if err
              assertion = user.email is login and user.password is password
              assertion.should.eql true
              client.close()
              next()
    .pipe importStream client, format: 'csv', objectMode: true

  it 'Import sample.json', (next) ->
    client = db "#{__dirname}/../db/tmp"
    fs
    .createReadStream "#{__dirname}/../sample.json"
    .on 'end', () ->
      console.log "End"
      login = 'dorian@ethylocle.com'
      password = '1234'
      client.users.get login, (err, user) ->
        return next err if err
        assertion = user.username is login and user.password is password
        if assertion
          assertion.should.eql true
          client.close()
          next()
        else
          assertion.should.eql false
          client.users.getByEmail login, (err, userByEmail) ->
            return next err if err
            client.users.get userByEmail.username, (err, user) ->
              return next err if err
              assertion = user.email is login and user.password is password
              assertion.should.eql true
              client.close()
              next()
    .pipe importStream client, format: 'json', objectMode: true
