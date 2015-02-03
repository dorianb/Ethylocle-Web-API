rimraf = require 'rimraf'
should = require 'should'
db = require '../lib/db'
moment = require 'moment'

describe 'User test', ->

  beforeEach (next) ->
    rimraf "#{__dirname}/../db/tmp/user", next

  it 'Insert and get user', (next) ->
    user1 =
      email: 'dorian@ethylocle.com'
      password: '1234'
    client = db "#{__dirname}/../db/tmp/user"
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
    client = db "#{__dirname}/../db/tmp/user"
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
    client = db "#{__dirname}/../db/tmp/user"
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
                        next()

  it 'Sign in', (next) ->
    user1 =
      email: 'dorian@ethylocle.com'
      password: '1234'
    user2 =
      email: 'maoqiao@ethylocle.com'
      password: '1234'
    client = db "#{__dirname}/../db/tmp/user"
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
                data =
                  email: 'dorian@ethylocle.com'
                  password: '1234'
                client.users.getByEmail data.email, (err, user) ->
                  return next err if err
                  client.users.get user.id, (err, user) ->
                    return next err if err
                    assertion = user.email is data.email and user.password is data.password
                    assertion.should.eql true
                    client.close()
                    next()

  it 'Sign up', (next) ->
    user1 =
      email: 'dorian@ethylocle.com'
      password: '1234'
    client = db "#{__dirname}/../db/tmp/user"
    client.users.getMaxId (err, maxId) ->
      return next err if err
      user1.id = ++maxId
      client.users.set user1.id, user1, (err) ->
        return next err if err
        client.users.setByEmail user1.email, user1, (err) ->
          return next err if err
          data =
            email: 'dorian@ethylocle.com'
            password: '1234'
          client.users.getByEmail data.email, (err, user) ->
            return next err if err
            assertion = user.email is data.email
            assertion.should.eql true
            data =
              email: 'maoqiao@ethylocle.com'
              password: '1234'
            client.users.getByEmail data.email, (err, user) ->
              return next err if err
              assertion = user.email is data.email
              assertion.should.eql false
              client.users.getMaxId (err, maxId) ->
                return next err if err
                data.id = ++maxId
                client.users.set data.id, data, (err) ->
                  return next err if err
                  client.users.setByEmail data.email, data, (err) ->
                    return next err if err
                    client.users.getByEmail data.email, (err, user) ->
                      return next err if err
                      client.users.get user.id, (err, user) ->
                        return next err if err
                        user.id.should.eql '1'
                        user.email.should.eql 'maoqiao@ethylocle.com'
                        user.password.should.eql '1234'
                        client.users.getByEmail user1.email, (err, user) ->
                          return next err if err
                          client.users.get user.id, (err, user) ->
                            return next err if err
                            user.id.should.eql '0'
                            user.email.should.eql 'dorian@ethylocle.com'
                            user.password.should.eql '1234'
                            client.close()
                            next()

  it 'Update email', (next) ->
    user1 =
      email: "dorian@ethylocle.com"
      picture: "null"
      lastname: "Bagur"
      firstname: "Dorian"
      birthDate: "07-08-1992"
      gender: "M"
      weight: "75.5"
      address: "162 Boulevard du Général de Gaulle"
      zipCode: "78700"
      city: "Conflans-Sainte-Honorine"
      country: "France"
      phone: "+330619768399"
      password: "1234"
    client = db "#{__dirname}/../db/tmp/user"
    client.users.getMaxId (err, maxId) ->
      return next err if err
      user1.id = ++maxId
      client.users.set user1.id, user1, (err) ->
        return next err if err
        client.users.setByEmail user1.email, user1, (err) ->
          return next err if err
          data =
            email: 'alfred@ethylocle.com'
          client.users.getByEmail user1.email, (err, user) ->
            return next err if err
            data.id = user.id
            client.users.delByEmail user.email, user, (err) ->
              return next err if err
              client.users.setByEmail data.email, data, (err) ->
                return next err if err
                client.users.set data.id, data, (err) ->
                  return next err if err
                  client.users.get data.id, (err, user) ->
                    return next err if err
                    user.id.should.eql '0'
                    user.email.should.eql "alfred@ethylocle.com"
                    user.picture.should.eql "null"
                    user.lastname.should.eql "Bagur"
                    user.firstname.should.eql "Dorian"
                    user.birthDate.should.eql "07-08-1992"
                    user.gender.should.eql "M"
                    user.weight.should.eql "75.5"
                    user.address.should.eql "162 Boulevard du Général de Gaulle"
                    user.zipCode.should.eql "78700"
                    user.city.should.eql "Conflans-Sainte-Honorine"
                    user.country.should.eql "France"
                    user.phone.should.eql "+330619768399"
                    user.password.should.eql "1234"
                    client.close()
                    next()

  it 'Update user data', (next) ->
    user1 =
      email: "dorian@ethylocle.com"
      password: "1234"
    client = db "#{__dirname}/../db/tmp/user"
    client.users.getMaxId (err, maxId) ->
      return next err if err
      user1.id = ++maxId
      client.users.set user1.id, user1, (err) ->
        return next err if err
        client.users.setByEmail user1.email, user1, (err) ->
          return next err if err
          firstname = ""
          user1 =
            email: "dorian@ethylocle.com"
            picture: "null"
            lastname: "Bagur"
            firstname: firstname
            birthDate: "07-08-1992"
            gender: "M"
            weight: "75.5"
            address: "162 Boulevard du Général de Gaulle"
            zipCode: "78700"
            city: "Conflans-Sainte-Honorine"
            country: "France"
            phone: "+330619768399"
            password: "1234"
          data = {}
          for k, v of user1
            continue unless v
            data[k] = v
          client.users.getByEmail data.email, (err, user) ->
            return next err if err
            data.id = user.id
            client.users.set data.id, data, (err) ->
              return next err if err
              client.users.get data.id, (err, user) ->
                return next err if err
                user.id.should.eql '0'
                user.email.should.eql "dorian@ethylocle.com"
                user.picture.should.eql "null"
                user.lastname.should.eql "Bagur"
                should.not.exists user.firstname
                user.birthDate.should.eql "07-08-1992"
                user.gender.should.eql "M"
                user.weight.should.eql "75.5"
                user.address.should.eql "162 Boulevard du Général de Gaulle"
                user.zipCode.should.eql "78700"
                user.city.should.eql "Conflans-Sainte-Honorine"
                user.country.should.eql "France"
                user.phone.should.eql "+330619768399"
                user.password.should.eql "1234"
                client.close()
                next()

  it 'Delete user', (next) ->
    user1 =
      email: 'dorian@ethylocle.com'
      password: '1234'
    client = db "#{__dirname}/../db/tmp/user"
    client.users.getMaxId (err, maxId) ->
      return next err if err
      user1.id = ++maxId
      client.users.set user1.id, user1, (err) ->
        return next err if err
        client.users.setByEmail user1.email, user1, (err) ->
          return next err if err
          data =
            id: maxId
          client.close (err) ->
            return next err if err
            client = db "#{__dirname}/../db/trip"
            client.trips.getByPassengerTripInProgress data.id, moment(), (err, trip) ->
              return next err if err
              should.not.exists trip.id
              client.close (err) ->
                client.users.get data.id, (err, user) ->
                  return next err if err
                  client.users.del user.id, user, (err) ->
                    return next err if err
                    client.users.delByEmail user.email, user, (err) ->
                      return next err if err
                      client.users.getByEmail user1.email, (err, user) ->
                        return next err if err
                        user.should.eql {}
                        client.users.get user1.id, (err, user) ->
                          return next err if err
                          user.should.eql {}
                          client.close()
                          next()

  it 'Collection', (next) ->
    user =
      email: 'dorian@ethylocle.com'
      lastname: 'Bagur'
      birthDate: '29-01-1992'
      firstname: ""
    data = {}
    for k, v of user
      continue unless v and k in ["image", "lastname", "firstname", "birthDate", "gender", "weight", "address", "zipCode", "city", "country", "phone", "password", "latitude", "longitude", "lastKnownPositionDate", "bac", "lastBacKnownDate"]
      data[k] = v
    data.lastname.should.eql user.lastname
    should.not.exists data.email
    should.not.exists data.image
    should.not.exists data.firstname
    data.birthDate.should.eql user.birthDate
    should.not.exists data.gender
    should.not.exists data.weight
    should.not.exists data.address
    should.not.exists data.zipCode
    should.not.exists data.city
    should.not.exists data.country
    should.not.exists data.phone
    should.not.exists data.password
    should.not.exists data.latitude
    should.not.exists data.longitude
    should.not.exists data.lastKnownPositionDate
    should.not.exists data.bac
    should.not.exists data.lastBacKnownDate
    next()

  it 'Check email address', (next) ->
    isEmail = (email) ->
      regEmail = new RegExp '^[0-9a-z._-]+@{1}[0-9a-z.-]{2,}[.]{1}[a-z]{2,5}$', 'i'
      regEmail.test email

    emails = new Array 'adressemail@gmail', 'adresse@mel.fr', 'adr@fr.com.eu'

    isEmail(emails[0]).should.eql false
    isEmail(emails[1]).should.eql true
    isEmail(emails[2]).should.eql true
    next()
