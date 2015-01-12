rimraf = require 'rimraf'
should = require 'should'
db = require '../lib/db'

describe 'users', ->

  beforeEach (next) ->
    rimraf "#{__dirname}/../db/tmp", next

  it 'insert and get user by username', (next) ->
    client = db "#{__dirname}/../db/tmp"
    client.users.set 'dorianb',
      lastname: 'Bagur'
      firstname: 'Dorian'
      email: 'dorian@ethylocle.com'
    , (err) ->
      return next err if err
      client.users.get 'dorianb', (err, user) ->
        return next err if err
        user.username.should.eql 'dorianb'
        user.lastname.should.eql 'Bagur'
        user.firstname.should.eql 'Dorian'
        user.email.should.eql 'dorian@ethylocle.com'
        client.close()
        next()

  it 'get only a single user by username', (next) ->
    client = db "#{__dirname}/../db/tmp"
    client.users.set 'dorianb',
      lastname: 'Bagur'
      firstname: 'Dorian'
    , (err) ->
      return next err if err
      client.users.set 'maoqiaoz',
        lastname: 'Zhou'
        firstname: 'Maoqiao'
        email: 'maoqiao@ethylocle.com'
      , (err) ->
        return next err if err
        client.users.get 'dorianb', (err, user) ->
          return next err if err
          user.username.should.eql 'dorianb'
          user.lastname.should.eql 'Bagur'
          should.not.exists user.email
          client.close()
          next()

  it 'insert and get user by email', (next) ->
    client = db "#{__dirname}/../db/tmp"
    client.users.set 'dorianb',
      lastname: 'Bagur'
      firstname: 'Dorian'
      email: 'dorian@ethylocle.com'
    , (err) ->
      return next err if err
      client.users.setByEmail 'dorian@ethylocle.com',
        username: 'dorianb'
      , (err) ->
        return next err if err
        client.users.getByEmail 'dorian@ethylocle.com', (err, userByEmail) ->
          return next err if err
          userByEmail.email.should.eql 'dorian@ethylocle.com'
          userByEmail.username.should.eql 'dorianb'
          client.users.get userByEmail.username, (err, user) ->
            return next err if err
            user.username.should.eql 'dorianb'
            user.lastname.should.eql 'Bagur'
            user.firstname.should.eql 'Dorian'
            user.email.should.eql 'dorian@ethylocle.com'
            client.close()
            next()

  it 'get only a single user by email', (next) ->
    client = db "#{__dirname}/../db/tmp"
    client.users.set 'dorianb',
      lastname: 'Bagur'
      firstname: 'Dorian'
      email: 'dorian@ethylocle.com'
    , (err) ->
      return next err if err
      client.users.setByEmail 'dorian@ethylocle.com',
        username: 'dorianb'
      , (err) ->
        return next err if err
        client.users.set 'maoqiaoz',
          lastname: 'Zhou'
          firstname: 'Maoqiao'
          email: 'maoqiao@ethylocle.com'
        , (err) ->
          return next err if err
          client.users.setByEmail 'maoqiao@ethylocle.com',
            username: 'maoqiaoz'
          , (err) ->
            return next err if err
            client.users.getByEmail 'dorian@ethylocle.com', (err, userByEmail) ->
              return next err if err
              userByEmail.email.should.eql 'dorian@ethylocle.com'
              userByEmail.username.should.eql 'dorianb'
              client.users.get userByEmail.username, (err, user) ->
                return next err if err
                user.username.should.eql 'dorianb'
                user.lastname.should.eql 'Bagur'
                user.firstname.should.eql 'Dorian'
                user.email.should.eql 'dorian@ethylocle.com'
                client.users.getByEmail 'maoqiao@ethylocle.com', (err, userByEmail) ->
                  return next err if err
                  userByEmail.email.should.eql 'maoqiao@ethylocle.com'
                  userByEmail.username.should.eql 'maoqiaoz'
                  client.users.get userByEmail.username, (err, user) ->
                    return next err if err
                    user.username.should.eql 'maoqiaoz'
                    user.lastname.should.eql 'Zhou'
                    user.firstname.should.eql 'Maoqiao'
                    user.email.should.eql 'maoqiao@ethylocle.com'
                    client.close()
                    next()

  it 'Sign in', (next) ->
    client = db "#{__dirname}/../db/tmp"
    client.users.set 'dorianb',
      lastname: 'Bagur'
      firstname: 'Dorian'
      password: '1234'
      email: 'alfred@ethylocle.com'
    , (err) ->
      return next err if err
      client.users.setByEmail 'alfred@ethylocle.com',
        username: 'dorianb'
      , (err) ->
        return next err if err
        client.users.set 'maoqiaoz',
          lastname: 'Zhou'
          firstname: 'Maoqiao'
          password: '4321'
          email: 'gilbert@ethylocle.com'
        , (err) ->
          return next err if err
          client.users.setByEmail 'gilbert@ethylocle.com',
            username: 'maoqiaoz'
          , (err) ->
            return next err if err
            login = 'gilbert@ethylocle.com'
            password = '4321'
            client.users.get login, (err, user) ->
              return next err if err
              assertion = user.username is login and user.password is password
              if assertion
                console.log "By username"
                assertion.should.eql true
                client.close()
                next()
              else
                assertion.should.eql false
                client.users.getByEmail login, (err, userByEmail) ->
                  return next err if err
                  client.users.get userByEmail.username, (err, user) ->
                    return next err if err
                    assertion = user.email is login and user.password is password
                    console.log "By email"
                    assertion.should.eql true
                    client.close()
                    next()

  it 'sign up', (next) ->
    client = db "#{__dirname}/../db/tmp"
    client.users.set 'dorianb',
     lastname: 'Bagur'
     firstname: 'Dorian'
     password: '1234'
     email: 'alfred@ethylocle.com'
    , (err) ->
     return next err if err
     client.users.setByEmail 'alfred@ethylocle.com',
       username: 'dorianb'
     , (err) ->
       return next err if err
       client.users.set 'maoqiaoz',
         lastname: 'Zhou'
         firstname: 'Maoqiao'
         password: '4321'
         email: 'gilbert@ethylocle.com'
       , (err) ->
         return next err if err
         client.users.setByEmail 'gilbert@ethylocle.com',
           username: 'maoqiaoz'
         , (err) ->
           return next err if err
           username = 'dorian'
           lastname = 'Bagur'
           firstname = 'Dorian'
           password = '1234'
           email = 'alfred@ethylocle.com'
           client.users.get username, (err, user) ->
             return next err if err
             assertion = user.username is username
             if assertion
               console.log 'Username not available'
               assertion.should.eql true
               client.close()
               next()
             else
               client.users.getByEmail email, (err, userByEmail) ->
                 return next err if err
                 client.users.get userByEmail.username, (err, user) ->
                   return next err if err
                   assertion = user.email is email
                   if assertion
                     console.log 'Email already used'
                     assertion.should.eql true
                     client.close()
                     next()
                   else
                     console.log 'Username and email are available'
                     assertion.should.eql false
                     client.users.set username,
                       lastname: lastname
                       firstname: firstname
                       password: password
                       email: email
                     , (err) ->
                       return next err if err
                       client.users.setByEmail email,
                         username: username
                       , (err) ->
                         return next err if err
                         client.close()
                         next()
