rimraf = require 'rimraf'
should = require 'should'
db = require '../lib/db'
tripSearch = require '../lib/tripsearch'
geolib = require 'geolib'
moment = require 'moment'

describe 'Trip test', ->

  beforeEach (next) ->
    rimraf "#{__dirname}/../db/tmp/tripsearch", ->
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
      passenger_1: '0'
      passenger_2: '0'
    , (err) ->
      return next err if err
      client.trips.set '1',
        latStart: '48.856470'
        lonStart: '2.286001'
        latEnd: '48.865314'
        lonEnd: '2.321514'
        dateTime: '22-01-2015 16:30'
        price: '17'
        passenger_1: '1'
      , (err) ->
        return next err if err
        client.trips.getMaxId (err, maxId) ->
          return next err if err
          maxId.should.eql '1'
          client.close()
          next()

  it 'Insert two trips without knowing last id', (next) ->
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
                client2.trips.getMaxId (err, maxId) ->
                  return next err if err
                  maxId.should.eql '-1'
                  client2.trips.set ++maxId,
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
                    client2.trips.getMaxId (err, maxId) ->
                      return next err if err
                      maxId.should.eql '0'
                      client2.trips.set ++maxId,
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

  it 'Create a trip for 1 person', (next) ->
    userId = '0'
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
            data["passenger_" + ++i] = userId
        else
          data[k] = v
      data.price = '15' #A déterminer à l'aide de l'api taxi G7
      client.trips.getMaxId (err, maxId) ->
        return next err if err
        client.trips.set ++maxId, data, (err) ->
          return next err if err
          client.trips.get maxId, (err, trip) ->
            return next err if err
            trip.latStart.should.eql '48.856470'
            trip.lonStart.should.eql '2.286001'
            trip.latEnd.should.eql '48.865314'
            trip.lonEnd.should.eql '2.321514'
            trip.dateTime.should.eql '22-01-2015 16:30'
            trip.price.should.eql '15'
            trip.passenger_1.should.eql userId
            should.not.exists trip.passenger_2
            should.not.exists trip.passenger_3
            should.not.exists trip.passenger_4
            client.trips.setByPassenger userId, trip, (err) ->
              return next err if err
              client.trips.getByPassenger userId, (err, trips) ->
                return next err if err
                trips.length.should.eql 1
                trips[0].id.should.eql '0'
                trips[0].dateTime.should.eql '22-01-2015 16:30'
                client.close()
                next()

  it 'Create a trip for 2 persons', (next) ->
    userId = '0'
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
            data["passenger_" + ++i] = userId
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
            trip.passenger_1.should.eql userId
            trip.passenger_2.should.eql userId
            should.not.exists trip.passenger_3
            should.not.exists trip.passenger_4
            client.trips.setByPassenger userId, trip, (err) ->
              return next err if err
              client.trips.getByPassenger userId, (err, trips) ->
                return next err if err
                trips.length.should.eql 1
                trips[0].id.should.eql '0'
                trips[0].dateTime.should.eql '22-01-2015 16:30'
                client.close()
                next()

  it 'Create a trip for 3 or more persons', (next) ->
    userId = '0'
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

  it 'Get trips', (next) ->
    this.timeout 10000
    dateTime1 = moment().add(30, 'm').format "DD-MM-YYYY H:mm"
    dateTime2 = moment().add(1, 'h').format "DD-MM-YYYY H:mm"
    dateTime3 = moment().add(90, 'm').format "DD-MM-YYYY H:mm"
    user1 =
      email: 'dorian@ethylocle.com'
      password: '1234'
    user2 =
      email: 'maoqiao@ethylocle.com'
      password: '4321'
    user3 =
      email: 'robin@ethylocle.com'
      password: '4321'
    user4 =
      email: 'pierre@ethylocle.com'
      password: '4321'
    client1 = db "#{__dirname}/../db/tmp/user"
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
                client1.users.getMaxId (err, maxId) ->
                  return next err if err
                  user3.id = ++maxId
                  client1.users.set user3.id, user3, (err) ->
                    return next err if err
                    client1.users.setByEmail user3.email, user3, (err) ->
                      return next err if err
                      client1.users.getMaxId (err, maxId) ->
                        return next err if err
                        user4.id = ++maxId
                        client1.users.set user4.id, user4, (err) ->
                          return next err if err
                          client1.users.setByEmail user4.email, user4, (err) ->
                            return next err if err
                            client1.close()
                            client2 = db "#{__dirname}/../db/tmp/trip"
                            client2.trips.getMaxId (err, maxId) ->
                              return next err if err
                              maxId.should.eql '-1'
                              client2.trips.set ++maxId,
                                latStart: '48.853611'
                                lonStart: '2.287546'
                                latEnd: '48.860359'
                                lonEnd: '2.352949'
                                dateTime: dateTime1
                                price: '30'
                                numberOfPassenger: '2'
                                passenger_1: user1.id
                                passenger_2: user1.id
                              , (err) ->
                                return next err if err
                                client2.trips.getMaxId (err, maxId) ->
                                  return next err if err
                                  maxId.should.eql '0'
                                  client2.trips.set ++maxId,
                                    latStart: '48.856470'
                                    lonStart: '2.286001'
                                    latEnd: '48.865314'
                                    lonEnd: '2.321514'
                                    dateTime: dateTime2
                                    price: '17'
                                    numberOfPassenger: '1'
                                    passenger_1: user2.id
                                  , (err) ->
                                    return next err if err
                                    client2.trips.getMaxId (err, maxId) ->
                                      return next err if err
                                      maxId.should.eql '1'
                                      client2.trips.set ++maxId,
                                        latStart: '48.857460'
                                        lonStart: '2.291070'
                                        latEnd: '48.867158'
                                        lonEnd: '2.313901'
                                        dateTime: dateTime3
                                        price: '17'
                                        numberOfPassenger: '1'
                                        passenger_1: user4.id
                                      , (err) ->
                                        return next err if err
                                        client2.trips.get '0', (err, trip) ->
                                          return next err if err
                                          trip.latStart.should.eql '48.853611'
                                          trip.lonStart.should.eql '2.287546'
                                          trip.latEnd.should.eql '48.860359'
                                          trip.lonEnd.should.eql '2.352949'
                                          trip.dateTime.should.eql dateTime1
                                          trip.price.should.eql '30'
                                          trip.numberOfPassenger.should.eql '2'
                                          trip.passenger_1.should.eql '0'
                                          trip.passenger_2.should.eql '0'
                                          should.not.exists trip.passenger3
                                          should.not.exists trip.passenger4
                                          client2.trips.setByPassenger user1.id, trip, (err) ->
                                            return next err if err
                                            client2.trips.getByPassenger user1.id, (err, trips) ->
                                              return next err if err
                                              trips.length.should.eql 1
                                              trips[0].id.should.eql '0'
                                              trips[0].dateTime.should.eql dateTime1
                                              client2.trips.get '1', (err, trip) ->
                                                return next err if err
                                                trip.latStart.should.eql '48.856470'
                                                trip.lonStart.should.eql '2.286001'
                                                trip.latEnd.should.eql '48.865314'
                                                trip.lonEnd.should.eql '2.321514'
                                                trip.dateTime.should.eql dateTime2
                                                trip.price.should.eql '17'
                                                trip.numberOfPassenger.should.eql '1'
                                                trip.passenger_1.should.eql '1'
                                                should.not.exists trip.passenger_2
                                                should.not.exists trip.passenger_3
                                                should.not.exists trip.passenger_4
                                                client2.trips.setByPassenger user2.id, trip, (err) ->
                                                  return next err if err
                                                  client2.trips.getByPassenger user2.id, (err, trips) ->
                                                    return next err if err
                                                    trips.length.should.eql 1
                                                    trips[0].id.should.eql '1'
                                                    trips[0].dateTime.should.eql dateTime2
                                                    client2.trips.get '2', (err, trip) ->
                                                      return next err if err
                                                      trip.latStart.should.eql '48.857460'
                                                      trip.lonStart.should.eql '2.291070'
                                                      trip.latEnd.should.eql '48.867158'
                                                      trip.lonEnd.should.eql '2.313901'
                                                      trip.dateTime.should.eql dateTime3
                                                      trip.price.should.eql '17'
                                                      trip.numberOfPassenger.should.eql '1'
                                                      trip.passenger_1.should.eql '3'
                                                      should.not.exists trip.passenger_2
                                                      should.not.exists trip.passenger_3
                                                      should.not.exists trip.passenger_4
                                                      client2.trips.setByPassenger user4.id, trip, (err) ->
                                                        return next err if err
                                                        client2.trips.getByPassenger user4.id, (err, trips) ->
                                                          return next err if err
                                                          trips.length.should.eql 1
                                                          trips[0].id.should.eql '2'
                                                          trips[0].dateTime.should.eql dateTime3
                                                          client2.close()
                                                          body =
                                                            latStart: '48.856470'
                                                            lonStart: '2.286001'
                                                            latEnd: '48.865314'
                                                            lonEnd: '2.321514'
                                                            dateTime: moment().add(25, 'm').format "DD-MM-YYYY H:mm"
                                                            numberOfPeople: '2'
                                                          tripSearch "#{__dirname}/../db/tmp", user3.id, body, (err, trips) ->
                                                            data = []
                                                            client3 = db "#{__dirname}/../db/tmp/trip"
                                                            getTripDetails = (i) ->
                                                              if i < trips.length
                                                                client3.trips.get trips[i], (err, trip) ->
                                                                  return next err if err
                                                                  datum = {}
                                                                  datum.id = trip.id
                                                                  datum.distanceToStart = geolib.getDistance({latitude: body.latStart, longitude: body.lonStart}, {latitude: trip.latStart, longitude: trip.lonStart})/1000
                                                                  datum.distanceToEnd = geolib.getDistance({latitude: body.latEnd, longitude: body.lonEnd}, {latitude: trip.latEnd, longitude: trip.lonEnd})/1000
                                                                  datum.dateTime = trip.dateTime
                                                                  datum.numberOfPassenger = trip.numberOfPassenger
                                                                  # Créer une fonction pour déterminer le prix maximal en fonction du nombre de parties prenantes
                                                                  datum.maxPrice = trip.price
                                                                  data.push datum
                                                                  getTripDetails i+1
                                                              else
                                                                client3.close()
                                                                trips.length.should.eql 3
                                                                ###for k, v of data
                                                                  for c, d of v
                                                                    console.log "Trip " + k + ": type: " + c + " valeur: " + d###
                                                                next()
                                                            getTripDetails 0

  it 'Has a trip', (next) ->
    this.timeout 10000
    dateTime1 = moment().add(30, 'm').format "DD-MM-YYYY H:mm"
    dateTime2 = moment().add(1, 'h').format "DD-MM-YYYY H:mm"
    dateTime3 = moment().add(90, 'm').format "DD-MM-YYYY H:mm"
    user1 =
      email: 'dorian@ethylocle.com'
      password: '1234'
    user2 =
      email: 'maoqiao@ethylocle.com'
      password: '4321'
    user3 =
      email: 'robin@ethylocle.com'
      password: '4321'
    user4 =
      email: 'pierre@ethylocle.com'
      password: '4321'
    client1 = db "#{__dirname}/../db/tmp/user"
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
                client1.users.getMaxId (err, maxId) ->
                  return next err if err
                  user3.id = ++maxId
                  client1.users.set user3.id, user3, (err) ->
                    return next err if err
                    client1.users.setByEmail user3.email, user3, (err) ->
                      return next err if err
                      client1.users.getMaxId (err, maxId) ->
                        return next err if err
                        user4.id = ++maxId
                        client1.users.set user4.id, user4, (err) ->
                          return next err if err
                          client1.users.setByEmail user4.email, user4, (err) ->
                            return next err if err
                            client1.close()
                            client2 = db "#{__dirname}/../db/tmp/trip"
                            client2.trips.getMaxId (err, maxId) ->
                              return next err if err
                              maxId.should.eql '-1'
                              client2.trips.set ++maxId,
                                latStart: '48.853611'
                                lonStart: '2.287546'
                                latEnd: '48.860359'
                                lonEnd: '2.352949'
                                dateTime: dateTime1
                                price: '30'
                                numberOfPassenger: '2'
                                passenger_1: user1.id
                                passenger_2: user1.id
                              , (err) ->
                                return next err if err
                                client2.trips.getMaxId (err, maxId) ->
                                  return next err if err
                                  maxId.should.eql '0'
                                  client2.trips.set ++maxId,
                                    latStart: '48.856470'
                                    lonStart: '2.286001'
                                    latEnd: '48.865314'
                                    lonEnd: '2.321514'
                                    dateTime: dateTime2
                                    price: '17'
                                    numberOfPassenger: '1'
                                    passenger_1: user2.id
                                  , (err) ->
                                    return next err if err
                                    client2.trips.getMaxId (err, maxId) ->
                                      return next err if err
                                      maxId.should.eql '1'
                                      client2.trips.set ++maxId,
                                        latStart: '48.857460'
                                        lonStart: '2.291070'
                                        latEnd: '48.867158'
                                        lonEnd: '2.313901'
                                        dateTime: dateTime3
                                        price: '17'
                                        numberOfPassenger: '1'
                                        passenger_1: user4.id
                                      , (err) ->
                                        return next err if err
                                        client2.trips.get '0', (err, trip) ->
                                          return next err if err
                                          trip.latStart.should.eql '48.853611'
                                          trip.lonStart.should.eql '2.287546'
                                          trip.latEnd.should.eql '48.860359'
                                          trip.lonEnd.should.eql '2.352949'
                                          trip.dateTime.should.eql dateTime1
                                          trip.price.should.eql '30'
                                          trip.numberOfPassenger.should.eql '2'
                                          trip.passenger_1.should.eql '0'
                                          trip.passenger_2.should.eql '0'
                                          should.not.exists trip.passenger3
                                          should.not.exists trip.passenger4
                                          client2.trips.setByPassenger user1.id, trip, (err) ->
                                            return next err if err
                                            client2.trips.getByPassenger user1.id, (err, trips) ->
                                              return next err if err
                                              trips.length.should.eql 1
                                              trips[0].id.should.eql '0'
                                              trips[0].dateTime.should.eql dateTime1
                                              client2.trips.get '1', (err, trip) ->
                                                return next err if err
                                                trip.latStart.should.eql '48.856470'
                                                trip.lonStart.should.eql '2.286001'
                                                trip.latEnd.should.eql '48.865314'
                                                trip.lonEnd.should.eql '2.321514'
                                                trip.dateTime.should.eql dateTime2
                                                trip.price.should.eql '17'
                                                trip.numberOfPassenger.should.eql '1'
                                                trip.passenger_1.should.eql '1'
                                                should.not.exists trip.passenger_2
                                                should.not.exists trip.passenger_3
                                                should.not.exists trip.passenger_4
                                                client2.trips.setByPassenger user2.id, trip, (err) ->
                                                  return next err if err
                                                  client2.trips.getByPassenger user2.id, (err, trips) ->
                                                    return next err if err
                                                    trips.length.should.eql 1
                                                    trips[0].id.should.eql '1'
                                                    trips[0].dateTime.should.eql dateTime2
                                                    client2.trips.get '2', (err, trip) ->
                                                      return next err if err
                                                      trip.latStart.should.eql '48.857460'
                                                      trip.lonStart.should.eql '2.291070'
                                                      trip.latEnd.should.eql '48.867158'
                                                      trip.lonEnd.should.eql '2.313901'
                                                      trip.dateTime.should.eql dateTime3
                                                      trip.price.should.eql '17'
                                                      trip.numberOfPassenger.should.eql '1'
                                                      trip.passenger_1.should.eql '3'
                                                      should.not.exists trip.passenger_2
                                                      should.not.exists trip.passenger_3
                                                      should.not.exists trip.passenger_4
                                                      client2.trips.setByPassenger user4.id, trip, (err) ->
                                                        return next err if err
                                                        client2.trips.getByPassenger user4.id, (err, trips) ->
                                                          return next err if err
                                                          trips.length.should.eql 1
                                                          trips[0].id.should.eql '2'
                                                          trips[0].dateTime.should.eql dateTime3
                                                          client2.close()
                                                          session =
                                                            userId: user4.id
                                                          client3 = db "#{__dirname}/../db/tmp/trip"
                                                          client3.trips.getByPassengerTripInProgress session.userId, moment(), (err, trip) ->
                                                            trip.id.should.eql '2'
                                                            trip.dateTime.should.eql dateTime3
                                                            ###if trip.id
                                                              console.log "Un trajet est en cours"
                                                            else
                                                              console.log "Aucun trajet en cours"###
                                                            session =
                                                              userId: user3.id
                                                            client3.trips.getByPassengerTripInProgress session.userId, moment(), (err, trip) ->
                                                              trip.should.eql {}
                                                              ###if trip.id
                                                                console.log "Un trajet est en cours"
                                                              else
                                                                console.log "Aucun trajet en cours"###
                                                              client3.close()
                                                              next()

  it 'Get trip data', (next) ->
    this.timeout 10000
    dateTime1 = moment().add(30, 'm').format "DD-MM-YYYY H:mm"
    dateTime2 = moment().add(1, 'h').format "DD-MM-YYYY H:mm"
    dateTime3 = moment().add(90, 'm').format "DD-MM-YYYY H:mm"
    user1 =
      email: 'dorian@ethylocle.com'
      password: '1234'
    user2 =
      email: 'maoqiao@ethylocle.com'
      password: '4321'
    user3 =
      email: 'robin@ethylocle.com'
      password: '4321'
    user4 =
      email: 'pierre@ethylocle.com'
      password: '4321'
    client1 = db "#{__dirname}/../db/tmp/user"
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
                client1.users.getMaxId (err, maxId) ->
                  return next err if err
                  user3.id = ++maxId
                  client1.users.set user3.id, user3, (err) ->
                    return next err if err
                    client1.users.setByEmail user3.email, user3, (err) ->
                      return next err if err
                      client1.users.getMaxId (err, maxId) ->
                        return next err if err
                        user4.id = ++maxId
                        client1.users.set user4.id, user4, (err) ->
                          return next err if err
                          client1.users.setByEmail user4.email, user4, (err) ->
                            return next err if err
                            client1.close()
                            client2 = db "#{__dirname}/../db/tmp/trip"
                            client2.trips.getMaxId (err, maxId) ->
                              return next err if err
                              maxId.should.eql '-1'
                              client2.trips.set ++maxId,
                                latStart: '48.853611'
                                lonStart: '2.287546'
                                latEnd: '48.860359'
                                lonEnd: '2.352949'
                                dateTime: dateTime1
                                price: '30'
                                numberOfPassenger: '2'
                                passenger_1: user1.id
                                passenger_2: user1.id
                              , (err) ->
                                return next err if err
                                client2.trips.getMaxId (err, maxId) ->
                                  return next err if err
                                  maxId.should.eql '0'
                                  client2.trips.set ++maxId,
                                    latStart: '48.856470'
                                    lonStart: '2.286001'
                                    latEnd: '48.865314'
                                    lonEnd: '2.321514'
                                    dateTime: dateTime2
                                    price: '17'
                                    numberOfPassenger: '1'
                                    passenger_1: user2.id
                                  , (err) ->
                                    return next err if err
                                    client2.trips.getMaxId (err, maxId) ->
                                      return next err if err
                                      maxId.should.eql '1'
                                      client2.trips.set ++maxId,
                                        latStart: '48.857460'
                                        lonStart: '2.291070'
                                        latEnd: '48.867158'
                                        lonEnd: '2.313901'
                                        dateTime: dateTime3
                                        price: '17'
                                        numberOfPassenger: '1'
                                        passenger_1: user4.id
                                      , (err) ->
                                        return next err if err
                                        client2.trips.get '0', (err, trip) ->
                                          return next err if err
                                          trip.latStart.should.eql '48.853611'
                                          trip.lonStart.should.eql '2.287546'
                                          trip.latEnd.should.eql '48.860359'
                                          trip.lonEnd.should.eql '2.352949'
                                          trip.dateTime.should.eql dateTime1
                                          trip.price.should.eql '30'
                                          trip.numberOfPassenger.should.eql '2'
                                          trip.passenger_1.should.eql '0'
                                          trip.passenger_2.should.eql '0'
                                          should.not.exists trip.passenger3
                                          should.not.exists trip.passenger4
                                          client2.trips.setByPassenger user1.id, trip, (err) ->
                                            return next err if err
                                            client2.trips.getByPassenger user1.id, (err, trips) ->
                                              return next err if err
                                              trips.length.should.eql 1
                                              trips[0].id.should.eql '0'
                                              trips[0].dateTime.should.eql dateTime1
                                              client2.trips.get '1', (err, trip) ->
                                                return next err if err
                                                trip.latStart.should.eql '48.856470'
                                                trip.lonStart.should.eql '2.286001'
                                                trip.latEnd.should.eql '48.865314'
                                                trip.lonEnd.should.eql '2.321514'
                                                trip.dateTime.should.eql dateTime2
                                                trip.price.should.eql '17'
                                                trip.numberOfPassenger.should.eql '1'
                                                trip.passenger_1.should.eql '1'
                                                should.not.exists trip.passenger_2
                                                should.not.exists trip.passenger_3
                                                should.not.exists trip.passenger_4
                                                client2.trips.setByPassenger user2.id, trip, (err) ->
                                                  return next err if err
                                                  client2.trips.getByPassenger user2.id, (err, trips) ->
                                                    return next err if err
                                                    trips.length.should.eql 1
                                                    trips[0].id.should.eql '1'
                                                    trips[0].dateTime.should.eql dateTime2
                                                    client2.trips.get '2', (err, trip) ->
                                                      return next err if err
                                                      trip.latStart.should.eql '48.857460'
                                                      trip.lonStart.should.eql '2.291070'
                                                      trip.latEnd.should.eql '48.867158'
                                                      trip.lonEnd.should.eql '2.313901'
                                                      trip.dateTime.should.eql dateTime3
                                                      trip.price.should.eql '17'
                                                      trip.numberOfPassenger.should.eql '1'
                                                      trip.passenger_1.should.eql '3'
                                                      should.not.exists trip.passenger_2
                                                      should.not.exists trip.passenger_3
                                                      should.not.exists trip.passenger_4
                                                      client2.trips.setByPassenger user4.id, trip, (err) ->
                                                        return next err if err
                                                        client2.trips.getByPassenger user4.id, (err, trips) ->
                                                          return next err if err
                                                          trips.length.should.eql 1
                                                          trips[0].id.should.eql '2'
                                                          trips[0].dateTime.should.eql dateTime3
                                                          client2.close()
                                                          session =
                                                            userId: user4.id
                                                          client3 = db "#{__dirname}/../db/tmp/trip"
                                                          client3.trips.getByPassengerTripInProgress session.userId, moment(), (err, trip) ->
                                                            return next err if err
                                                            trip.id.should.eql '2'
                                                            trip.dateTime.should.eql dateTime3
                                                            if trip.id
                                                              client3.trips.get trip.id, (err, trip) ->
                                                                return next err if err
                                                                trip.latStart.should.eql '48.857460'
                                                                trip.lonStart.should.eql '2.291070'
                                                                trip.latEnd.should.eql '48.867158'
                                                                trip.lonEnd.should.eql '2.313901'
                                                                trip.dateTime.should.eql dateTime3
                                                                trip.price.should.eql '17'
                                                                trip.numberOfPassenger.should.eql '1'
                                                                trip.passenger_1.should.eql '3'
                                                                should.not.exists trip.passenger_2
                                                                should.not.exists trip.passenger_3
                                                                should.not.exists trip.passenger_4
                                                                client3.close()
                                                                next()

  it 'Join trip', (next) ->
    this.timeout 10000
    dateTime1 = moment().add(30, 'm').format "DD-MM-YYYY H:mm"
    dateTime2 = moment().add(1, 'h').format "DD-MM-YYYY H:mm"
    dateTime3 = moment().add(90, 'm').format "DD-MM-YYYY H:mm"
    user1 =
      email: 'dorian@ethylocle.com'
      password: '1234'
    user2 =
      email: 'maoqiao@ethylocle.com'
      password: '4321'
    user3 =
      email: 'robin@ethylocle.com'
      password: '4321'
    user4 =
      email: 'pierre@ethylocle.com'
      password: '4321'
    client1 = db "#{__dirname}/../db/tmp/user"
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
                client1.users.getMaxId (err, maxId) ->
                  return next err if err
                  user3.id = ++maxId
                  client1.users.set user3.id, user3, (err) ->
                    return next err if err
                    client1.users.setByEmail user3.email, user3, (err) ->
                      return next err if err
                      client1.users.getMaxId (err, maxId) ->
                        return next err if err
                        user4.id = ++maxId
                        client1.users.set user4.id, user4, (err) ->
                          return next err if err
                          client1.users.setByEmail user4.email, user4, (err) ->
                            return next err if err
                            client1.close()
                            client2 = db "#{__dirname}/../db/tmp/trip"
                            client2.trips.getMaxId (err, maxId) ->
                              return next err if err
                              maxId.should.eql '-1'
                              client2.trips.set ++maxId,
                                latStart: '48.853611'
                                lonStart: '2.287546'
                                latEnd: '48.860359'
                                lonEnd: '2.352949'
                                dateTime: dateTime1
                                price: '30'
                                numberOfPassenger: '2'
                                passenger_1: user1.id
                                passenger_2: user1.id
                              , (err) ->
                                return next err if err
                                client2.trips.getMaxId (err, maxId) ->
                                  return next err if err
                                  maxId.should.eql '0'
                                  client2.trips.set ++maxId,
                                    latStart: '48.856470'
                                    lonStart: '2.286001'
                                    latEnd: '48.865314'
                                    lonEnd: '2.321514'
                                    dateTime: dateTime2
                                    price: '17'
                                    numberOfPassenger: '1'
                                    passenger_1: user2.id
                                  , (err) ->
                                    return next err if err
                                    client2.trips.getMaxId (err, maxId) ->
                                      return next err if err
                                      maxId.should.eql '1'
                                      client2.trips.set ++maxId,
                                        latStart: '48.857460'
                                        lonStart: '2.291070'
                                        latEnd: '48.867158'
                                        lonEnd: '2.313901'
                                        dateTime: dateTime3
                                        price: '17'
                                        numberOfPassenger: '1'
                                        passenger_1: user4.id
                                      , (err) ->
                                        return next err if err
                                        client2.trips.get '0', (err, trip) ->
                                          return next err if err
                                          trip.latStart.should.eql '48.853611'
                                          trip.lonStart.should.eql '2.287546'
                                          trip.latEnd.should.eql '48.860359'
                                          trip.lonEnd.should.eql '2.352949'
                                          trip.dateTime.should.eql dateTime1
                                          trip.price.should.eql '30'
                                          trip.numberOfPassenger.should.eql '2'
                                          trip.passenger_1.should.eql '0'
                                          trip.passenger_2.should.eql '0'
                                          should.not.exists trip.passenger3
                                          should.not.exists trip.passenger4
                                          client2.trips.setByPassenger user1.id, trip, (err) ->
                                            return next err if err
                                            client2.trips.getByPassenger user1.id, (err, trips) ->
                                              return next err if err
                                              trips.length.should.eql 1
                                              trips[0].id.should.eql '0'
                                              trips[0].dateTime.should.eql dateTime1
                                              client2.trips.get '1', (err, trip) ->
                                                return next err if err
                                                trip.latStart.should.eql '48.856470'
                                                trip.lonStart.should.eql '2.286001'
                                                trip.latEnd.should.eql '48.865314'
                                                trip.lonEnd.should.eql '2.321514'
                                                trip.dateTime.should.eql dateTime2
                                                trip.price.should.eql '17'
                                                trip.numberOfPassenger.should.eql '1'
                                                trip.passenger_1.should.eql '1'
                                                should.not.exists trip.passenger_2
                                                should.not.exists trip.passenger_3
                                                should.not.exists trip.passenger_4
                                                client2.trips.setByPassenger user2.id, trip, (err) ->
                                                  return next err if err
                                                  client2.trips.getByPassenger user2.id, (err, trips) ->
                                                    return next err if err
                                                    trips.length.should.eql 1
                                                    trips[0].id.should.eql '1'
                                                    trips[0].dateTime.should.eql dateTime2
                                                    client2.trips.get '2', (err, trip) ->
                                                      return next err if err
                                                      trip.latStart.should.eql '48.857460'
                                                      trip.lonStart.should.eql '2.291070'
                                                      trip.latEnd.should.eql '48.867158'
                                                      trip.lonEnd.should.eql '2.313901'
                                                      trip.dateTime.should.eql dateTime3
                                                      trip.price.should.eql '17'
                                                      trip.numberOfPassenger.should.eql '1'
                                                      trip.passenger_1.should.eql '3'
                                                      should.not.exists trip.passenger_2
                                                      should.not.exists trip.passenger_3
                                                      should.not.exists trip.passenger_4
                                                      client2.trips.setByPassenger user4.id, trip, (err) ->
                                                        return next err if err
                                                        client2.trips.getByPassenger user4.id, (err, trips) ->
                                                          return next err if err
                                                          trips.length.should.eql 1
                                                          trips[0].id.should.eql '2'
                                                          trips[0].dateTime.should.eql dateTime3
                                                          client2.close()
                                                          session =
                                                            userId: user3.id
                                                          body =
                                                            id: '2'
                                                            numberOfPeople: '2'
                                                          client3 = db "#{__dirname}/../db/tmp/trip"
                                                          client3.trips.getByPassengerTripInProgress session.userId, moment(), (err, trip) ->
                                                            return next err if err
                                                            should.not.exists trip.id
                                                            client3.trips.get body.id, (err, trip) ->
                                                              return next err if err
                                                              trip.numberOfPassenger.should.eql '1'
                                                              room = 4 - +trip.numberOfPassenger
                                                              room.should.eql 3
                                                              data = {}
                                                              data.numberOfPassenger = +trip.numberOfPassenger + +body.numberOfPeople
                                                              data.numberOfPassenger.should.eql 3
                                                              i = trip.numberOfPassenger
                                                              while i < data.numberOfPassenger
                                                                data["passenger_" + ++i] = session.userId
                                                              client3.trips.set body.id, data, (err) ->
                                                                return next err if err
                                                                client3.trips.get body.id, (err, trip) ->
                                                                  return next err if err
                                                                  client3.trips.setByPassenger session.userId, trip, (err) ->
                                                                    return next err if err
                                                                    client3.trips.getByPassengerTripInProgress session.userId, moment(), (err, trip) ->
                                                                      return next err if err
                                                                      trip.id.should.eql '2'
                                                                      trip.dateTime.should.eql dateTime3
                                                                      client3.trips.get trip.id, (err, trip) ->
                                                                        return next err if err
                                                                        trip.latStart.should.eql '48.857460'
                                                                        trip.lonStart.should.eql '2.291070'
                                                                        trip.latEnd.should.eql '48.867158'
                                                                        trip.lonEnd.should.eql '2.313901'
                                                                        trip.dateTime.should.eql dateTime3
                                                                        trip.price.should.eql '17'
                                                                        trip.numberOfPassenger.should.eql '3'
                                                                        trip.passenger_1.should.eql '3'
                                                                        trip.passenger_2.should.eql '2'
                                                                        trip.passenger_3.should.eql '2'
                                                                        should.not.exists trip.passenger_4
                                                                        client3.close()
                                                                        next()
