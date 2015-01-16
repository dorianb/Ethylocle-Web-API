rimraf = require 'rimraf'
should = require 'should'
db = require '../lib/db'

describe 'Database', ->

  beforeEach (next) ->
    rimraf "#{__dirname}/../db/tmp", next

  it 'Insert and get user by email', (next) ->
    client = db "#{__dirname}/../db/tmp"
    client.users.set 'dorian@ethylocle.com',
      email: 'dorian@ethylocle.com'
      password: '1234'
    , (err) ->
      return next err if err
      client.users.get 'dorian@ethylocle.com', (err, user) ->
        return next err if err
        user.email.should.eql 'dorian@ethylocle.com'
        user.password.should.eql '1234'
        client.close()
        next()

  it 'Get only a single user by email', (next) ->
    client = db "#{__dirname}/../db/tmp"
    client.users.set 'dorian@ethylocle.com',
      email: 'dorian@ethylocle.com'
      password: '1234'
    , (err) ->
      return next err if err
      client.users.set 'maoqiao@ethylocle.com',
        email: 'maoqiao@ethylocle.com'
        password: '4321'
      , (err) ->
        return next err if err
        client.users.get 'dorian@ethylocle.com', (err, user) ->
          return next err if err
          user.email.should.eql 'dorian@ethylocle.com'
          user.password.should.eql '1234'
          client.close()
          next()

  it 'Sign in', (next) ->
    client = db "#{__dirname}/../db/tmp"
    client.users.set 'dorian@ethylocle.com',
      email: 'dorian@ethylocle.com'
      password: '1234'
    , (err) ->
      return next err if err
      client.users.set 'maoqiao@ethylocle.com',
        email: 'maoqiao@ethylocle.com'
        password: '4321'
      , (err) ->
        return next err if err
        login = 'maoqiao@ethylocle.com'
        password = '4321'
        client.users.get login, (err, user) ->
          return next err if err
          assertion = user.email is login and user.password is password
          assertion.should.eql true
          client.close()
          next()

  it 'Sign up', (next) ->
    client = db "#{__dirname}/../db/tmp"
    client.users.set 'dorian@ethylocle.com',
     email: 'dorian@ethylocle.com'
     password: '1234'
    , (err) ->
     return next err if err
     client.users.set 'maoqiao@ethylocle.com',
       email: 'maoqiao@ethylocle.com'
       password: '4321'
     , (err) ->
       return next err if err
       email = 'dorian@ethylocle.com'
       password = '1234'
       client.users.get email, (err, user) ->
         return next err if err
         assertion = user.email is email
         if assertion
           assertion.should.eql true
           client.close()
           next()
         else
           assertion.should.eql false
           client.users.set email,
            email: email
            password: password
           , (err) ->
             return next err if err
             client.close()
             next()

  it 'Update user data', (next) ->
    client = db "#{__dirname}/../db/tmp"
    firstname = ""
    user =
      email: 'dorian@ethylocle.com'
      picture: "null"
      lastname: "Bagur"
      firstname: firstname
      age: "22"
      gender: "M"
      weight: "75.5"
      address: "162 Boulevard du Général de Gaulle"
      zipCode: "78700"
      city: "Conflans-Sainte-Honorine"
      country: "France"
      phone: "+330619768399"
      vehicul: "Renault mégane"
      password: '1234'
    data = {}
    for k, v of user
      continue unless v
      data[k] = v
    client.users.set data.email, data, (err) ->
     return next err if err
     client.users.get "dorian@ethylocle.com", (err, user) ->
       return next err if err
       user.email.should.eql "dorian@ethylocle.com"
       user.picture.should.eql "null"
       user.lastname.should.eql "Bagur"
       should.not.exists user.firstname
       user.age.should.eql "22"
       user.gender.should.eql "M"
       user.weight.should.eql "75.5"
       user.address.should.eql "162 Boulevard du Général de Gaulle"
       user.zipCode.should.eql "78700"
       user.city.should.eql "Conflans-Sainte-Honorine"
       user.country.should.eql "France"
       user.phone.should.eql "+330619768399"
       user.vehicul.should.eql "Renault mégane"
       user.password.should.eql "1234"
       client.users.set 'dorian@ethylocle.com',
        email: "dorian@ethylocle.com"
        picture: "null"
        lastname: "Zhou"
        firstname: "Maoqiao"
        age: "22"
        gender: "M"
        weight: "75.5"
        address: "162 Boulevard du Général de Gaulle"
        zipCode: "78700"
        city: "Conflans-Sainte-Honorine"
        country: "France"
        phone: "+330619768399"
        vehicul: "Renault mégane"
       , (err) ->
        return next err if err
        client.users.get "dorian@ethylocle.com", (err, user) ->
          return next err if err
          user.email.should.eql "dorian@ethylocle.com"
          user.picture.should.eql "null"
          user.lastname.should.eql "Zhou"
          user.firstname.should.eql "Maoqiao"
          user.age.should.eql "22"
          user.gender.should.eql "M"
          user.weight.should.eql "75.5"
          user.address.should.eql "162 Boulevard du Général de Gaulle"
          user.zipCode.should.eql "78700"
          user.city.should.eql "Conflans-Sainte-Honorine"
          user.country.should.eql "France"
          user.phone.should.eql "+330619768399"
          user.vehicul.should.eql "Renault mégane"
          user.password.should.eql "1234"
          client.close()
          next()

  it 'Delete user', (next) ->
    client = db "#{__dirname}/../db/tmp"
    client.users.set 'dorian@ethylocle.com',
     email: 'dorian@ethylocle.com'
     picture: "null"
     lastname: "Bagur"
     firstname: "Dorian"
     age: "22"
     gender: "M"
     weight: "75.5"
     address: "162 Boulevard du Général de Gaulle"
     zipCode: "78700"
     city: "Conflans-Sainte-Honorine"
     country: "France"
     phone: "+330619768399"
     vehicul: "Renault mégane"
     password: '1234'
    , (err) ->
      return next err if err
      client.users.get "dorian@ethylocle.com", (err, user) ->
        return next err if err
        user.email.should.eql "dorian@ethylocle.com"
        user.picture.should.eql "null"
        user.lastname.should.eql "Bagur"
        user.firstname.should.eql "Dorian"
        user.age.should.eql "22"
        user.gender.should.eql "M"
        user.weight.should.eql "75.5"
        user.address.should.eql "162 Boulevard du Général de Gaulle"
        user.zipCode.should.eql "78700"
        user.city.should.eql "Conflans-Sainte-Honorine"
        user.country.should.eql "France"
        user.phone.should.eql "+330619768399"
        user.vehicul.should.eql "Renault mégane"
        user.password.should.eql "1234"
        client.users.del 'dorian@ethylocle.com', user, (err) ->
            return next err if err
            client.users.get "dorian@ethylocle.com", (err, user) ->
              return next err if err
              user.should.eql {}
              client.close()
              next()

  it 'Response structure', (next) ->
    client = db "#{__dirname}/../db/tmp"
    client.users.set 'dorian@ethylocle.com',
     password: '1234'
    , (err) ->
      return next err if err
      client.users.get 'dorian@ethylocle.com', (err, user) ->
        return next err if err
        data = {}
        for k, v of user
          continue if k is 'password'
          data[k] = v
        json =
          result: true
          data: data
        json.data.should.eql { email: 'dorian@ethylocle.com' }
        client.close()
        next()

  it 'Insert and get a stop', (next) ->
    client = db "#{__dirname}/../db/tmp"
    client.stops.set '4035172',
      name: 'REPUBLIQUE - DEFORGES'
      desc: 'FACE 91 AVENUE DE LA REPUBLIQUE - 92020'
      lat: '48.80383802353411'
      lon: '2.2978373453843948'
      lineType: 'BUS'
      lineName: 'BUS N63'
    , (err) ->
      return next err if err
      client.stops.get '4035172', (err, stop) ->
        return next err if err
        stop.name.should.eql 'REPUBLIQUE - DEFORGES'
        stop.desc.should.eql 'FACE 91 AVENUE DE LA REPUBLIQUE - 92020'
        stop.lat.should.eql '48.80383802353411'
        stop.lon.should.eql '2.2978373453843948'
        stop.lineType.should.eql 'BUS'
        stop.lineName.should.eql 'BUS N63'
        client.close()
        next()

  it 'Insert and get a single stop', (next) ->
    client = db "#{__dirname}/../db/tmp"
    client.stops.set '4035172',
      name: 'REPUBLIQUE - DEFORGES'
      desc: 'FACE 91 AVENUE DE LA REPUBLIQUE - 92020'
      lat: '48.80383802353411'
      lon: '2.2978373453843948'
      lineType: 'BUS'
      lineName: 'BUS N63'
    , (err) ->
      return next err if err
      client.stops.set '1832',
        name: 'Nation'
        desc: 'Nation (terre-plein face au 3 place de la) - 75112'
        lat: '48.84811123157566'
        lon: '2.3980040127977436'
        lineType: 'M'
        lineName: 'M 1'
      , (err) ->
        return next err if err
        client.stops.get '4035172', (err, stop) ->
          return next err if err
          stop.name.should.eql 'REPUBLIQUE - DEFORGES'
          stop.desc.should.eql 'FACE 91 AVENUE DE LA REPUBLIQUE - 92020'
          stop.lat.should.eql '48.80383802353411'
          stop.lon.should.eql '2.2978373453843948'
          stop.lineType.should.eql 'BUS'
          stop.lineName.should.eql 'BUS N63'
          client.close()
          next()

  it 'Insert and get a stop by line type', (next) ->
    client = db "#{__dirname}/../db/tmp"
    client.stops.set '4035172',
      name: 'REPUBLIQUE - DEFORGES'
      desc: 'FACE 91 AVENUE DE LA REPUBLIQUE - 92020'
      lat: '48.80383802353411'
      lon: '2.2978373453843948'
      lineType: 'BUS'
      lineName: 'BUS N63'
    , (err) ->
      return next err if err
      client.stops.setByLineType 'BUS', '4035172', (err) ->
        return next err if err
        client.stops.getByLineType 'BUS', (err, stops) ->
          return next err if err
          for k, v of stops
            stops[k].id.should.eql '4035172'
            stops[k].lineType.should.eql 'BUS'
            client.stops.get '4035172', (err, stop) ->
              return next err if err
              stop.name.should.eql 'REPUBLIQUE - DEFORGES'
              stop.desc.should.eql 'FACE 91 AVENUE DE LA REPUBLIQUE - 92020'
              stop.lat.should.eql '48.80383802353411'
              stop.lon.should.eql '2.2978373453843948'
              stop.lineType.should.eql 'BUS'
              stop.lineName.should.eql 'BUS N63'
              client.close()
              next()

  it 'Insert and get stops by line type', (next) ->
    client = db "#{__dirname}/../db/tmp"
    client.stops.set '4035172',
      name: 'REPUBLIQUE - DEFORGES'
      desc: 'FACE 91 AVENUE DE LA REPUBLIQUE - 92020'
      lat: '48.80383802353411'
      lon: '2.2978373453843948'
      lineType: 'BUS'
      lineName: 'BUS N63'
    , (err) ->
      return next err if err
      client.stops.setByLineType 'BUS', '4035172', (err) ->
        return next err if err
        client.stops.set '1832',
          name: 'Nation'
          desc: 'Nation (terre-plein face au 3 place de la) - 75112'
          lat: '48.84811123157566'
          lon: '2.3980040127977436'
          lineType: 'M'
          lineName: 'M 1'
        , (err) ->
          return next err if err
          client.stops.setByLineType 'M', '1832', (err) ->
            return next err if err
            client.stops.set '4035207',
              name: 'CHATILLON - MONTROUGE-METRO'
              desc: 'PISTE GARE ROUTIERE - 92020'
              lat: '48.81008571048087'
              lon: '2.301547557964941'
              lineType: 'BUS'
              lineName: 'BUS N63'
            , (err) ->
              return next err if err
              client.stops.setByLineType 'BUS', '4035207', (err) ->
                return next err if err
                client.stops.getByLineType 'BUS', (err, stops) ->
                  return next err if err
                  stops[0].id.should.eql '4035172'
                  stops[0].lineType.should.eql 'BUS'
                  stops[1].id.should.eql '4035207'
                  stops[1].lineType.should.eql 'BUS'
                  should.not.exists stops[2]
                  client.stops.get stops[0].id, (err, stop) ->
                    return next err if err
                    stop.name.should.eql 'REPUBLIQUE - DEFORGES'
                    stop.desc.should.eql 'FACE 91 AVENUE DE LA REPUBLIQUE - 92020'
                    stop.lat.should.eql '48.80383802353411'
                    stop.lon.should.eql '2.2978373453843948'
                    stop.lineType.should.eql 'BUS'
                    stop.lineName.should.eql 'BUS N63'
                    client.stops.get stops[1].id, (err, stop) ->
                      return next err if err
                      stop.name.should.eql 'CHATILLON - MONTROUGE-METRO'
                      stop.desc.should.eql 'PISTE GARE ROUTIERE - 92020'
                      stop.lat.should.eql '48.81008571048087'
                      stop.lon.should.eql '2.301547557964941'
                      stop.lineType.should.eql 'BUS'
                      stop.lineName.should.eql 'BUS N63'
                      client.close()
                      next()
