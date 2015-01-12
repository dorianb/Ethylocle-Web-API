# Server set up

    express = require 'express'
    path = require 'path'
    favicon = require 'serve-favicon'
    bodyParser = require 'body-parser'
    cookieParser = require 'cookie-parser'
    methodOverride = require 'method-override'
    expressSession = require 'express-session'
    serveStatic = require 'serve-static'
    serveIndex = require 'serve-index'
    errorHandler = require 'errorhandler'
    stylus = require 'stylus'
    nib = require 'nib'

    app = express()

    app.set 'views', "#{__dirname}/../views"
    app.set 'view engine', 'jade'

    app.use favicon("#{__dirname}/../public/favicon.ico")
    app.use bodyParser.json()
    app.use bodyParser.urlencoded( extended: false )
    app.use cookieParser('123456789')
    app.use methodOverride '_method'

    sess =
      secret: '123456789'
      resave: false
      saveUninitialized: true
      cookie: maxAge: 60000

    if process.env.NODE_ENV is "production"
      app.set "trust proxy", 1
      sess.cookie.secure = true

    app.use expressSession(sess)

    app.use stylus.middleware
      src: "#{__dirname}/../views"
      dest: "#{__dirname}/../public"
      compile: (str, path) ->
        stylus(str)
        .set('filename', path)
        .set('compress', config?.css?.compress)
        .use nib()

    app.use serveStatic("#{__dirname}/../public")

    app.use '/', require('../routes/index');

    app.use serveIndex("#{__dirname}/../public")
    app.use errorHandler() if process.env.NODE_ENV is "development"

    module.exports = app
