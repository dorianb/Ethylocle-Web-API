rimraf = require 'rimraf'
should = require 'should'
Up = require '../down'

describe 'Down levelDB Model', ->

  beforeEach (next) ->
    rimraf "#{__dirname}/../../db/tmp/user", next

  ###it 'Insert and get user', (next) ->
    user1 =
      email: 'dorian@ethylocle.com'
      password: '1234'
    client = db "#{__dirname}/../../db/tmp/user"
    client.users.getMaxId (err, maxId) ->
      return next err if err
      user1.id = ++maxId
      client.users.set user1.id, user1, (err) ->
        return next err if err
        client.users.get user1.id, (err, user) ->
          return next err if err
          user.id.should.eql '0'
          user.email.should.eql 'dorian@ethylocle.com'
          user.password.should.eql '1234'
          client.close()
          next()

  it 'Insert and get user by email', (next) ->
    user1 =
      email: 'dorian@ethylocle.com'
      password: '1234'
    client = db "#{__dirname}/../../db/tmp/user"
    client.users.getMaxId (err, maxId) ->
      return next err if err
      user1.id = ++maxId
      client.users.set user1.id, user1, (err) ->
        return next err if err
        client.users.setByEmail user1.email, user1, (err) ->
          return next err if err
          client.users.getByEmail user1.email, (err, user) ->
            return next err if err
            client.users.get user.id, (err, user) ->
              return next err if err
              user.id.should.eql '0'
              user.email.should.eql 'dorian@ethylocle.com'
              user.password.should.eql '1234'
              client.close()
              next()

  it 'Insert two users and get them', (next) ->
    user1 =
      email: 'dorian@ethylocle.com'
      password: '1234'
    user2 =
      email: 'maoqiao@ethylocle.com'
      password: '1234'
    client = db "#{__dirname}/../../db/tmp/user"
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
                client.users.getByEmail user1.email, (err, user) ->
                  return next err if err
                  client.users.get user.id, (err, user) ->
                    return next err if err
                    user.id.should.eql '0'
                    user.email.should.eql 'dorian@ethylocle.com'
                    user.password.should.eql '1234'
                    client.users.getByEmail user2.email, (err, user) ->
                      return next err if err
                      client.users.get user.id, (err, user) ->
                        return next err if err
                        user.id.should.eql '1'
                        user.email.should.eql 'maoqiao@ethylocle.com'
                        user.password.should.eql '1234'
                        client.close()
                        next()###
