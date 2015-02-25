should = require 'should'
AbstractModel = require '../abstract'

describe 'Abstract model class', ->

  it 'Create abstract model', (next) ->
    try
      model = new AbstractModel
    catch error
      #console.log error.message
    error.message.should.eql "Can't instantiate abstract class !"
    should.not.exists model
    next()

  ###it 'Call user signIn method', (next) ->
    try
      AbstractModel.prototype.signIn null, null
    catch error
      #console.log error.message
    error.message.should.eql "Abstract method !"
    next()###
