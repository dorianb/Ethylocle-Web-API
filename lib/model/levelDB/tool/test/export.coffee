rimraf = require 'rimraf'
should = require 'should'
fs = require 'fs'
exportStream = require '../export'
importStream = require '../import'
Down = require '../../down'
level = require 'level'

describe 'Export', ->

  beforeEach (next) ->
    rimraf "#{__dirname}/../../../../../db/tmp/user", ->
      rimraf "#{__dirname}/../../../../../db/tmp/stop", next

  it 'Export users to csv', (next) ->
    user1 =
      email: 'dorian@ethylocle.com'
      lastname: 'Bagur'
      firstname: 'Dorian'
      password: '1234'
    user2 =
      email: 'maoqiao@ethylocle.com'
      lastname: 'Zhou'
      firstname: 'Maoqiao'
      password: '1234'
    user3 =
      email: 'robin@ethylocle.com'
      lastname: 'Biondi'
      firstname: 'Robin'
      password: '1234'
    client = Down "#{__dirname}/../../../../../db/tmp/user"
    client.users.getMaxId (err, maxId) ->
      return next err if err
      user1.id = ++maxId
      client.users.set user1.id, user1, (err) ->
        return next err if err
        client.users.setByEmail user1.email, user1, (err) ->
          return next err if err
          client.users.getMaxId (err, maxId) ->
            return next err if err
            user2.id = ++maxId
            client.users.set user2.id, user2, (err) ->
              return next err if err
              client.users.setByEmail user2.email, user2, (err) ->
                return next err if err
                client.users.getMaxId (err, maxId) ->
                  return next err if err
                  user3.id = ++maxId
                  client.users.set user3.id, user3, (err) ->
                    return next err if err
                    client.users.setByEmail user3.email, user3, (err) ->
                      return next err if err
                      client.close ->
                        client = level "#{__dirname}/../../../../../db/tmp/user"
                        client.createReadStream
                          gte: "users:"
                          lte: "users:\xff"
                        .pipe exportStream 'csv', objectMode: true
                        .on 'finish', () ->
                          this.iterator.should.eql 4
                        .pipe fs.createWriteStream "#{__dirname}/../../../../../resource/users.csv"
                        .on 'finish', () ->
                          client.close()
                          next()

  it 'Export stops to csv', (next) ->
    this.timeout 20000
    client = Down "#{__dirname}/../../../../../db/tmp/stop"
    fs
    .createReadStream "#{__dirname}/../../../../../resource/ratp_stops_with_routes.csv"
    .pipe importStream client, 'csv', 'stop'
    .on 'finish', ->
      this.iterator.should.eql 26621
      client.close ->
        db = level "#{__dirname}/../../../../../db/tmp/stop"
        db.createReadStream
          gte: "stops:"
          lte: "stops:\xff"
        .pipe exportStream 'csv', objectMode: true
        .on 'finish', () ->
          this.iterator.should.eql 26622
        .pipe fs.createWriteStream "#{__dirname}/../../../../../resource/stops.csv"
        .on 'finish', () ->
          db.close()
          next()
