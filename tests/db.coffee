rimraf = require 'rimraf'
should = require 'should'
db = require '../lib/db'

describe 'users', ->

  beforeEach (next) ->
    rimraf "#{__dirname}/../db/tmp", next

  it 'insert and get user by email', (next) ->
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

  it 'get only a single user by email', (next) ->
    client = db "#{__dirname}/../db/tmp"
    client.users.set 'dorian@ethylocle.com',
      email: 'dorian@ethylocle.com'
      password: '1234'
    , (err) ->
      return next err if err
      client.users.set 'maoqiao@ethylocle.com',
        email: 'maoqiao@ethylocle.com'
        password: '4321'
      , (err) ->
        return next err if err
        client.users.get 'maoqiao@ethylocle.com', (err, user) ->
          return next err if err
          user.email.should.eql 'maoqiao@ethylocle.com'
          user.password.should.eql '4321'
          client.close()
          next()

  it 'Sign in', (next) ->
    client = db "#{__dirname}/../db/tmp"
    client.users.set 'dorian@ethylocle.com',
      email: 'dorian@ethylocle.com'
      password: '1234'
    , (err) ->
      return next err if err
      client.users.set 'maoqiao@ethylocle.com',
        email: 'maoqiao@ethylocle.com'
        password: '4321'
      , (err) ->
        return next err if err
        login = 'maoqiao@ethylocle.com'
        password = '4321'
        client.users.get login, (err, user) ->
          return next err if err
          assertion = user.email is login and user.password is password
          assertion.should.eql true
          client.close()
          next()

  it 'sign up', (next) ->
    client = db "#{__dirname}/../db/tmp"
    client.users.set 'dorian@ethylocle.com',
     email: 'dorian@ethylocle.com'
     password: '1234'
    , (err) ->
     return next err if err
     client.users.set 'maoqiao@ethylocle.com',
       email: 'maoqiao@ethylocle.com'
       password: '4321'
     , (err) ->
       return next err if err
       email = 'dorian@ethylocle.com'
       password = '1234'
       client.users.get email, (err, user) ->
         return next err if err
         assertion = user.email is email
         if assertion
           console.log 'Email already used'
           assertion.should.eql true
           client.close()
           next()
         else
           console.log 'Email is available'
           assertion.should.eql false
           client.users.set email,
            email: email
            password: password
           , (err) ->
             return next err if err
             client.close()
             next()
