rimraf = require 'rimraf'
should = require 'should'
db = require '../lib/db'

describe 'Trip test', ->

  beforeEach (next) ->
    rimraf "#{__dirname}/../db/tmp/trip", ->
      rimraf "#{__dirname}/../db/tmp/user", next

  it 'Insert and get a trip', (next) ->
    client1 = db "#{__dirname}/../db/tmp/user"
    client2 = db "#{__dirname}/../db/tmp/trip"
    user1 =
      email: 'dorian@ethylocle.com'
      password: '1234'
    client1.users.getMaxId (err, maxId) ->
      return next err if err
      user1.id = ++maxId
      client1.users.set user1.id, user1, (err) ->
        return next err if err
        client1.users.setByEmail user1.email, user1, (err) ->
          return next err if err
          client1.close()
          client2.trips.set '0',
            latStart: '48.853611'
            lonStart: '2.287546'
            latEnd: '48.860359'
            lonEnd: '2.352949'
            dateTime: '22-01-2015 16:30'
            price: '30'
            passenger_1: user1.id
            passenger_2: user1.id
          , (err) ->
            return next err if err
            client2.trips.get '0', (err, trip) ->
              return next err if err
              trip.latStart.should.eql '48.853611'
              trip.lonStart.should.eql '2.287546'
              trip.latEnd.should.eql '48.860359'
              trip.lonEnd.should.eql '2.352949'
              trip.dateTime.should.eql '22-01-2015 16:30'
              trip.price.should.eql '30'
              trip.passenger_1.should.eql '0'
              trip.passenger_2.should.eql '0'
              should.not.exists trip.passenger_3
              should.not.exists trip.passenger_4
              client2.close()
              next()

  it 'Insert two trips and get a single one', (next) ->
    client1 = db "#{__dirname}/../db/tmp/user"
    client2 = db "#{__dirname}/../db/tmp/trip"
    user1 =
      email: 'dorian@ethylocle.com'
      password: '1234'
    user2 =
      email: 'maoqiao@ethylocle.com'
      password: '4321'
    client1.users.getMaxId (err, maxId) ->
      return next err if err
      user1.id = ++maxId
      client1.users.set user1.id, user1, (err) ->
        return next err if err
        client1.users.setByEmail user1.email, user1, (err) ->
          return next err if err
          client1.users.getMaxId (err, maxId) ->
            return next err if err
            user2.id = ++maxId
            client1.users.set user2.id, user2, (err) ->
              return next err if err
              client1.users.setByEmail user2.email, user2, (err) ->
                return next err if err
                client1.close()
                client2.trips.set '0',
                  latStart: '48.853611'
                  lonStart: '2.287546'
                  latEnd: '48.860359'
                  lonEnd: '2.352949'
                  dateTime: '22-01-2015 16:02'
                  price: '30'
                  passenger_1: user1.id
                  passenger_2: user1.id
                , (err) ->
                  return next err if err
                  client2.trips.set '1',
                    latStart: '48.856470'
                    lonStart: '2.286001'
                    latEnd: '48.865314'
                    lonEnd: '2.321514'
                    dateTime: '22-01-2015 16:30'
                    price: '17'
                    passenger_1: user2.id
                  , (err) ->
                    return next err if err
                    client2.trips.get '0', (err, trip) ->
                      return next err if err
                      trip.latStart.should.eql '48.853611'
                      trip.lonStart.should.eql '2.287546'
                      trip.latEnd.should.eql '48.860359'
                      trip.lonEnd.should.eql '2.352949'
                      trip.dateTime.should.eql '22-01-2015 16:02'
                      trip.price.should.eql '30'
                      trip.passenger_1.should.eql '0'
                      trip.passenger_2.should.eql '0'
                      should.not.exists trip.passenger3
                      should.not.exists trip.passenger4
                      client2.trips.get '1', (err, trip) ->
                        return next err if err
                        trip.latStart.should.eql '48.856470'
                        trip.lonStart.should.eql '2.286001'
                        trip.latEnd.should.eql '48.865314'
                        trip.lonEnd.should.eql '2.321514'
                        trip.dateTime.should.eql '22-01-2015 16:30'
                        trip.price.should.eql '17'
                        trip.passenger_1.should.eql '1'
                        should.not.exists trip.passenger_2
                        should.not.exists trip.passenger_3
                        should.not.exists trip.passenger_4
                        client2.close()
                        next()

  it 'Get last trip id', (next) ->
    client = db "#{__dirname}/../db/tmp/trip"
    client.trips.set '0',
      latStart: '48.853611'
      lonStart: '2.287546'
      latEnd: '48.860359'
      lonEnd: '2.352949'
      dateTime: '22-01-2015 16:02'
      price: '30'
      passenger_1: 'dorian@ethylocle.com'
      passenger_2: 'dorian@ethylocle.com'
    , (err) ->
      return next err if err
      client.trips.set '1',
        latStart: '48.856470'
        lonStart: '2.286001'
        latEnd: '48.865314'
        lonEnd: '2.321514'
        dateTime: '22-01-2015 16:30'
        price: '17'
        passenger_1: 'maoqiao@ethylocle.com'
      , (err) ->
        return next err if err
        client.trips.getMaxId (err, maxId) ->
          return next err if err
          maxId.should.eql '1'
          client.close()
          next()

  it 'Insert two trips without knowing last id', (next) ->
    client = db "#{__dirname}/../db/tmp/trip"
    client.users.set 'dorian@ethylocle.com',
      email: 'dorian@ethylocle.com'
      password: '1234'
    , (err) ->
      return next err if err
      client.users.set 'maoqiao@ethylocle.com',
        email: 'maoqiao@ethylocle.com'
        password: '1234'
      , (err) ->
        return next err if err
        client.trips.getMaxId (err, maxId) ->
          return next err if err
          maxId.should.eql '-1'
          client.trips.set ++maxId,
            latStart: '48.853611'
            lonStart: '2.287546'
            latEnd: '48.860359'
            lonEnd: '2.352949'
            dateTime: '22-01-2015 16:02'
            price: '30'
            passenger_1: 'dorian@ethylocle.com'
            passenger_2: 'dorian@ethylocle.com'
          , (err) ->
            return next err if err
            client.trips.getMaxId (err, maxId) ->
              return next err if err
              maxId.should.eql '0'
              client.trips.set ++maxId,
                latStart: '48.856470'
                lonStart: '2.286001'
                latEnd: '48.865314'
                lonEnd: '2.321514'
                dateTime: '22-01-2015 16:30'
                price: '17'
                passenger_1: 'maoqiao@ethylocle.com'
              , (err) ->
                return next err if err
                client.trips.get '0', (err, trip) ->
                  return next err if err
                  trip.latStart.should.eql '48.853611'
                  trip.lonStart.should.eql '2.287546'
                  trip.latEnd.should.eql '48.860359'
                  trip.lonEnd.should.eql '2.352949'
                  trip.dateTime.should.eql '22-01-2015 16:02'
                  trip.price.should.eql '30'
                  trip.passenger_1.should.eql 'dorian@ethylocle.com'
                  trip.passenger_2.should.eql 'dorian@ethylocle.com'
                  should.not.exists trip.passenger3
                  should.not.exists trip.passenger4
                  client.trips.get '1', (err, trip) ->
                    return next err if err
                    trip.latStart.should.eql '48.856470'
                    trip.lonStart.should.eql '2.286001'
                    trip.latEnd.should.eql '48.865314'
                    trip.lonEnd.should.eql '2.321514'
                    trip.dateTime.should.eql '22-01-2015 16:30'
                    trip.price.should.eql '17'
                    trip.passenger_1.should.eql 'maoqiao@ethylocle.com'
                    should.not.exists trip.passenger_2
                    should.not.exists trip.passenger_3
                    should.not.exists trip.passenger_4
                    client.close()
                    next()

  it 'Create a trip for 1 person', (next) ->
    session = 'dorian@ethylocle.com'
    body =
      latStart: '48.856470'
      lonStart: '2.286001'
      latEnd: '48.865314'
      lonEnd: '2.321514'
      dateTime: '22-01-2015 16:30'
      numberOfPeople: '1'
    if body.numberOfPeople > 2
      console.log "Impossible de créer un trajet pour plus de 2 personnes"
    else
      client = db "#{__dirname}/../db/tmp/trip"
      data = {}
      for k, v of body
        continue unless v
        if k is 'numberOfPeople'
          i = 0
          while i < v
            data["passenger_" + ++i] = session
        else
          data[k] = v
      data.price = '15' #A déterminer à l'aide de l'api taxi G7
      client.trips.getMaxId (err, maxId) ->
        return next err if err
        client.trips.set ++maxId, data, (err) ->
          return next err if err
          client.trips.get '0', (err, trip) ->
            return next err if err
            trip.latStart.should.eql '48.856470'
            trip.lonStart.should.eql '2.286001'
            trip.latEnd.should.eql '48.865314'
            trip.lonEnd.should.eql '2.321514'
            trip.dateTime.should.eql '22-01-2015 16:30'
            trip.price.should.eql '15'
            trip.passenger_1.should.eql session
            should.not.exists trip.passenger_2
            should.not.exists trip.passenger_3
            should.not.exists trip.passenger_4
            client.close()
            next()

  it 'Create a trip for 2 persons', (next) ->
    session = 'dorian@ethylocle.com'
    body =
      latStart: '48.856470'
      lonStart: '2.286001'
      latEnd: '48.865314'
      lonEnd: '2.321514'
      dateTime: '22-01-2015 16:30'
      numberOfPeople: '2'
    if body.numberOfPeople > 2
      console.log "Impossible de créer un trajet pour plus de 2 personnes"
    else
      client = db "#{__dirname}/../db/tmp/trip"
      data = {}
      for k, v of body
        continue unless v
        if k is 'numberOfPeople'
          i = 0
          while i < v
            data["passenger_" + ++i] = session
        else
          data[k] = v
      data.price = '15' #A déterminer à l'aide de l'api taxi G7
      client.trips.getMaxId (err, maxId) ->
        return next err if err
        client.trips.set ++maxId, data, (err) ->
          return next err if err
          client.trips.get '0', (err, trip) ->
            return next err if err
            trip.latStart.should.eql '48.856470'
            trip.lonStart.should.eql '2.286001'
            trip.latEnd.should.eql '48.865314'
            trip.lonEnd.should.eql '2.321514'
            trip.dateTime.should.eql '22-01-2015 16:30'
            trip.price.should.eql '15'
            trip.passenger_1.should.eql session
            trip.passenger_2.should.eql session
            should.not.exists trip.passenger_3
            should.not.exists trip.passenger_4
            client.close()
            next()

  it 'Create a trip for 3 or more persons', (next) ->
    session = 'dorian@ethylocle.com'
    body =
      latStart: '48.856470'
      lonStart: '2.286001'
      latEnd: '48.865314'
      lonEnd: '2.321514'
      dateTime: '22-01-2015 16:30'
      numberOfPeople: '3'
    assertion = body.numberOfPeople > 2
    assertion.should.eql true
    next()

  it 'Join trip', (next) ->
    next()
