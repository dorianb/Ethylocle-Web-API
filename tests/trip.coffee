should = require 'should'
db = require '../lib/db'

describe 'Trip test', ->

  beforeEach (next) ->
    rimraf "#{__dirname}/../db/tmp", next

  it 'Insert and get user by email', (next) ->
    client = db "#{__dirname}/../db/tmp"
    client.users.set 'dorian@ethylocle.com',
      email: 'dorian@ethylocle.com'
      password: '1234'
    , (err) ->
      return next err if err
      client.users.get 'dorian@ethylocle.com', (err, user) ->
        return next err if err
        user.email.should.eql 'dorian@ethylocle.com'
        user.password.should.eql '1234'
        client.close()
        next()
