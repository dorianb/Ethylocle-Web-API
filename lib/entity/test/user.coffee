should = require 'should'
User = require '../user'

describe 'User entity', ->

  it 'Create user', (next) ->
    data =
      id: 0
      email: "dorian@ethylocle.com"
      password: "1234"
    user = new User data
    user.id.should.eql data.id
    user.email.should.eql data.email
    user.password.should.eql data.password
    should.not.exists user.image
    should.not.exists user.lastName
    should.not.exists user.firstName
    should.not.exists user.birthDate
    should.not.exists user.gender
    should.not.exists user.weight
    should.not.exists user.address
    should.not.exists user.zipCode
    should.not.exists user.city
    should.not.exists user.country
    should.not.exists user.phone
    should.not.exists user.latitude
    should.not.exists user.longitude
    should.not.exists user.longitude
    should.not.exists user.bac
    should.not.exists user.bacDate
    next()

  it 'Get User', (next) ->
    data =
      id: "0"
      email: "dorian@ethylocle.com"
      password: "1234"
    user = new User data
    user = user.get()
    user.id.should.eql data.id
    user.email.should.eql data.email
    user.password.should.eql data.password
    should.not.exists user.image
    should.not.exists user.lastName
    should.not.exists user.firstName
    should.not.exists user.birthDate
    should.not.exists user.gender
    should.not.exists user.weight
    should.not.exists user.address
    should.not.exists user.zipCode
    should.not.exists user.city
    should.not.exists user.country
    should.not.exists user.phone
    should.not.exists user.latitude
    should.not.exists user.longitude
    should.not.exists user.longitude
    should.not.exists user.bac
    should.not.exists user.bacDate
    next()

  it 'Get User without properties', (next) ->
    user = new User
    user = user.get()
    should.not.exists user.id
    should.not.exists user.email
    should.not.exists user.password
    should.not.exists user.image
    should.not.exists user.lastName
    should.not.exists user.firstName
    should.not.exists user.birthDate
    should.not.exists user.gender
    should.not.exists user.weight
    should.not.exists user.address
    should.not.exists user.zipCode
    should.not.exists user.city
    should.not.exists user.country
    should.not.exists user.phone
    should.not.exists user.latitude
    should.not.exists user.longitude
    should.not.exists user.longitude
    should.not.exists user.bac
    should.not.exists user.bacDate
    next()

  it 'Get User with empty properties', (next) ->
    user = new User {}
    user = user.get()
    should.not.exists user.id
    should.not.exists user.email
    should.not.exists user.password
    should.not.exists user.image
    should.not.exists user.lastName
    should.not.exists user.firstName
    should.not.exists user.birthDate
    should.not.exists user.gender
    should.not.exists user.weight
    should.not.exists user.address
    should.not.exists user.zipCode
    should.not.exists user.city
    should.not.exists user.country
    should.not.exists user.phone
    should.not.exists user.latitude
    should.not.exists user.longitude
    should.not.exists user.longitude
    should.not.exists user.bac
    should.not.exists user.bacDate
    next()

  it 'User toString', (next) ->
    data =
      id: "0"
      email: "dorian@ethylocle.com"
      password: "1234"
    user = User data
    string = user.toString()
    string.should.eql "User id:0 email:dorian@ethylocle.com password:1234"
    next()

  it 'User toString without properties', (next) ->
    user = new User
    string = user.toString()
    string.should.eql "User"
    next()

  it 'User toString with empty properties', (next) ->
    user = new User {}
    string = user.toString()
    string.should.eql "User"
    next()
