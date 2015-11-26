rimraf = require 'rimraf'
should = require 'should'
Up = require '../up'

User = require '../../../entity/user'
Trip = require '../../../entity/trip'
TripCriteria = require '../../../entity/tripCriteria'

moment = require 'moment'

describe 'Up levelDB Model', ->

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

  describe 'Up user methods', ->

    beforeEach (next) ->
      rimraf "#{__dirname}/../../../../db/tmp/user", next

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

    it 'Check password with null password (after signed up)', (next) ->
      body =
        email: 'robin@ethylocle.com'
        password: '1234'
      user = User body
      Up("#{__dirname}/../../../../db/tmp").signUp user, (err, response) ->
        return next err if err
        user.password = null
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

  describe 'Up trip methods', ->

    beforeEach (next) ->
      rimraf "#{__dirname}/../../../../db/tmp/trip", next

    it 'Create trip', (next) ->
      trip =
        latStart: '48.856470'
        lonStart: '2.286001'
        latEnd: '48.865314'
        lonEnd: '2.321514'
        dateTime: moment().add(30, 'm').format "DD-MM-YYYY H:mm"
        numberOfPassenger: '2'
        price: '13.93'
        passenger_1: '0'
        passenger_2: '0'
      Up("#{__dirname}/../../../../db/tmp").createTrip User({id: '0'}), Trip(trip), (err, response) ->
        return next err if err
        Object.keys(response).length.should.eql 2
        response.result.should.eql true
        should.not.exists response.data
        next()

    it 'Has trip after created one in 30 min', (next) ->
      trip =
        latStart: '48.856470'
        lonStart: '2.286001'
        latEnd: '48.865314'
        lonEnd: '2.321514'
        dateTime: moment().add(30, 'm').format "DD-MM-YYYY H:mm"
        numberOfPassenger: '2'
        price: '13.93'
        passenger_1: '0'
        passenger_2: '0'
      Up("#{__dirname}/../../../../db/tmp").createTrip User({id: '0'}), Trip(trip), (err, response) ->
        return next err if err
        Up("#{__dirname}/../../../../db/tmp").hasTrip User({id: '0'}), (err, response) ->
          return next err if err
          Object.keys(response).length.should.eql 2
          response.result.should.eql true
          should.not.exists response.data
          next()

    it 'Has trip after created one in past', (next) ->
      trip =
        latStart: '48.856470'
        lonStart: '2.286001'
        latEnd: '48.865314'
        lonEnd: '2.321514'
        dateTime: moment().add(-10, 'm').format "DD-MM-YYYY H:mm"
        numberOfPassenger: '2'
        price: '13.93'
        passenger_1: '0'
        passenger_2: '0'
      Up("#{__dirname}/../../../../db/tmp").createTrip User({id: '0'}), Trip(trip), (err, response) ->
        return next err if err
        Up("#{__dirname}/../../../../db/tmp").hasTrip User({id: '0'}), (err, response) ->
          return next err if err
          Object.keys(response).length.should.eql 2
          response.result.should.eql false
          response.data.should.eql "Aucun trajet en cours"
          next()

    it 'Get trip after created one in 30 min', (next) ->
      trip =
        latStart: '48.856470'
        lonStart: '2.286001'
        latEnd: '48.865314'
        lonEnd: '2.321514'
        dateTime: moment().add(30, 'm').format "DD-MM-YYYY H:mm"
        numberOfPassenger: '2'
        price: '13.93'
        passenger_1: '0'
        passenger_2: '0'
      Up("#{__dirname}/../../../../db/tmp").createTrip User({id: '0'}), Trip(trip), (err, response) ->
        return next err if err
        Up("#{__dirname}/../../../../db/tmp").getTrip User({id: '0'}), (err, response) ->
          return next err if err
          Object.keys(response).length.should.eql 2
          response.result.should.eql true
          Object.keys(response.data).length.should.eql 10
          response.data.id.should.eql '0'
          response.data.latStart.should.eql trip.latStart
          response.data.lonStart.should.eql trip.lonStart
          response.data.latEnd.should.eql trip.latEnd
          response.data.lonEnd.should.eql trip.lonEnd
          response.data.dateTime.should.eql trip.dateTime
          response.data.numberOfPassenger.should.eql trip.numberOfPassenger
          response.data.maxPrice.should.eql trip.price
          response.data.passenger_1.should.eql trip.passenger_1
          response.data.passenger_2.should.eql trip.passenger_2
          next()

    it 'Get trip after created one in past', (next) ->
      trip =
        latStart: '48.856470'
        lonStart: '2.286001'
        latEnd: '48.865314'
        lonEnd: '2.321514'
        dateTime: moment().add(-10, 'm').format "DD-MM-YYYY H:mm"
        numberOfPassenger: '2'
        price: '13.93'
        passenger_1: '0'
        passenger_2: '0'
      Up("#{__dirname}/../../../../db/tmp").createTrip User({id: '0'}), Trip(trip), (err, response) ->
        return next err if err
        Up("#{__dirname}/../../../../db/tmp").getTrip User({id: '0'}), (err, response) ->
          return next err if err
          Object.keys(response).length.should.eql 2
          response.result.should.eql false
          response.data.should.eql "Aucun trajet en cours"
          next()

    it 'Get trip without created one', (next) ->
      Up("#{__dirname}/../../../../db/tmp").getTrip User({id: '0'}), (err, response) ->
        return next err if err
        Object.keys(response).length.should.eql 2
        response.result.should.eql false
        response.data.should.eql "Aucun trajet en cours"
        next()

    it 'Get trip by id after created one', (next) ->
      trip =
        latStart: '48.856470'
        lonStart: '2.286001'
        latEnd: '48.865314'
        lonEnd: '2.321514'
        dateTime: "07-08-1992 17:00"
        numberOfPassenger: '2'
        price: '13.93'
        passenger_1: '0'
        passenger_2: '0'
      Up("#{__dirname}/../../../../db/tmp").createTrip User({id: '0'}), Trip(trip), (err, response) ->
        return next err if err
        Up("#{__dirname}/../../../../db/tmp").getTripById Trip({id: 0}), (err, response) ->
          return next err if err
          Object.keys(response).length.should.eql 2
          response.result.should.eql true
          Object.keys(response.data).length.should.eql 8
          response.data.id.should.eql '0'
          response.data.latStart.should.eql trip.latStart
          response.data.lonStart.should.eql trip.lonStart
          response.data.latEnd.should.eql trip.latEnd
          response.data.lonEnd.should.eql trip.lonEnd
          response.data.dateTime.should.eql trip.dateTime
          response.data.numberOfPassenger.should.eql trip.numberOfPassenger
          response.data.maxPrice.should.eql (trip.price/2/1.1).toFixed 2
          should.not.exists response.data.passenger_1
          should.not.exists response.data.passenger_2
          next()

    it 'Get trip by id without created one', (next) ->
      Up("#{__dirname}/../../../../db/tmp").getTripById Trip({id: '0'}), (err, response) ->
        return next err if err
        Object.keys(response).length.should.eql 2
        response.result.should.eql false
        response.data.should.eql "Le trajet n'existe plus"
        next()

    it 'Search trip after created three', (next) ->
      this.timeout 3000
      trip =
          latStart: '48.856470'
          lonStart: '2.286001'
          latEnd: '48.865314'
          lonEnd: '2.321514'
          dateTime: moment().add(30, 'm').format "DD-MM-YYYY H:mm"
          numberOfPassenger: '2'
          price: '13.93'
          passenger_1: '0'
          passenger_2: '0'
        Up("#{__dirname}/../../../../db/tmp").createTrip User({id: '0'}), Trip(trip), (err, response) ->
          return next err if err
          trip =
            latStart: '48.853611'
            lonStart: '2.287546'
            latEnd: '48.860359'
            lonEnd: '2.352949'
            dateTime: moment().add(1, 'h').format "DD-MM-YYYY H:mm"
            numberOfPassenger: '1'
            price: '13.93'
            passenger_1: '1'
          Up("#{__dirname}/../../../../db/tmp").createTrip User({id: '1'}), Trip(trip), (err, response) ->
            return next err if err
            trip =
              latStart: '48.857460'
              lonStart: '2.291070'
              latEnd: '48.867158'
              lonEnd: '2.313901'
              dateTime: moment().add(90, 'm').format "DD-MM-YYYY H:mm"
              numberOfPassenger: '3'
              price: '13.93'
              passenger_1: '2'
              passenger_2: '2'
              passenger_3: '2'
            Up("#{__dirname}/../../../../db/tmp").createTrip User({id: '2'}), Trip(trip), (err, response) ->
              return next err if err
              tripCriteria =
                latStart: '48.856470'
                lonStart: '2.286001'
                latEnd: '48.865314'
                lonEnd: '2.321514'
                dateTime: moment().add(25, 'm').format "DD-MM-YYYY H:mm"
                numberOfPeople: '1'
              Up("#{__dirname}/../../../../db/tmp").searchTrip User({id: '3'}), TripCriteria(tripCriteria), (err, response) ->
                return next err if err
                Object.keys(response).length.should.eql 2
                response.result.should.eql true
                Object.keys(response.data).length.should.eql 3
                next()

    it 'Join trip', (next) ->
      trip =
          latStart: '48.856470'
          lonStart: '2.286001'
          latEnd: '48.865314'
          lonEnd: '2.321514'
          dateTime: moment().add(30, 'm').format "DD-MM-YYYY H:mm"
          numberOfPassenger: '2'
          price: '13.93'
          passenger_1: '0'
          passenger_2: '0'
        Up("#{__dirname}/../../../../db/tmp").createTrip User({id: '0'}), Trip(trip), (err, response) ->
          return next err if err
          trip =
            latStart: '48.853611'
            lonStart: '2.287546'
            latEnd: '48.860359'
            lonEnd: '2.352949'
            dateTime: moment().add(1, 'h').format "DD-MM-YYYY H:mm"
            numberOfPassenger: '1'
            price: '13.93'
            passenger_1: '1'
          Up("#{__dirname}/../../../../db/tmp").createTrip User({id: '1'}), Trip(trip), (err, response) ->
            return next err if err
            trip =
              latStart: '48.857460'
              lonStart: '2.291070'
              latEnd: '48.867158'
              lonEnd: '2.313901'
              dateTime: moment().add(90, 'm').format "DD-MM-YYYY H:mm"
              numberOfPassenger: '3'
              price: '13.93'
              passenger_1: '2'
              passenger_2: '2'
              passenger_3: '2'
            Up("#{__dirname}/../../../../db/tmp").createTrip User({id: '2'}), Trip(trip), (err, response) ->
              return next err if err
              body =
                id: '1'
                numberOfPeople: '2'
              Up("#{__dirname}/../../../../db/tmp").joinTrip User({id: '3'}), Trip(body), TripCriteria(body), (err, response) ->
                return next err if err
                Object.keys(response).length.should.eql 2
                response.result.should.eql true
                should.not.exists response.data
                next()

    it 'Join trip with an unexisting trip', (next) ->
      body =
        id: '1'
        numberOfPeople: '2'
      Up("#{__dirname}/../../../../db/tmp").joinTrip User({id: '0'}), Trip(body), TripCriteria(body), (err, response) ->
        return next err if err
        Object.keys(response).length.should.eql 2
        response.result.should.eql false
        response.data.should.eql "Le trajet n'existe plus"
        next()

    it 'Join trip with an overloaded trip', (next) ->
      trip =
          latStart: '48.856470'
          lonStart: '2.286001'
          latEnd: '48.865314'
          lonEnd: '2.321514'
          dateTime: moment().add(30, 'm').format "DD-MM-YYYY H:mm"
          numberOfPassenger: '3'
          price: '13.93'
          passenger_1: '0'
          passenger_2: '0'
          passenger_3: '0'
        Up("#{__dirname}/../../../../db/tmp").createTrip User({id: '0'}), Trip(trip), (err, response) ->
          return next err if err
          body =
            id: '0'
            numberOfPeople: '2'
          Up("#{__dirname}/../../../../db/tmp").joinTrip User({id: '1'}), Trip(body), TripCriteria(body), (err, response) ->
            return next err if err
            Object.keys(response).length.should.eql 2
            response.result.should.eql false
            response.data.should.eql "Il n'y a plus assez de places disponibles pour ce trajet"
            next()
