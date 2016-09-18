rimraf = require 'rimraf'
should = require 'should'

db = require '../down'
rideSearch = require '../rideSearch'

geolib = require 'geolib'
moment = require 'moment'

describe 'Ride search', ->

  ###beforeEach (next) ->
    rimraf "#{__dirname}/../../../db/tmp/ridesearch", ->
      rimraf "#{__dirname}/../../../db/tmp/ride", ->
        rimraf "#{__dirname}/../../../db/tmp/user", next

  it 'Insert and get an element in ride search database', (next) ->
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
    client1 = db "#{__dirname}/../../../db/tmp/user"
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
                      client2 = db "#{__dirname}/../../../db/tmp/ride"
                      client2.rides.getMaxId (err, maxId) ->
                        return next err if err
                        maxId.should.eql '-1'
                        client2.rides.set ++maxId,
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
                          client2.rides.getMaxId (err, maxId) ->
                            return next err if err
                            maxId.should.eql '0'
                            client2.rides.set ++maxId,
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
                              client2.rides.get '0', (err, ride) ->
                                return next err if err
                                ride.latStart.should.eql '48.853611'
                                ride.lonStart.should.eql '2.287546'
                                ride.latEnd.should.eql '48.860359'
                                ride.lonEnd.should.eql '2.352949'
                                ride.dateTime.should.eql dateTime1
                                ride.price.should.eql '30'
                                ride.numberOfPassenger.should.eql '2'
                                ride.passenger_1.should.eql '0'
                                ride.passenger_2.should.eql '0'
                                should.not.exists ride.passenger_3
                                should.not.exists ride.passenger_4
                                client2.rides.get '1', (err, ride) ->
                                  return next err if err
                                  ride.latStart.should.eql '48.856470'
                                  ride.lonStart.should.eql '2.286001'
                                  ride.latEnd.should.eql '48.865314'
                                  ride.lonEnd.should.eql '2.321514'
                                  ride.dateTime.should.eql dateTime2
                                  ride.price.should.eql '17'
                                  ride.numberOfPassenger.should.eql '1'
                                  ride.passenger_1.should.eql '1'
                                  should.not.exists ride.passenger_2
                                  should.not.exists ride.passenger_3
                                  should.not.exists ride.passenger_4
                                  body =
                                    latStart: '48.856470'
                                    lonStart: '2.286001'
                                    latEnd: '48.865314'
                                    lonEnd: '2.321514'
                                    dateTime: moment().add(25, 'm').format "DD-MM-YYYY H:mm"
                                    numberOfPeople: 2
                                  client2.rides.get '1', (err, ride) ->
                                    return next err if err
                                    distanceStart = geolib.getDistance {latitude: body.latStart, longitude: body.lonStart}, {latitude: ride.latStart, longitude: ride.lonStart}
                                    distanceEnd = geolib.getDistance {latitude: body.latEnd, longitude: body.lonEnd}, {latitude: ride.latEnd, longitude: ride.lonEnd}
                                    distanceStart.should.eql 0
                                    distanceEnd.should.eql 0
                                    distance = distanceStart + distanceEnd
                                    distance.should.eql 0
                                    client3 = db "#{__dirname}/../../../db/tmp/ridesearch"
                                    client3.ridesearch.set user3.id, distance, ride.id, (err) ->
                                      return next err if err
                                      client3.ridesearch.get user3.id, distance, ride.id, (err, result) ->
                                        result.distance.should.eql "#{distance}"
                                        client2.rides.get '0', (err, ride) ->
                                          return next err if err
                                          client2.close()
                                          distanceStart = geolib.getDistance {latitude: body.latStart, longitude: body.lonStart}, {latitude: ride.latStart, longitude: ride.lonStart}
                                          distanceEnd = geolib.getDistance {latitude: body.latEnd, longitude: body.lonEnd}, {latitude: ride.latEnd, longitude: ride.lonEnd}
                                          distanceStart.should.eql 338
                                          distanceEnd.should.eql 2371
                                          distance = distanceStart + distanceEnd
                                          distance.should.eql 338+2371
                                          client3.ridesearch.set user3.id, distance, ride.id, (err) ->
                                            return next err if err
                                            client3.ridesearch.get user3.id, distance, ride.id, (err, result) ->
                                              result.distance.should.eql "#{distance}"
                                              client3.close()
                                              next()

  it 'Get the best ride thanks to the ride search engine', (next) ->
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
    client1 = db "#{__dirname}/../../../db/tmp/user"
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
                            client2 = db "#{__dirname}/../../../db/tmp/ride"
                            client2.rides.getMaxId (err, maxId) ->
                              return next err if err
                              maxId.should.eql '-1'
                              client2.rides.set ++maxId,
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
                                client2.rides.getMaxId (err, maxId) ->
                                  return next err if err
                                  maxId.should.eql '0'
                                  client2.rides.set ++maxId,
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
                                    client2.rides.getMaxId (err, maxId) ->
                                      return next err if err
                                      maxId.should.eql '1'
                                      client2.rides.set ++maxId,
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
                                        client2.rides.get '0', (err, ride) ->
                                          return next err if err
                                          ride.latStart.should.eql '48.853611'
                                          ride.lonStart.should.eql '2.287546'
                                          ride.latEnd.should.eql '48.860359'
                                          ride.lonEnd.should.eql '2.352949'
                                          ride.dateTime.should.eql dateTime1
                                          ride.price.should.eql '30'
                                          ride.numberOfPassenger.should.eql '2'
                                          ride.passenger_1.should.eql '0'
                                          ride.passenger_2.should.eql '0'
                                          should.not.exists ride.passenger_3
                                          should.not.exists ride.passenger_4
                                          client2.rides.get '1', (err, ride) ->
                                            return next err if err
                                            ride.latStart.should.eql '48.856470'
                                            ride.lonStart.should.eql '2.286001'
                                            ride.latEnd.should.eql '48.865314'
                                            ride.lonEnd.should.eql '2.321514'
                                            ride.dateTime.should.eql dateTime2
                                            ride.price.should.eql '17'
                                            ride.numberOfPassenger.should.eql '1'
                                            ride.passenger_1.should.eql '1'
                                            should.not.exists ride.passenger_2
                                            should.not.exists ride.passenger_3
                                            should.not.exists ride.passenger_4
                                            client2.rides.get '2', (err, ride) ->
                                              return next err if err
                                              ride.latStart.should.eql '48.857460'
                                              ride.lonStart.should.eql '2.291070'
                                              ride.latEnd.should.eql '48.867158'
                                              ride.lonEnd.should.eql '2.313901'
                                              ride.dateTime.should.eql dateTime3
                                              ride.price.should.eql '17'
                                              ride.numberOfPassenger.should.eql '1'
                                              ride.passenger_1.should.eql '3'
                                              should.not.exists ride.passenger_2
                                              should.not.exists ride.passenger_3
                                              should.not.exists ride.passenger_4
                                              client2.close()
                                              body =
                                                latStart: '48.856470'
                                                lonStart: '2.286001'
                                                latEnd: '48.865314'
                                                lonEnd: '2.321514'
                                                dateTime: moment().add(25, 'm').format "DD-MM-YYYY H:mm"
                                                numberOfPeople: '2'
                                              rideSearch "#{__dirname}/../../../db/tmp", 2, body, (err, rides) ->
                                                should.not.exists err
                                                rides.length.should.eql 3
                                                for k, v of rides
                                                  console.log v
                                                next()

  it 'Test the ride search engine without entry values', (next) ->
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
    client1 = db "#{__dirname}/../../../db/tmp/user"
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
                            client2 = db "#{__dirname}/../../../db/tmp/ride"
                            client2.rides.getMaxId (err, maxId) ->
                              return next err if err
                              maxId.should.eql '-1'
                              client2.rides.set ++maxId,
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
                                client2.rides.getMaxId (err, maxId) ->
                                  return next err if err
                                  maxId.should.eql '0'
                                  client2.rides.set ++maxId,
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
                                    client2.rides.getMaxId (err, maxId) ->
                                      return next err if err
                                      maxId.should.eql '1'
                                      client2.rides.set ++maxId,
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
                                        client2.rides.get '0', (err, ride) ->
                                          return next err if err
                                          ride.latStart.should.eql '48.853611'
                                          ride.lonStart.should.eql '2.287546'
                                          ride.latEnd.should.eql '48.860359'
                                          ride.lonEnd.should.eql '2.352949'
                                          ride.dateTime.should.eql dateTime1
                                          ride.price.should.eql '30'
                                          ride.numberOfPassenger.should.eql '2'
                                          ride.passenger_1.should.eql '0'
                                          ride.passenger_2.should.eql '0'
                                          should.not.exists ride.passenger_3
                                          should.not.exists ride.passenger_4
                                          client2.rides.get '1', (err, ride) ->
                                            return next err if err
                                            ride.latStart.should.eql '48.856470'
                                            ride.lonStart.should.eql '2.286001'
                                            ride.latEnd.should.eql '48.865314'
                                            ride.lonEnd.should.eql '2.321514'
                                            ride.dateTime.should.eql dateTime2
                                            ride.price.should.eql '17'
                                            ride.numberOfPassenger.should.eql '1'
                                            ride.passenger_1.should.eql '1'
                                            should.not.exists ride.passenger_2
                                            should.not.exists ride.passenger_3
                                            should.not.exists ride.passenger_4
                                            client2.rides.get '2', (err, ride) ->
                                              return next err if err
                                              ride.latStart.should.eql '48.857460'
                                              ride.lonStart.should.eql '2.291070'
                                              ride.latEnd.should.eql '48.867158'
                                              ride.lonEnd.should.eql '2.313901'
                                              ride.dateTime.should.eql dateTime3
                                              ride.price.should.eql '17'
                                              ride.numberOfPassenger.should.eql '1'
                                              ride.passenger_1.should.eql '3'
                                              should.not.exists ride.passenger_2
                                              should.not.exists ride.passenger_3
                                              should.not.exists ride.passenger_4
                                              client2.close()
                                              rideSearch "#{__dirname}/../../../db/tmp", '2', {}, (err, rides) ->
                                                should.not.exists err
                                                rides.should.eql []
                                                next()

  it 'Test the ride search engine without rides', (next) ->
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
    client1 = db "#{__dirname}/../../../db/tmp/user"
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
                            rideSearch "#{__dirname}/../../../db/tmp", '2', body, (err, rides) ->
                              should.not.exists err
                              rides.should.eql []
                              next()

  it 'Test the ride search engine with an out of date ride', (next) ->
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
    client1 = db "#{__dirname}/../../../db/tmp/user"
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
                            client2 = db "#{__dirname}/../../../db/tmp/ride"
                            client2.rides.getMaxId (err, maxId) ->
                              return next err if err
                              maxId.should.eql '-1'
                              client2.rides.set ++maxId,
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
                                client2.rides.getMaxId (err, maxId) ->
                                  return next err if err
                                  maxId.should.eql '0'
                                  client2.rides.set ++maxId,
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
                                    client2.rides.getMaxId (err, maxId) ->
                                      return next err if err
                                      maxId.should.eql '1'
                                      client2.rides.set ++maxId,
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
                                        client2.rides.get '0', (err, ride) ->
                                          return next err if err
                                          ride.latStart.should.eql '48.853611'
                                          ride.lonStart.should.eql '2.287546'
                                          ride.latEnd.should.eql '48.860359'
                                          ride.lonEnd.should.eql '2.352949'
                                          ride.dateTime.should.eql dateTime1
                                          ride.price.should.eql '30'
                                          ride.numberOfPassenger.should.eql '2'
                                          ride.passenger_1.should.eql '0'
                                          ride.passenger_2.should.eql '0'
                                          should.not.exists ride.passenger_3
                                          should.not.exists ride.passenger_4
                                          client2.rides.get '1', (err, ride) ->
                                            return next err if err
                                            ride.latStart.should.eql '48.856470'
                                            ride.lonStart.should.eql '2.286001'
                                            ride.latEnd.should.eql '48.865314'
                                            ride.lonEnd.should.eql '2.321514'
                                            ride.dateTime.should.eql dateTime2
                                            ride.price.should.eql '17'
                                            ride.numberOfPassenger.should.eql '1'
                                            ride.passenger_1.should.eql '1'
                                            should.not.exists ride.passenger_2
                                            should.not.exists ride.passenger_3
                                            should.not.exists ride.passenger_4
                                            client2.rides.get '2', (err, ride) ->
                                              return next err if err
                                              ride.latStart.should.eql '48.857460'
                                              ride.lonStart.should.eql '2.291070'
                                              ride.latEnd.should.eql '48.867158'
                                              ride.lonEnd.should.eql '2.313901'
                                              ride.dateTime.should.eql dateTime3
                                              ride.price.should.eql '17'
                                              ride.numberOfPassenger.should.eql '1'
                                              ride.passenger_1.should.eql '3'
                                              should.not.exists ride.passenger_2
                                              should.not.exists ride.passenger_3
                                              should.not.exists ride.passenger_4
                                              client2.close()
                                              body =
                                                latStart: '48.856470'
                                                lonStart: '2.286001'
                                                latEnd: '48.865314'
                                                lonEnd: '2.321514'
                                                dateTime: moment().add(35, 'm').format "DD-MM-YYYY H:mm"
                                                numberOfPeople: '2'
                                              rideSearch "#{__dirname}/../../../db/tmp", 2, body, (err, rides) ->
                                                should.not.exists err
                                                rides.length.should.eql 2
                                                for k, v of rides
                                                  console.log v
                                                next()

  it 'Test the ride search engine with an overloaded ride', (next) ->
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
    client1 = db "#{__dirname}/../../../db/tmp/user"
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
                            client2 = db "#{__dirname}/../../../db/tmp/ride"
                            client2.rides.getMaxId (err, maxId) ->
                              return next err if err
                              maxId.should.eql '-1'
                              client2.rides.set ++maxId,
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
                                client2.rides.getMaxId (err, maxId) ->
                                  return next err if err
                                  maxId.should.eql '0'
                                  client2.rides.set ++maxId,
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
                                    client2.rides.getMaxId (err, maxId) ->
                                      return next err if err
                                      maxId.should.eql '1'
                                      client2.rides.set ++maxId,
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
                                        client2.rides.get '0', (err, ride) ->
                                          return next err if err
                                          ride.latStart.should.eql '48.853611'
                                          ride.lonStart.should.eql '2.287546'
                                          ride.latEnd.should.eql '48.860359'
                                          ride.lonEnd.should.eql '2.352949'
                                          ride.dateTime.should.eql dateTime1
                                          ride.price.should.eql '30'
                                          ride.numberOfPassenger.should.eql '2'
                                          ride.passenger_1.should.eql '0'
                                          ride.passenger_2.should.eql '0'
                                          should.not.exists ride.passenger_3
                                          should.not.exists ride.passenger_4
                                          client2.rides.get '1', (err, ride) ->
                                            return next err if err
                                            ride.latStart.should.eql '48.856470'
                                            ride.lonStart.should.eql '2.286001'
                                            ride.latEnd.should.eql '48.865314'
                                            ride.lonEnd.should.eql '2.321514'
                                            ride.dateTime.should.eql dateTime2
                                            ride.price.should.eql '17'
                                            ride.numberOfPassenger.should.eql '3'
                                            ride.passenger_1.should.eql '1'
                                            ride.passenger_2.should.eql '1'
                                            ride.passenger_3.should.eql '1'
                                            should.not.exists ride.passenger_4
                                            client2.rides.get '2', (err, ride) ->
                                              return next err if err
                                              ride.latStart.should.eql '48.857460'
                                              ride.lonStart.should.eql '2.291070'
                                              ride.latEnd.should.eql '48.867158'
                                              ride.lonEnd.should.eql '2.313901'
                                              ride.dateTime.should.eql dateTime3
                                              ride.price.should.eql '17'
                                              ride.numberOfPassenger.should.eql '1'
                                              ride.passenger_1.should.eql '3'
                                              should.not.exists ride.passenger_2
                                              should.not.exists ride.passenger_3
                                              should.not.exists ride.passenger_4
                                              client2.close()
                                              body =
                                                latStart: '48.856470'
                                                lonStart: '2.286001'
                                                latEnd: '48.865314'
                                                lonEnd: '2.321514'
                                                dateTime: moment().add(25, 'm').format "DD-MM-YYYY H:mm"
                                                numberOfPeople: '2'
                                              rideSearch "#{__dirname}/../../../db/tmp", '2', body, (err, rides) ->
                                                should.not.exists err
                                                rides.length.should.eql 2
                                                next()###
