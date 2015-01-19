rimraf = require 'rimraf'
should = require 'should'
fs = require 'fs'
exportStream = require '../lib/export'
db = require '../lib/db'

describe 'export', ->

  beforeEach (next) ->
    rimraf "#{__dirname}/../db/tmp", next

  it 'Export users to csv', (next) ->
    client = db "#{__dirname}/../db/tmp"
    client.users.set 'dorian@ethylocle.com',
      lastname: 'Bagur'
      firstname: 'Dorian'
      password: '1234'
    , (err) ->
        return next err if err
        client.users.set 'maoqiao@ethylocle.com',
          lastname: 'Zhou'
          firstname: 'Maoqiao'
          password: '1234'
        , (err) ->
            return next err if err
            client.users.set 'robin@ethylocle.com',
              lastname: 'Biondi'
              firstname: 'Robin'
              password: '1234'
            , (err) ->
                return next err if err
                client.close()
                exportStream "#{__dirname}/../db/tmp", 'csv', objectMode: true
                .on 'end', () ->
                  next()
                .pipe fs.createWriteStream "#{__dirname}/../users.csv"
