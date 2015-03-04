https = require 'https'
fs = require 'fs'
should = require 'should'
app  = require "../app"
port = process.env.PORT || 443
server = undefined

hskey = fs.readFileSync __dirname + "/../../../resource/key/key.pem"
hscert = fs.readFileSync __dirname + "/../../../resource/key/cert.pem"

options =
  key: hskey
  cert: hscert

describe 'App', () ->

  before (done) ->
    console.log port
    server = https.createServer(options, app).listen port, (err, result) ->
      if err
        done err
      else
        done()

  after (done) ->
    server.close()
    done()

  it 'should exist', (done) ->
    should.exist(app)
    done()

  it "should be listening at localhost:#{port}", (done) ->
    headers = defaultGetOptions '/'
    https.get headers, (res) ->
      res.statusCode.should.eql 200
      done()

  defaultGetOptions = (path) ->
    options =
      "host": "localhost"
      "port": port
      "path": path
      "method": "GET"
