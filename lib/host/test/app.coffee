http = require 'http'
should = require 'should'
app  = require "../app"
port = 3000
server = undefined

describe 'App', () ->

  before (done) ->
    server = app.listen port, (err, result) ->
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
    http.get headers, (res) ->
      res.statusCode.should.eql 200
      done()

  defaultGetOptions = (path) ->
    options =
      "host": "localhost"
      "port": port
      "path": path
      "method": "GET"
