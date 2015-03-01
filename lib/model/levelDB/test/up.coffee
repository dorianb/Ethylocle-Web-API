rimraf = require 'rimraf'
should = require 'should'
Up = require '../up'
User = require '../../../entity/user'

describe 'Up levelDB Model', ->

  beforeEach (next) ->
    rimraf "#{__dirname}/../../../../db/tmp/user", next

  it 'Create Up', (next) ->
    up = Up "#{__dirname}/../../../../db/tmp"
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
      return next err if err
      Object.keys(response).length.should.eql 2
      response.result.should.eql false
      response.data.should.eql "Email ou mot de passe incorrect"
      next()

  it 'Sign up', (next) ->
    body =
      email: 'dorian@ethylocle.com'
      password: '1234'
    user = User body
    Up("#{__dirname}/../../../../db/tmp").signUp user, (err, response) ->
      return next err if err
      Object.keys(response).length.should.eql 3
      response.result.should.eql true
      should.not.exists response.data
      Object.keys(response.user).length.should.eql 3
      response.user.id.should.eql '0'
      response.user.email.should.eql 'dorian@ethylocle.com'
      response.user.password.should.eql '1234'
      next()

  it 'Sign up with an unavailable email', (next) ->
    body =
      email: 'dorian@ethylocle.com'
      password: '1234'
    user = User body
    Up("#{__dirname}/../../../../db/tmp").signUp user, (err, response) ->
      return next err if err
      Up("#{__dirname}/../../../../db/tmp").signUp user, (err, response) ->
        return next err if err
        Object.keys(response).length.should.eql 2
        response.result.should.eql false
        response.data.should.eql "L'email n'est plus disponible"
        next()

  it 'Sign in after signed up', (next) ->
    body =
      email: 'robin@ethylocle.com'
      password: '1234'
    user = User body
    Up("#{__dirname}/../../../../db/tmp").signUp user, (err, response) ->
      return next err if err
      Up("#{__dirname}/../../../../db/tmp").signIn user, (err, response) ->
        return next err if err
        Object.keys(response).length.should.eql 3
        response.result.should.eql true
        should.not.exists response.data
        Object.keys(response.user).length.should.eql 3
        response.user.id.should.eql '0'
        response.user.email.should.eql 'robin@ethylocle.com'
        response.user.password.should.eql '1234'
        next()

  it 'Check password with right password (after signed up)', (next) ->
    body =
      email: 'robin@ethylocle.com'
      password: '1234'
    user = User body
    Up("#{__dirname}/../../../../db/tmp").signUp user, (err, response) ->
      return next err if err
      Up("#{__dirname}/../../../../db/tmp").checkPassword user, (err, response) ->
        return next err if err
        Object.keys(response).length.should.eql 2
        response.result.should.eql true
        should.not.exists response.data
        next()

  it 'Check password with wrong password (after signed up)', (next) ->
    body =
      email: 'robin@ethylocle.com'
      password: '1234'
    user = User body
    Up("#{__dirname}/../../../../db/tmp").signUp user, (err, response) ->
      return next err if err
      user.password = '4321'
      Up("#{__dirname}/../../../../db/tmp").checkPassword user, (err, response) ->
        return next err if err
        Object.keys(response).length.should.eql 2
        response.result.should.eql false
        should.not.exists response.data
        next()

  it 'Update email (after signed up)', (next) ->
    body =
      email: 'dorian@ethylocle.com'
      password: '1234'
    user = User body
    Up("#{__dirname}/../../../../db/tmp").signUp user, (err, response) ->
      return next err if err
      user.email = 'robin@ethylocle.com'
      Up("#{__dirname}/../../../../db/tmp").updateEmail user, (err, response) ->
        return next err if err
        Object.keys(response).length.should.eql 2
        response.result.should.eql true
        should.not.exists response.data
        next()

  it 'Update email with an unavaliable email (after signed up)', (next) ->
    body =
      email: 'dorian@ethylocle.com'
      password: '1234'
    user = User body
    Up("#{__dirname}/../../../../db/tmp").signUp user, (err, response) ->
      return next err if err
      user.email = 'dorian@ethylocle.com'
      Up("#{__dirname}/../../../../db/tmp").updateEmail user, (err, response) ->
        return next err if err
        Object.keys(response).length.should.eql 2
        response.result.should.eql false
        response.data.should.eql "L'email n'est plus disponible"
        next()

  it 'Update (after signed up)', (next) ->
    body =
      email: 'dorian@ethylocle.com'
      password: '1234'
    user = User body
    Up("#{__dirname}/../../../../db/tmp").signUp user, (err, response) ->
      return next err if err
      user.set
        email: 'maoqiao@ethylocle.com'
        lastName: "Bagur"
        firstName: "Dorian"
      Up("#{__dirname}/../../../../db/tmp").update user, (err, response) ->
        return next err if err
        Object.keys(response).length.should.eql 2
        response.result.should.eql true
        should.not.exists response.data
        next()

  it 'Get (after signed up)', (next) ->
    body =
      email: 'dorian@ethylocle.com'
      password: '1234'
      lastName: "Bagur"
      bac: "1.12"
    user = User body
    Up("#{__dirname}/../../../../db/tmp").signUp user, (err, response) ->
      return next err if err
      Up("#{__dirname}/../../../../db/tmp").get User({id: '0'}), (err, response) ->
        return next err if err
        Object.keys(response).length.should.eql 2
        response.result.should.eql true
        response.data.id.should.eql '0'
        response.data.email.should.eql user.email
        response.data.lastName.should.eql user.lastName
        response.data.bac.should.eql user.bac
        should.not.exists response.data.password
        next()

  it 'Get by id (after signed up)', (next) ->
    body =
      email: 'dorian@ethylocle.com'
      password: '1234'
      lastName: "Bagur"
      bac: "1.12"
    user = User body
    Up("#{__dirname}/../../../../db/tmp").signUp user, (err, response) ->
      return next err if err
      Up("#{__dirname}/../../../../db/tmp").getById User({id: '0'}), (err, response) ->
        return next err if err
        Object.keys(response).length.should.eql 2
        response.result.should.eql true
        response.data.id.should.eql '0'
        response.data.lastName.should.eql user.lastName
        should.not.exists response.data.password
        should.not.exists response.data.email
        should.not.exists response.data.bac
        next()

  it 'Delete (after signed up)', (next) ->
    body =
      email: 'dorian@ethylocle.com'
      password: '1234'
      lastName: "Bagur"
      bac: "1.12"
    user = User body
    Up("#{__dirname}/../../../../db/tmp").signUp user, (err, response) ->
      return next err if err
      Up("#{__dirname}/../../../../db/tmp").delete User({id: '0'}), (err, response) ->
        return next err if err
        Object.keys(response).length.should.eql 2
        response.result.should.eql true
        should.not.exists response.data
        Up("#{__dirname}/../../../../db/tmp").getById User({id: '0'}), (err, response) ->
          return next err if err
          Object.keys(response).length.should.eql 2
          response.result.should.eql false
          response.data.should.eql "L'utilisateur n'existe pas"
          next()
