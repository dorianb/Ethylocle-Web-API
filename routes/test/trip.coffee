rimraf = require 'rimraf'
should = require 'should'
db = require '../../lib/factory/model'
app = require '../../lib/host/app'
https = require 'https'
fs = require 'fs'
port = 443
server = undefined
process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0"

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

  it 'Create trip', (next) ->
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
