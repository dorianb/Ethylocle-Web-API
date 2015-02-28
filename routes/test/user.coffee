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

  it 'Sign in without body (without email or password)', (next) ->
    headers = defaultGetOptions '/usr/signin'
    http.get headers, (res) ->
      res.statusCode.should.eql 200
      body = ""
      res.on 'data', (data) ->
        body += data
      res.on 'end', (err) ->
        return next err if err
        res = JSON.parse body
        Object.keys(res).length.should.eql 2
        res.result.should.eql false
        res.data.should.eql "Email ou mot de passe manquant"
        next()

  it 'Sign in without signed up', (next) ->
    bodyString = JSON.stringify email: "dorian@ethylocle.com", password: "1234"
    headers = GetOptionsWithHeaders '/usr/signin', bodyString
    req = http.request headers, (res) ->
      res.statusCode.should.eql 200
      body = ""
      res.on 'data', (data) ->
        body += data
      res.on 'end', (err) ->
        return next err if err
        res = JSON.parse body
        Object.keys(res).length.should.eql 2
        res.result.should.eql false
        res.data.should.eql "Email ou mot de passe incorrect"
        next()
    req.write bodyString
    req.end()

  it 'Sign up correctly', (next) ->
    bodyString = JSON.stringify email: "dorian@ethylocle.com", password: "12345678"
    headers = GetOptionsWithHeaders '/usr/signup', bodyString
    req = http.request headers, (res) ->
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

  it 'Sign up without email or password', (next) ->
    bodyString = JSON.stringify password: "1234"
    headers = GetOptionsWithHeaders '/usr/signup', bodyString
    req = http.request headers, (res) ->
      res.statusCode.should.eql 200
      body = ""
      res.on 'data', (data) ->
        body += data
      res.on 'end', (err) ->
        return next err if err
        res = JSON.parse body
        Object.keys(res).length.should.eql 2
        res.result.should.eql false
        res.data.should.eql "Email ou mot de passe manquant"
        next()
    req.write bodyString
    req.end()

  it 'Sign up without a valid email', (next) ->
    bodyString = JSON.stringify email: "dorianethylocle.com", password: "1234"
    headers = GetOptionsWithHeaders '/usr/signup', bodyString
    req = http.request headers, (res) ->
      res.statusCode.should.eql 200
      body = ""
      res.on 'data', (data) ->
        body += data
      res.on 'end', (err) ->
        return next err if err
        res = JSON.parse body
        Object.keys(res).length.should.eql 2
        res.result.should.eql false
        res.data.should.eql "Cette adresse email est invalide"
        next()
    req.write bodyString
    req.end()

  it 'Sign up without a strong password', (next) ->
    bodyString = JSON.stringify email: "dorian@ethylocle.com", password: "1234"
    headers = GetOptionsWithHeaders '/usr/signup', bodyString
    req = http.request headers, (res) ->
      res.statusCode.should.eql 200
      body = ""
      res.on 'data', (data) ->
        body += data
      res.on 'end', (err) ->
        return next err if err
        res = JSON.parse body
        Object.keys(res).length.should.eql 2
        res.result.should.eql false
        res.data.should.eql "Le mot de passe doit comporter au moins 8 caractères"
        next()
    req.write bodyString
    req.end()

  it 'Sign in after signed up', (next) ->
    bodyString = JSON.stringify email: "dorian@ethylocle.com", password: "12345678"
    headers = GetOptionsWithHeaders '/usr/signup', bodyString
    req = http.request headers, (res) ->
      res.on 'data', (data) ->
      res.on 'end', (err) ->
        return next err if err
        bodyString = JSON.stringify email: "dorian@ethylocle.com", password: "12345678"
        headers = GetOptionsWithHeaders '/usr/signin', bodyString
        req2 = http.request headers, (res) ->
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
        req2.write bodyString
        req2.end()
    req.write bodyString
    req.end()

  it 'Check password without signed in', (next) ->
    bodyString = JSON.stringify password: "12345678"
    headers = GetOptionsWithHeaders '/usr/checkpassword', bodyString
    req = http.request headers, (res) ->
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
    req.write bodyString
    req.end()

  it 'Check password after signed up', (next) ->
    bodyString = JSON.stringify email: "dorian@ethylocle.com", password: "12345678"
    headers = GetOptionsWithHeaders '/usr/signup', bodyString
    req = http.request headers, (res) ->
      res.on 'data', (data) ->
      res.on 'end', (err) ->
        return next err if err
        bodyString = JSON.stringify password: "12345678"
        headers = GetOptionsWithHeaders '/usr/checkpassword', bodyString, res.headers['set-cookie']
        req = http.request headers, (res) ->
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

  it 'Check password without password (after signed up)', (next) ->
    bodyString = JSON.stringify email: "dorian@ethylocle.com", password: "12345678"
    headers = GetOptionsWithHeaders '/usr/signup', bodyString
    req = http.request headers, (res) ->
      res.on 'data', (data) ->
      res.on 'end', (err) ->
        return next err if err
        bodyString = JSON.stringify email: "12345678"
        headers = GetOptionsWithHeaders '/usr/checkpassword', bodyString, res.headers['set-cookie']
        req = http.request headers, (res) ->
          res.statusCode.should.eql 200
          body = ""
          res.on 'data', (data) ->
            body += data
          res.on 'end', (err) ->
            return next err if err
            res = JSON.parse body
            Object.keys(res).length.should.eql 2
            res.result.should.eql false
            res.data.should.eql "Mot de passe manquant"
            next()
        req.write bodyString
        req.end()
    req.write bodyString
    req.end()

  it 'Update email without signed in', (next) ->
    bodyString = JSON.stringify email: "dorian@ethylocle.com"
    headers = GetOptionsWithHeaders '/usr/updateemail', bodyString
    req = http.request headers, (res) ->
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
    req.write bodyString
    req.end()

  it 'Update email after signed up', (next) ->
    bodyString = JSON.stringify email: "dorian@ethylocle.com", password: "12345678"
    headers = GetOptionsWithHeaders '/usr/signup', bodyString
    req = http.request headers, (res) ->
      res.on 'data', (data) ->
      res.on 'end', (err) ->
        return next err if err
        bodyString = JSON.stringify email: "robin@ethylocle.com"
        headers = GetOptionsWithHeaders '/usr/updateemail', bodyString, res.headers['set-cookie']
        req = http.request headers, (res) ->
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

  it 'Update email without email (after signed up)', (next) ->
    bodyString = JSON.stringify email: "dorian@ethylocle.com", password: "12345678"
    headers = GetOptionsWithHeaders '/usr/signup', bodyString
    req = http.request headers, (res) ->
      res.on 'data', (data) ->
      res.on 'end', (err) ->
        return next err if err
        headers = GetOptionsWithHeaders '/usr/updateemail', "", res.headers['set-cookie']
        req = http.request headers, (res) ->
          res.statusCode.should.eql 200
          body = ""
          res.on 'data', (data) ->
            body += data
          res.on 'end', (err) ->
            return next err if err
            res = JSON.parse body
            Object.keys(res).length.should.eql 2
            res.result.should.eql false
            res.data.should.eql "Email manquant"
            next()
        req.end()
    req.write bodyString
    req.end()

  it 'Update email with an unvalid email (after signed up)', (next) ->
    bodyString = JSON.stringify email: "dorian@ethylocle.com", password: "12345678"
    headers = GetOptionsWithHeaders '/usr/signup', bodyString
    req = http.request headers, (res) ->
      res.on 'data', (data) ->
      res.on 'end', (err) ->
        return next err if err
        bodyString = JSON.stringify email: "robinethylocle.com"
        headers = GetOptionsWithHeaders '/usr/updateemail', bodyString, res.headers['set-cookie']
        req = http.request headers, (res) ->
          res.statusCode.should.eql 200
          body = ""
          res.on 'data', (data) ->
            body += data
          res.on 'end', (err) ->
            return next err if err
            res = JSON.parse body
            Object.keys(res).length.should.eql 2
            res.result.should.eql false
            res.data.should.eql "Cette adresse email est invalide"
            next()
        req.write bodyString
        req.end()
    req.write bodyString
    req.end()

  it 'Update without signed in', (next) ->
    bodyString = JSON.stringify email: "maoqiao@ethylocle.com", lastName: "Bagur", firstName: "Dorian"
    headers = GetOptionsWithHeaders '/usr/update', bodyString
    req = http.request headers, (res) ->
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
    req.write bodyString
    req.end()

  it 'Update after signed up', (next) ->
    bodyString = JSON.stringify email: "dorian@ethylocle.com", password: "12345678"
    headers = GetOptionsWithHeaders '/usr/signup', bodyString
    req = http.request headers, (res) ->
      res.on 'data', (data) ->
      res.on 'end', (err) ->
        return next err if err
        bodyString = JSON.stringify email: "maoqiao@ethylocle.com", lastName: "Bagur", firstName: "Dorian", password: "87654321"
        headers = GetOptionsWithHeaders '/usr/update', bodyString, res.headers['set-cookie']
        req = http.request headers, (res) ->
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

  it 'Update without arguments (after signed up)', (next) ->
    bodyString = JSON.stringify email: "dorian@ethylocle.com", password: "12345678"
    headers = GetOptionsWithHeaders '/usr/signup', bodyString
    req = http.request headers, (res) ->
      res.on 'data', (data) ->
      res.on 'end', (err) ->
        return next err if err
        bodyString = ""
        headers = GetOptionsWithHeaders '/usr/update', bodyString, res.headers['set-cookie']
        req = http.request headers, (res) ->
          res.statusCode.should.eql 200
          body = ""
          res.on 'data', (data) ->
            body += data
          res.on 'end', (err) ->
            return next err if err
            res = JSON.parse body
            Object.keys(res).length.should.eql 2
            res.result.should.eql false
            res.data.should.eql "La requête ne comporte aucun argument"
            next()
        req.write bodyString
        req.end()
    req.write bodyString
    req.end()

  it 'Update without password (after signed up)', (next) ->
    bodyString = JSON.stringify email: "dorian@ethylocle.com", password: "12345678"
    headers = GetOptionsWithHeaders '/usr/signup', bodyString
    req = http.request headers, (res) ->
      res.on 'data', (data) ->
      res.on 'end', (err) ->
        return next err if err
        bodyString = JSON.stringify email: "maoqiao@ethylocle.com", lastName: "Bagur", firstName: "Dorian"
        headers = GetOptionsWithHeaders '/usr/update', bodyString, res.headers['set-cookie']
        req = http.request headers, (res) ->
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

  it 'Update with an unvalid password (after signed up)', (next) ->
    bodyString = JSON.stringify email: "dorian@ethylocle.com", password: "12345678"
    headers = GetOptionsWithHeaders '/usr/signup', bodyString
    req = http.request headers, (res) ->
      res.on 'data', (data) ->
      res.on 'end', (err) ->
        return next err if err
        bodyString = JSON.stringify password: "1234"
        headers = GetOptionsWithHeaders '/usr/update', bodyString, res.headers['set-cookie']
        req = http.request headers, (res) ->
          res.statusCode.should.eql 200
          body = ""
          res.on 'data', (data) ->
            body += data
          res.on 'end', (err) ->
            return next err if err
            res = JSON.parse body
            Object.keys(res).length.should.eql 2
            res.result.should.eql false
            res.data.should.eql "Le mot de passe doit comporter au moins 8 caractères"
            next()
        req.write bodyString
        req.end()
    req.write bodyString
    req.end()
