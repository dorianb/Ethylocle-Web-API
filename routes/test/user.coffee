rimraf = require 'rimraf'
should = require 'should'
db = require '../../lib/factory/model'
app = require '../../lib/host/app'
http = require 'http'
port = 3000

defaultGetOptions = (path) ->
  options =
    "host": "localhost"
    "port": port
    "path": path
    "method": "POST"

GetOptionsWithHeaders = (path, body) ->
  headers =
    'Content-Type': 'application/json'
    'Content-Length': body.length
  options =
    "host": "localhost"
    "port": port
    "path": path
    "method": "POST"
    "headers": headers

describe 'User routes', ->

  before (next) ->
    app.listen port, (err, result) ->
      if err
        next err
      else
        next()

  beforeEach (next) ->
    rimraf "#{__dirname}/../../db/tmp/user", next

  it 'should exist', (next) ->
    should.exist app
    next()

  it "should be listening at localhost:#{port}", (next) ->
    headers = defaultGetOptions '/'
    headers.method = "GET"
    http.get headers, (res) ->
      res.statusCode.should.eql 200
      next()

  it 'Sign in without body', (next) ->
    headers = defaultGetOptions '/usr/signin'
    http.get headers, (res) ->
      res.statusCode.should.eql 200
      body = ""
      res.on 'data', (data) ->
        body += data
      res.on 'end', (err) ->
        res = JSON.parse body
        res.result.should.eql false
        res.data.should.eql "Email ou mot de passe manquant"
        next()

  it 'Sign in without signed up', (next) ->
    bodyString = JSON.stringify {email: "dorian@ethylocle.com", password: "1234"}
    headers = GetOptionsWithHeaders '/usr/signin', bodyString
    req = http.request headers, (res) ->
      res.statusCode.should.eql 200
      body = ""
      res.on 'data', (data) ->
        body += data
      res.on 'end', (err) ->
        res = JSON.parse body
        res.result.should.eql false
        res.data.should.eql "Email ou mot de passe incorrect"
        next()
    req.write bodyString
    req.end()

  it 'Sign up', (next) ->
    next()

  it 'Sign up and sign in', (next) ->
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

  it 'Check password complexity', (next) ->
    isPassword = (password) ->
      score = 0
      match = new RegExp "[a-z]+", ""
      if match.test password
        score++
      match = new RegExp "[A-Z]+", ""
      if match.test password
        score++
      match = new RegExp "[0-9]+", ""
      if match.test password
        score++
      match = new RegExp "[^A-Za-z0-9]+", ""
      if match.test password
        score++
      score += password.length
      #console.log score
      if score > 8
        return true
      else
        return false

    passwords = new Array '6143614', 'coucou', 'HelloDorian', '61436143', 'couCou'

    isPassword(passwords[0]).should.eql false
    isPassword(passwords[1]).should.eql false
    isPassword(passwords[2]).should.eql true
    isPassword(passwords[3]).should.eql true
    isPassword(passwords[4]).should.eql false
    next()
