# Application host

    express = require 'express'
    path = require 'path'
    bodyParser = require 'body-parser'
    cookieParser = require 'cookie-parser'
    methodOverride = require 'method-override'
    expressSession = require 'express-session'
    serveStatic = require 'serve-static'
    serveIndex = require 'serve-index'
    errorHandler = require 'errorhandler'

    app = express()

    app.use bodyParser.json()
    app.use bodyParser.urlencoded extended: false
    app.use cookieParser 'A8g8o7Zf-c0d8-e0V<-QVe2'
    app.use methodOverride '_method'

    app.use expressSession
      secret: 'A8g8o7Zf-c0d8-e0V<-QVe2'
      resave: false
      saveUninitialized: true
      cookie:
        maxAge: 3600000
        secure: true

    app.use serveStatic "#{__dirname}/../../public"

    app.use '/', require '../../routes/index'
    app.use '/usr', require '../../routes/user'
    app.use '/trp', require '../../routes/trip'

    app.use serveIndex "#{__dirname}/../../public"
    app.use errorHandler() if process.env.NODE_ENV is "development"

    module.exports = app
