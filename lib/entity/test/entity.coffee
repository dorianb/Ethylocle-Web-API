should = require 'should'
Entity = require '../entity'

describe 'Entity abstract class', ->

  it 'Create entity', (next) ->
    data =
      id: "0"
    try
      entity = new Entity data
    catch error
      #console.log error.message
    error.message.should.eql "Can't instantiate abstract class !"
    should.not.exists entity
    next()

  it 'Call get method', (next) ->
    try
      Entity.prototype.get()
    catch error
      #console.log error.message
    error.message.should.eql "Abstract method !"
    next()

  it 'Call toString method', (next) ->
    try
      Entity.prototype.toString()
    catch error
      #console.log error.message
    error.message.should.eql "Abstract method !"
    next()
