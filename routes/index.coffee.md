# Routing from index

    express = require 'express'
    router = express.Router()
    db = require '../lib/db'

## POST Sign in

    router.post '/Connexion', (req, res) ->
      client = db "#{__dirname}/../db"
      client.users.get req.body.email, (err, user) ->
        return next err if err
        if user.email is req.body.email and user.password is req.body.password
          setSessionCookie req, user
          res.json
            result: true,
            message: null
          client.close()
        else
          res.json
            result: false,
            message: "Email ou mot de passe incorrect"
        client.close()

    setSessionCookie = (req, user) ->
      req.session.email = user.email
      req.session.cookie.maxAge = null
      console.log "Cookie: " + req.session.email + " " + req.session.cookie.maxAge/1000 + "s"

## POST Sign up

    router.post '/Inscription', (req, res) ->
      client = db "#{__dirname}/../db"
      client.users.get req.body.email, (err, user) ->
        return next err if err
        if user.email is req.body.email
          res.json
            result: false,
            message: "L'email n'est pas disponible"
          client.close()
        else
          client.users.set req.body.email,
            email: req.body.email
            password: req.body.password
          , (err) ->
            return next err if err
            client.users.get req.body.email, (err, user) ->
              return next err if err
              if user.email is req.body.email and user.password is req.body.password
                setSessionCookie req, user
                res.json
                  result: true,
                  message: null
                client.close()
              else
                res.json
                  result: false,
                  message: "Une erreur inattendue est survenue"
                client.close()

## POST Log out

    router.post '/Deconnexion', (req, res) ->
      req.session.email = null
      req.session.cookie.maxAge = 0
      res.json
        result: true,
        message: null

    module.exports = router
