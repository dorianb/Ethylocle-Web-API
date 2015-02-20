should = require 'should'
factory = require '../model'

describe 'Model Factory', ->

  it 'Call factory', (next) ->
    model = factory "#{__dirname}/../../../db/tmp"
    should.exists model.users
    should.exists model.trips
    should.exists model.stops
    next()
