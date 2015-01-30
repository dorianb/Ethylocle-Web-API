rimraf = require 'rimraf'
should = require 'should'
db = require '../lib/db'
tripSearch = require '../lib/tripsearch'
geolib = require 'geolib'
moment = require 'moment'

describe 'Trip search test', ->

  beforeEach (next) ->
    rimraf "#{__dirname}/../db/tmp/tripsearch", ->
      rimraf "#{__dirname}/../db/tmp/trip", ->
        rimraf "#{__dirname}/../db/tmp/user", next

  it 'Insert and get an element in trip search database', (next) ->
    dateTime1 = moment().add(30, 'm').format "DD-MM-YYYY H:mm"
    dateTime2 = moment().add(1, 'h').format "DD-MM-YYYY H:mm"
    user1 =
      email: 'dorian@ethylocle.com'
      password: '1234'
    user2 =
      email: 'maoqiao@ethylocle.com'
      password: '4321'
    user3 =
      email: 'robin@ethylocle.com'
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
                                  body =
                                    latStart: '48.856470'
                                    lonStart: '2.286001'
                                    latEnd: '48.865314'
                                    lonEnd: '2.321514'
                                    dateTime: moment().add(25, 'm').format "DD-MM-YYYY H:mm"
                                    numberOfPeople: 2
                                  client2.trips.get '1', (err, trip) ->
                                    return next err if err
                                    distanceStart = geolib.getDistance {latitude: body.latStart, longitude: body.lonStart}, {latitude: trip.latStart, longitude: trip.lonStart}
                                    distanceEnd = geolib.getDistance {latitude: body.latEnd, longitude: body.lonEnd}, {latitude: trip.latEnd, longitude: trip.lonEnd}
                                    distanceStart.should.eql 0
                                    distanceEnd.should.eql 0
                                    distance = distanceStart + distanceEnd
                                    distance.should.eql 0
                                    client3 = db "#{__dirname}/../db/tmp/tripsearch"
                                    client3.tripsearch.set user3.id, distance, trip.id, (err) ->
                                      return next err if err
                                      client3.tripsearch.get user3.id, distance, trip.id, (err, result) ->
                                        result.distance.should.eql "#{distance}"
                                        client2.trips.get '0', (err, trip) ->
                                          return next err if err
                                          client2.close()
                                          distanceStart = geolib.getDistance {latitude: body.latStart, longitude: body.lonStart}, {latitude: trip.latStart, longitude: trip.lonStart}
                                          distanceEnd = geolib.getDistance {latitude: body.latEnd, longitude: body.lonEnd}, {latitude: trip.latEnd, longitude: trip.lonEnd}
                                          distanceStart.should.eql 338
                                          distanceEnd.should.eql 2371
                                          distance = distanceStart + distanceEnd
                                          distance.should.eql 338+2371
                                          client3.tripsearch.set user3.id, distance, trip.id, (err) ->
                                            return next err if err
                                            client3.tripsearch.get user3.id, distance, trip.id, (err, result) ->
                                              result.distance.should.eql "#{distance}"
                                              client3.close()
                                              next()

  it 'Get the best trip thanks to the trip search engine', (next) ->
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
                                              client2.close()
                                              body =
                                                latStart: '48.856470'
                                                lonStart: '2.286001'
                                                latEnd: '48.865314'
                                                lonEnd: '2.321514'
                                                dateTime: moment().add(25, 'm').format "DD-MM-YYYY H:mm"
                                                numberOfPeople: '2'
                                              tripSearch "#{__dirname}/../db/tmp", 2, body, (err, trips) ->
                                                should.not.exists err
                                                trips.length.should.eql 3
                                                ###for k, v of trips
                                                  console.log v###
                                                next()

  it 'Test the trip search engine without entry values', (next) ->
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
                                              client2.close()
                                              tripSearch "#{__dirname}/../db/tmp", '2', {}, (err, trips) ->
                                                should.not.exists err
                                                trips.should.eql []
                                                next()

  it 'Test the trip search engine without trips', (next) ->
    this.timeout 10000
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
                            body =
                              latStart: '48.856470'
                              lonStart: '2.286001'
                              latEnd: '48.865314'
                              lonEnd: '2.321514'
                              dateTime: moment().add(25, 'm').format "DD-MM-YYYY H:mm"
                              numberOfPeople: '2'
                            tripSearch "#{__dirname}/../db/tmp", '2', body, (err, trips) ->
                              should.not.exists err
                              trips.should.eql []
                              next()

  it 'Test the trip search engine with an out of date trip', (next) ->
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
                                              client2.close()
                                              body =
                                                latStart: '48.856470'
                                                lonStart: '2.286001'
                                                latEnd: '48.865314'
                                                lonEnd: '2.321514'
                                                dateTime: moment().add(35, 'm').format "DD-MM-YYYY H:mm"
                                                numberOfPeople: '2'
                                              tripSearch "#{__dirname}/../db/tmp", 2, body, (err, trips) ->
                                                should.not.exists err
                                                trips.length.should.eql 2
                                                ###for k, v of trips
                                                  console.log v###
                                                next()

  it 'Test the trip search engine with an overloaded trip', (next) ->
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
                                    numberOfPassenger: '3'
                                    passenger_1: user2.id
                                    passenger_2: user2.id
                                    passenger_3: user2.id
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
                                          client2.trips.get '1', (err, trip) ->
                                            return next err if err
                                            trip.latStart.should.eql '48.856470'
                                            trip.lonStart.should.eql '2.286001'
                                            trip.latEnd.should.eql '48.865314'
                                            trip.lonEnd.should.eql '2.321514'
                                            trip.dateTime.should.eql dateTime2
                                            trip.price.should.eql '17'
                                            trip.numberOfPassenger.should.eql '3'
                                            trip.passenger_1.should.eql '1'
                                            trip.passenger_2.should.eql '1'
                                            trip.passenger_3.should.eql '1'
                                            should.not.exists trip.passenger_4
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
                                              client2.close()
                                              body =
                                                latStart: '48.856470'
                                                lonStart: '2.286001'
                                                latEnd: '48.865314'
                                                lonEnd: '2.321514'
                                                dateTime: moment().add(25, 'm').format "DD-MM-YYYY H:mm"
                                                numberOfPeople: '2'
                                              tripSearch "#{__dirname}/../db/tmp", '2', body, (err, trips) ->
                                                should.not.exists err
                                                trips.length.should.eql 2
                                                next()
