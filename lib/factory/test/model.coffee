should = require 'should'
model = require '../model'
Up = require '../../model/levelDB/up'

describe 'Model factory', ->

  it 'Call model factory for LevelDB', (next) ->
    assertion = model() instanceof Up
    assertion.should.eql true
    next()
