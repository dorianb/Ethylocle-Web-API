rimraf = require 'rimraf'
should = require 'should'
Up = require '../up'

describe 'Up levelDB Model', ->

  beforeEach (next) ->
    rimraf "#{__dirname}/../../db/tmp/user", next

  it 'Create Up', (next) ->
    up = new Up "#{__dirname}/../../../../db/tmp"
    up.should.exists
    up.path.should.eql "#{__dirname}/../../../../db/tmp"
    next()

  it 'Create Up without path', (next) ->
    up = Up()
    up.should.exists
    up.path.should.exists
    next()

  it 'Create Up without constructor', (next) ->
    Up("#{__dirname}/../../../../db/tmp").path.should.eql "#{__dirname}/../../../../db/tmp"
    next()

  it 'Sign in without signed up', (next) ->
    body =
      email: 'dorian@ethylocle.com'
      password: '1234'
    Up("#{__dirname}/../../../../db/tmp").signIn body, (err, response) ->
      response.result.should.eql false
      response.data.should.eql "Email ou mot de passe incorrect"
      should.not.exists response.user
      next()

  it 'Sign Up', (next) ->
    next()

  it 'Check password', (next) ->
    next()
