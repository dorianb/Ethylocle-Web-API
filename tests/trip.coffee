rimraf = require 'rimraf'
should = require 'should'
db = require '../lib/db'

describe 'Trip test', ->

  beforeEach (next) ->
    rimraf "#{__dirname}/../db/tmp", next

  it 'Insert and get a trip', (next) ->
    client = db "#{__dirname}/../db/tmp"
    client.users.set 'dorian@ethylocle.com',
      email: 'dorian@ethylocle.com'
      password: '1234'
    , (err) ->
      return next err if err
      client.trips.set 'dorian@ethylocle.com',
        latStart: '48.853611'
        lonStart: '2.287546'
        latEnd: '48.860359'
        lonEnd: '2.352949'
        dateTime: 'dd-MM-yyyy HH:mm'
        price: '30'
        passenger2: 'dorian@ethylocle.com'
      , (err) ->
        return next err if err
        client.trips.get 'dorian@ethylocle.com', (err, trip) ->
          return next err if err
          trip.owner.should.eql 'dorian@ethylocle.com'
          trip.latStart.should.eql '48.853611'
          trip.lonStart.should.eql '2.287546'
          trip.latEnd.should.eql '48.860359'
          trip.lonEnd.should.eql '2.352949'
          trip.dateTime.should.eql 'dd-MM-yyyy HH:mm'
          trip.price.should.eql '30'
          trip.passenger2.should.eql 'dorian@ethylocle.com'
          should.not.exists trip.passenger3
          should.not.exists trip.passenger4
          client.close()
          next()

  it 'Insert two trips and get a single one', (next) ->
    client = db "#{__dirname}/../db/tmp"
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
        client.trips.set 'dorian@ethylocle.com',
          latStart: '48.853611'
          lonStart: '2.287546'
          latEnd: '48.860359'
          lonEnd: '2.352949'
          dateTime: '22-01-2015 16:02:29'
          price: '30'
          passenger2: 'dorian@ethylocle.com'
        , (err) ->
          return next err if err
          client.trips.set 'maoqiao@ethylocle.com',
            latStart: '48.856470'
            lonStart: '2.286001'
            latEnd: '48.865314'
            lonEnd: '2.321514'
            dateTime: '22-01-2015 16:30:19'
            price: '17'
          , (err) ->
            return next err if err
            client.trips.get 'dorian@ethylocle.com', (err, trip) ->
              return next err if err
              trip.owner.should.eql 'dorian@ethylocle.com'
              trip.latStart.should.eql '48.853611'
              trip.lonStart.should.eql '2.287546'
              trip.latEnd.should.eql '48.860359'
              trip.lonEnd.should.eql '2.352949'
              trip.dateTime.should.eql '22-01-2015 16:02:29'
              trip.price.should.eql '30'
              trip.passenger2.should.eql 'dorian@ethylocle.com'
              should.not.exists trip.passenger3
              should.not.exists trip.passenger4
              client.trips.get 'maoqiao@ethylocle.com', (err, trip) ->
                return next err if err
                trip.owner.should.eql 'maoqiao@ethylocle.com'
                trip.latStart.should.eql '48.856470'
                trip.lonStart.should.eql '2.286001'
                trip.latEnd.should.eql '48.865314'
                trip.lonEnd.should.eql '2.321514'
                trip.dateTime.should.eql '22-01-2015 16:30:19'
                trip.price.should.eql '17'
                should.not.exists trip.passenger2
                should.not.exists trip.passenger3
                should.not.exists trip.passenger4
                client.close()
                next()

  it 'Create a trip for 1 person', (next) ->
    session = 'dorian@ethylocle.com'
    body =
      latStart: '48.856470'
      lonStart: '2.286001'
      latEnd: '48.865314'
      lonEnd: '2.321514'
      dateTime: '22-01-2015 16:30:19'
      numberOfPeople: '1'
    if body.numberOfPeople > 2
      console.log "Impossible de créer un trajet pour plus de 2 personnes"
    else
      client = db "#{__dirname}/../db"
      data = {}
      for k, v of body
        continue unless v
        if k is 'numberOfPeople'
          i = 1
          while i < v
            data["passenger" + ++i] = session
          should.not.exists data.passenger2
          should.not.exists data.passenger3
          should.not.exists data.passenger4
        else
          data[k] = v
      for k, v of data
        console.log "Key: " + k + " value: " + v
      data.price = '15' #A déterminer à l'aide de l'api taxi G7
      client.trips.set session, data, (err) ->
        return next err if err
        client.trips.get session, (err, trip) ->
          return next err if err
          trip.owner.should.eql session
          trip.latStart.should.eql '48.856470'
          trip.lonStart.should.eql '2.286001'
          trip.latEnd.should.eql '48.865314'
          trip.lonEnd.should.eql '2.321514'
          trip.dateTime.should.eql '22-01-2015 16:30:19'
          trip.price.should.eql '15'
          should.not.exists trip.passenger2
          should.not.exists trip.passenger3
          should.not.exists trip.passenger4
          client.close()
          next()

  it 'Create a trip for 2 persons', (next) ->
    session = 'dorian@ethylocle.com'
    body =
      latStart: '48.856470'
      lonStart: '2.286001'
      latEnd: '48.865314'
      lonEnd: '2.321514'
      dateTime: '22-01-2015 16:30:19'
      numberOfPeople: '2'
    if body.numberOfPeople > 2
      console.log "Impossible de créer un trajet pour plus de 2 personnes"
    else
      client = db "#{__dirname}/../db"
      data = {}
      for k, v of body
        continue unless v
        if k is 'numberOfPeople'
          i = 1
          while i < v
            data["passenger" + ++i] = session
          data.passenger2.should.eql session
          should.not.exists data.passenger3
          should.not.exists data.passenger4
        else
          data[k] = v
      data.price = '15' #A déterminer à l'aide de l'api taxi G7
      client.trips.set session, data, (err) ->
        return next err if err
        client.trips.get session, (err, trip) ->
          return next err if err
          trip.owner.should.eql session
          trip.latStart.should.eql '48.856470'
          trip.lonStart.should.eql '2.286001'
          trip.latEnd.should.eql '48.865314'
          trip.lonEnd.should.eql '2.321514'
          trip.dateTime.should.eql '22-01-2015 16:30:19'
          trip.price.should.eql '15'
          trip.passenger2.should.eql session
          should.not.exists trip.passenger3
          should.not.exists trip.passenger4
          client.close()
          next()

  it 'Create a trip for 3 or more persons', (next) ->
    session = 'dorian@ethylocle.com'
    body =
      latStart: '48.856470'
      lonStart: '2.286001'
      latEnd: '48.865314'
      lonEnd: '2.321514'
      dateTime: '22-01-2015 16:30:19'
      numberOfPeople: '3'
    assertion = body.numberOfPeople > 2
    assertion.should.eql true
