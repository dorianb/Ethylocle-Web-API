rimraf = require 'rimraf'
should = require 'should'
show = require '../show'
Down = require '../../down'

describe 'Show', ->

  beforeEach (next) ->
    rimraf "#{__dirname}/../../../../../db/tmp/user", next

  it 'Show user database with 3 users', (next) ->
    user1 =
      email: 'dorian@ethylocle.com'
      lastname: 'Bagur'
      firstname: 'Dorian'
      password: '1234'
    user2 =
      email: 'maoqiao@ethylocle.com'
      lastname: 'Zhou'
      firstname: 'Maoqiao'
      password: '1234'
    user3 =
      email: 'robin@ethylocle.com'
      lastname: 'Biondi'
      firstname: 'Robin'
      password: '1234'
    client = Down "#{__dirname}/../../../../../db/tmp/user"
    client.users.getMaxId (err, maxId) ->
      return next err if err
      user1.id = ++maxId
      client.users.set user1.id, user1, (err) ->
        return next err if err
        client.users.setByEmail user1.email, user1, (err) ->
          return next err if err
          client.users.getMaxId (err, maxId) ->
            return next err if err
            user2.id = ++maxId
            client.users.set user2.id, user2, (err) ->
              return next err if err
              client.users.setByEmail user2.email, user2, (err) ->
                return next err if err
                client.users.getMaxId (err, maxId) ->
                  return next err if err
                  user3.id = ++maxId
                  client.users.set user3.id, user3, (err) ->
                    return next err if err
                    client.users.setByEmail user3.email, user3, (err) ->
                      return next err if err
                      client.close (err) ->
                        return next err if err
                        show "#{__dirname}/../../../../../db/tmp/user", 'user', (err, message) ->
                          return next err if err
                          console.log message
                          next()

  it 'Show user database without user', (next) ->
    show "#{__dirname}/../../../../../db/tmp/user", 'user', (err, message) ->
      return next err if err
      console.log message
      next()

  it 'Show user database with 1 user', (next) ->
    user1 =
      email: 'dorian@ethylocle.com'
      lastname: 'Bagur'
      firstname: 'Dorian'
      password: '1234'
    client = Down "#{__dirname}/../../../../../db/tmp/user"
    client.users.getMaxId (err, maxId) ->
      return next err if err
      user1.id = ++maxId
      client.users.set user1.id, user1, (err) ->
        return next err if err
        client.users.setByEmail user1.email, user1, (err) ->
          return next err if err
          client.close (err) ->
            return next err if err
            show "#{__dirname}/../../../../../db/tmp/user", 'user', (err, message) ->
              return next err if err
              console.log message
              next()
