http = require 'http'
should = require 'should'
app  = require "../app"
port = 3000

describe 'App', () ->

  before (done) ->
    app.listen port, (err, result) ->
      if err
        done err
      else
        done()

  after (done) ->
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
