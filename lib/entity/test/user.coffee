should = require 'should'
User = require '../user'

describe 'User entity', ->

  it 'Create user', (next) ->
    data =
      id: 0
      email: "dorian@ethylocle.com"
      password: "1234"
    user = User data
    user.id.should.eql data.id
    user.email.should.eql data.email
    user.password.should.eql data.password
    should.not.exists user.image
    should.not.exists user.lastName
    should.not.exists user.firstName
    should.not.exists user.birthDate
    should.not.exists user.gender
    should.not.exists user.weight
    should.not.exists user.address
    should.not.exists user.zipCode
    should.not.exists user.city
    should.not.exists user.country
    should.not.exists user.phone
    should.not.exists user.latitude
    should.not.exists user.longitude
    should.not.exists user.longitude
    should.not.exists user.bac
    should.not.exists user.bacDate
    next()

  it 'Get User', (next) ->
    data =
      id: "0"
      email: "dorian@ethylocle.com"
      password: "1234"
    user = User data
    user = user.get()
    user.id.should.eql data.id
    user.email.should.eql data.email
    user.password.should.eql data.password
    should.not.exists user.image
    should.not.exists user.lastName
    should.not.exists user.firstName
    should.not.exists user.birthDate
    should.not.exists user.gender
    should.not.exists user.weight
    should.not.exists user.address
    should.not.exists user.zipCode
    should.not.exists user.city
    should.not.exists user.country
    should.not.exists user.phone
    should.not.exists user.latitude
    should.not.exists user.longitude
    should.not.exists user.longitude
    should.not.exists user.bac
    should.not.exists user.bacDate
    next()

  it 'Get User without properties', (next) ->
    user = User()
    user = user.get()
    should.not.exists user.id
    should.not.exists user.email
    should.not.exists user.password
    should.not.exists user.image
    should.not.exists user.lastName
    should.not.exists user.firstName
    should.not.exists user.birthDate
    should.not.exists user.gender
    should.not.exists user.weight
    should.not.exists user.address
    should.not.exists user.zipCode
    should.not.exists user.city
    should.not.exists user.country
    should.not.exists user.phone
    should.not.exists user.latitude
    should.not.exists user.longitude
    should.not.exists user.longitude
    should.not.exists user.bac
    should.not.exists user.bacDate
    next()

  it 'Get User with empty properties', (next) ->
    user = User {}
    user = user.get()
    should.not.exists user.id
    should.not.exists user.email
    should.not.exists user.password
    should.not.exists user.image
    should.not.exists user.lastName
    should.not.exists user.firstName
    should.not.exists user.birthDate
    should.not.exists user.gender
    should.not.exists user.weight
    should.not.exists user.address
    should.not.exists user.zipCode
    should.not.exists user.city
    should.not.exists user.country
    should.not.exists user.phone
    should.not.exists user.latitude
    should.not.exists user.longitude
    should.not.exists user.longitude
    should.not.exists user.bac
    should.not.exists user.bacDate
    next()

  it 'Get private user data', (next) ->
    data =
      id: "0"
      email: "dorian@ethylocle.com"
      lastName: "Bagur"
      password: "1234"
      bac: "1.12"
    user = User data
    user = user.getPrivate()
    user.id.should.eql data.id
    user.email.should.eql data.email
    user.lastName.should.eql data.lastName
    user.bac.should.eql data.bac
    should.not.exists user.password
    should.not.exists user.image
    should.not.exists user.firstName
    should.not.exists user.birthDate
    should.not.exists user.gender
    should.not.exists user.weight
    should.not.exists user.address
    should.not.exists user.zipCode
    should.not.exists user.city
    should.not.exists user.country
    should.not.exists user.phone
    should.not.exists user.latitude
    should.not.exists user.longitude
    should.not.exists user.longitude
    should.not.exists user.bacDate
    next()

  it 'Get public user data', (next) ->
    data =
      id: "0"
      email: "dorian@ethylocle.com"
      lastName: "Bagur"
      password: "1234"
      bac: "1.12"
    user = User data
    user = user.getPublic()
    user.id.should.eql data.id
    user.lastName.should.eql data.lastName
    should.not.exists user.email
    should.not.exists user.password
    should.not.exists user.image
    should.not.exists user.firstName
    should.not.exists user.birthDate
    should.not.exists user.gender
    should.not.exists user.weight
    should.not.exists user.address
    should.not.exists user.zipCode
    should.not.exists user.city
    should.not.exists user.country
    should.not.exists user.phone
    should.not.exists user.latitude
    should.not.exists user.longitude
    should.not.exists user.longitude
    should.not.exists user.bac
    should.not.exists user.bacDate
    next()

  it 'User toString', (next) ->
    data =
      id: "0"
      email: "dorian@ethylocle.com"
      password: "1234"
    user = User data
    string = user.toString()
    string.should.eql "User id:0 email:dorian@ethylocle.com password:1234"
    next()

  it 'User toString without properties', (next) ->
    user = User()
    string = user.toString()
    string.should.eql "User"
    next()

  it 'User toString with empty properties', (next) ->
    user = User {}
    string = user.toString()
    string.should.eql "User"
    next()

  it 'User check email address', (next) ->
    users = new Array User({email:'adressemail@gmail'}), User({email:'adresse@mel.fr'}), User({email:'adr@fr.com.eu'})
    users[0].isEmail().should.eql false
    users[1].isEmail().should.eql true
    users[2].isEmail().should.eql true
    next()

  it 'User check password complexity', (next) ->
    users = new Array User({password:'6143614'}), User({password:'coucou'}), User({password:'HelloDorian'}), User({password:'61436143'}), User({password:'couCou'})
    users[0].isPassword().should.eql false
    users[1].isPassword().should.eql false
    users[2].isPassword().should.eql true
    users[3].isPassword().should.eql true
    users[4].isPassword().should.eql false
    next()

  it 'Set User', (next) ->
    data1 =
      id: "0"
      email: "dorian@ethylocle.com"
      password: "1234"
    user = User data1
    data2 =
      email: "robin@ethylocle.com"
      lastName: "Bagur"
      bac: "1.9"
    user.set data2
    user = user.get()
    user.id.should.eql data1.id
    user.email.should.eql data2.email
    user.password.should.eql data1.password
    user.lastName.should.eql data2.lastName
    user.bac.should.eql data2.bac
    should.not.exists user.image
    should.not.exists user.firstName
    should.not.exists user.birthDate
    should.not.exists user.gender
    should.not.exists user.weight
    should.not.exists user.address
    should.not.exists user.zipCode
    should.not.exists user.city
    should.not.exists user.country
    should.not.exists user.phone
    should.not.exists user.latitude
    should.not.exists user.longitude
    should.not.exists user.longitude
    should.not.exists user.bacDate
    next()

  it 'Set from User', (next) ->
    data1 =
      id: "0"
      email: "dorian@ethylocle.com"
      password: "1234"
    user = User data1
    data2 =
      email: "robin@ethylocle.com"
      lastName: "Bagur"
      bac: "1.9"
    user.setFrom data2
    user = user.get()
    user.id.should.eql data1.id
    user.email.should.eql data1.email
    user.password.should.eql data1.password
    user.lastName.should.eql data2.lastName
    user.bac.should.eql data2.bac
    should.not.exists user.image
    should.not.exists user.firstName
    should.not.exists user.birthDate
    should.not.exists user.gender
    should.not.exists user.weight
    should.not.exists user.address
    should.not.exists user.zipCode
    should.not.exists user.city
    should.not.exists user.country
    should.not.exists user.phone
    should.not.exists user.latitude
    should.not.exists user.longitude
    should.not.exists user.longitude
    should.not.exists user.bacDate
    next()
