rimraf = require 'rimraf'
should = require 'should'
db = require '../../lib/factory/model'
app = require '../../lib/host/app'
https = require 'https'
fs = require 'fs'
port = process.env.PORT || 443
server = undefined
process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0"

moment = require 'moment'

hskey = fs.readFileSync __dirname + "/../../resource/key/key.pem"
hscert = fs.readFileSync __dirname + "/../../resource/key/cert.pem"

options =
  key: hskey
  cert: hscert

defaultGetOptions = (path) ->
  options =
    "host": "localhost"
    "port": port
    "path": path
    "method": "POST"

GetOptionsWithHeaders = (path, body, cookie) ->
  headers =
    'Content-Type': 'application/json'
    'Content-Length': body.length
    'Cookie': cookie
  options =
    "host": "localhost"
    "port": port
    "path": path
    "method": "POST"
    "headers": headers

describe 'Trip routes', ->

  before (next) ->
    server = https.createServer(options, app).listen port, (err, result) ->
      return next err if err
      next()

  after (next) ->
    server.close()
    next()

  beforeEach (next) ->
    rimraf "#{__dirname}/../../db/tmp/tripsearch", ->
      rimraf "#{__dirname}/../../db/tmp/trip", ->
        rimraf "#{__dirname}/../../db/tmp/user", next

  it 'should exist', (next) ->
    should.exist app
    next()

  it "should be listening at localhost:#{port}", (next) ->
    headers = defaultGetOptions '/'
    headers.method = "GET"
    https.get headers, (res) ->
      res.statusCode.should.eql 200
      next()

  it 'Create trip without signed in', (next) ->
    headers = defaultGetOptions '/trp/create'
    https.get headers, (res) ->
      res.statusCode.should.eql 200
      body = ""
      res.on 'data', (data) ->
        body += data
      res.on 'end', (err) ->
        return next err if err
        res = JSON.parse body
        Object.keys(res).length.should.eql 2
        res.result.should.eql false
        res.data.should.eql "Authentification requise"
        next()

  it 'Create trip (after signed up)', (next) ->
    bodyString = JSON.stringify email: "dorian@ethylocle.com", password: "12345678"
    headers = GetOptionsWithHeaders '/usr/signup', bodyString
    req = https.request headers, (res) ->
      res.on 'data', (data) ->
      res.on 'end', (err) ->
        return next err if err
        criteria =
          addressStart: "Aucune"
          latStart: '48.856470'
          lonStart: '2.286001'
          addressEnd: "Aucune"
          latEnd: '48.865314'
          lonEnd: '2.321514'
          dateTime: moment().add(30, 'm').format "DD-MM-YYYY H:mm"
          numberOfPeople: '2'
        bodyString = JSON.stringify criteria
        headers = GetOptionsWithHeaders '/trp/create', bodyString, res.headers['set-cookie']
        req = https.request headers, (res) ->
          res.statusCode.should.eql 200
          body = ""
          res.on 'data', (data) ->
            body += data
          res.on 'end', (err) ->
            return next err if err
            res = JSON.parse body
            Object.keys(res).length.should.eql 2
            res.result.should.eql true
            should.not.exists res.data
            next()
        req.write bodyString
        req.end()
    req.write bodyString
    req.end()

  it 'Create trip with missing parameters (after signed up)', (next) ->
    bodyString = JSON.stringify email: "dorian@ethylocle.com", password: "12345678"
    headers = GetOptionsWithHeaders '/usr/signup', bodyString
    req = https.request headers, (res) ->
      res.on 'data', (data) ->
      res.on 'end', (err) ->
        return next err if err
        criteria =
          latStart: '48.856470'
          lonStart: '2.286001'
          latEnd: '48.865314'
          lonEnd: '2.321514'
          dateTime: moment().add(30, 'm').format "DD-MM-YYYY H:mm"
          numberOfPeople: '2'
        bodyString = JSON.stringify criteria
        headers = GetOptionsWithHeaders '/trp/create', bodyString, res.headers['set-cookie']
        req = https.request headers, (res) ->
          res.statusCode.should.eql 200
          body = ""
          res.on 'data', (data) ->
            body += data
          res.on 'end', (err) ->
            return next err if err
            res = JSON.parse body
            Object.keys(res).length.should.eql 2
            res.result.should.eql false
            res.data.should.eql "Le nombre d'arguments est insuffisant"
            next()
        req.write bodyString
        req.end()
    req.write bodyString
    req.end()

  it 'Create trip with numberOfPeople < 1 (after signed up)', (next) ->
    bodyString = JSON.stringify email: "dorian@ethylocle.com", password: "12345678"
    headers = GetOptionsWithHeaders '/usr/signup', bodyString
    req = https.request headers, (res) ->
      res.on 'data', (data) ->
      res.on 'end', (err) ->
        return next err if err
        criteria =
          addressStart: "Aucune"
          latStart: '48.856470'
          lonStart: '2.286001'
          addressEnd: "Aucune"
          latEnd: '48.865314'
          lonEnd: '2.321514'
          dateTime: moment().add(30, 'm').format "DD-MM-YYYY H:mm"
          numberOfPeople: '0'
        bodyString = JSON.stringify criteria
        headers = GetOptionsWithHeaders '/trp/create', bodyString, res.headers['set-cookie']
        req = https.request headers, (res) ->
          res.statusCode.should.eql 200
          body = ""
          res.on 'data', (data) ->
            body += data
          res.on 'end', (err) ->
            return next err if err
            res = JSON.parse body
            Object.keys(res).length.should.eql 2
            res.result.should.eql false
            res.data.should.eql "Le nombre de personnes est nul"
            next()
        req.write bodyString
        req.end()
    req.write bodyString
    req.end()

  it 'Create trip with numberOfPeople > 2 (after signed up)', (next) ->
    bodyString = JSON.stringify email: "dorian@ethylocle.com", password: "12345678"
    headers = GetOptionsWithHeaders '/usr/signup', bodyString
    req = https.request headers, (res) ->
      res.on 'data', (data) ->
      res.on 'end', (err) ->
        return next err if err
        criteria =
          addressStart: "Aucune"
          latStart: '48.856470'
          lonStart: '2.286001'
          addressEnd: "Aucune"
          latEnd: '48.865314'
          lonEnd: '2.321514'
          dateTime: moment().add(30, 'm').format "DD-MM-YYYY H:mm"
          numberOfPeople: '10'
        bodyString = JSON.stringify criteria
        headers = GetOptionsWithHeaders '/trp/create', bodyString, res.headers['set-cookie']
        req = https.request headers, (res) ->
          res.statusCode.should.eql 200
          body = ""
          res.on 'data', (data) ->
            body += data
          res.on 'end', (err) ->
            return next err if err
            res = JSON.parse body
            Object.keys(res).length.should.eql 2
            res.result.should.eql false
            res.data.should.eql "Impossible de créer un trajet pour plus de 2 personnes"
            next()
        req.write bodyString
        req.end()
    req.write bodyString
    req.end()

  it 'Create trip with date past (after signed up)', (next) ->
    bodyString = JSON.stringify email: "dorian@ethylocle.com", password: "12345678"
    headers = GetOptionsWithHeaders '/usr/signup', bodyString
    req = https.request headers, (res) ->
      res.on 'data', (data) ->
      res.on 'end', (err) ->
        return next err if err
        criteria =
          addressStart: "Aucune"
          latStart: '48.856470'
          lonStart: '2.286001'
          addressEnd: "Aucune"
          latEnd: '48.865314'
          lonEnd: '2.321514'
          dateTime: moment().add(-1, 'm').format "DD-MM-YYYY H:mm"
          numberOfPeople: '2'
        bodyString = JSON.stringify criteria
        headers = GetOptionsWithHeaders '/trp/create', bodyString, res.headers['set-cookie']
        req = https.request headers, (res) ->
          res.statusCode.should.eql 200
          body = ""
          res.on 'data', (data) ->
            body += data
          res.on 'end', (err) ->
            return next err if err
            res = JSON.parse body
            Object.keys(res).length.should.eql 2
            res.result.should.eql false
            res.data.should.eql "La date et l'heure fournies sont passées"
            next()
        req.write bodyString
        req.end()
    req.write bodyString
    req.end()

  it 'Has trip', (next) ->
    headers = defaultGetOptions '/trp/has'
    https.get headers, (res) ->
      res.statusCode.should.eql 200
      body = ""
      res.on 'data', (data) ->
        body += data
      res.on 'end', (err) ->
        return next err if err
        res = JSON.parse body
        Object.keys(res).length.should.eql 2
        res.result.should.eql false
        res.data.should.eql "Authentification requise"
        next()

  it 'Has trip after created one (after signed up)', (next) ->
    bodyString = JSON.stringify email: "dorian@ethylocle.com", password: "12345678"
    headers = GetOptionsWithHeaders '/usr/signup', bodyString
    req = https.request headers, (res) ->
      res.on 'data', (data) ->
      res.on 'end', (err) ->
        return next err if err
        criteria =
          addressStart: "Aucune"
          latStart: '48.856470'
          lonStart: '2.286001'
          addressEnd: "Aucune"
          latEnd: '48.865314'
          lonEnd: '2.321514'
          dateTime: moment().add(30, 'm').format "DD-MM-YYYY H:mm"
          numberOfPeople: '2'
        bodyString = JSON.stringify criteria
        cookie = res.headers['set-cookie']
        headers = GetOptionsWithHeaders '/trp/create', bodyString, res.headers['set-cookie']
        req = https.request headers, (res) ->
          res.on 'data', (data) ->
          res.on 'end', (err) ->
            return next err if err
            bodyString = ""
            headers = GetOptionsWithHeaders '/trp/has', bodyString, cookie
            req = https.request headers, (res) ->
              res.statusCode.should.eql 200
              body = ""
              res.on 'data', (data) ->
                body += data
              res.on 'end', (err) ->
                return next err if err
                res = JSON.parse body
                Object.keys(res).length.should.eql 2
                res.result.should.eql true
                should.not.exists res.data
                next()
            req.write bodyString
            req.end()
        req.write bodyString
        req.end()
    req.write bodyString
    req.end()

  it 'Has trip without created one (after signed up)', (next) ->
    bodyString = JSON.stringify email: "dorian@ethylocle.com", password: "12345678"
    headers = GetOptionsWithHeaders '/usr/signup', bodyString
    req = https.request headers, (res) ->
      res.on 'data', (data) ->
      res.on 'end', (err) ->
        return next err if err
        bodyString = ""
        headers = GetOptionsWithHeaders '/trp/has', bodyString, res.headers['set-cookie']
        req = https.request headers, (res) ->
          res.statusCode.should.eql 200
          body = ""
          res.on 'data', (data) ->
            body += data
          res.on 'end', (err) ->
            return next err if err
            res = JSON.parse body
            Object.keys(res).length.should.eql 2
            res.result.should.eql false
            res.data.should.eql "Aucun trajet en cours"
            next()
        req.write bodyString
        req.end()
    req.write bodyString
    req.end()
