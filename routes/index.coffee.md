# Routing from index

    express = require 'express'
    router = express.Router()
    db = require '../lib/db'

## GET Index page

    router.get '/', (req, res) ->
        res.render 'index', {username: req.session.username, lastname: req.session.lastname, firstname: req.session.firstname, email: req.session.email}

## POST Sign in

    router.post '/Connexion', (req, res) ->
      client = db "#{__dirname}/../db"
      client.users.get req.body.login, (err, user) ->
        return next err if err
        if user.username is req.body.login and user.password is req.body.password
          setSessionCookie req, user
          res.json
            user: user
          client.close()
        else
          client.users.getByEmail req.body.login, (err, userByEmail) ->
            return next err if err
            client.users.get userByEmail.username, (err, user) ->
              return next err if err
              if user.email is req.body.login and user.password is req.body.password
                setSessionCookie req, user
                res.json
                  user: user
              else
                res.json
                  message: "Identifiant/email ou mot de passe incorrect"
              client.close()

    setSessionCookie = (req, user) ->
      req.session.username = user.username
      req.session.lastname = user.lastname
      req.session.firstname = user.firstname
      req.session.email = user.email
      if req.body.rememberMe == "true"
        req.session.cookie.maxAge = null
      console.log "Cookie: " + req.session.username + " " + req.session.cookie.maxAge/1000 + "s"

## POST Sign up

    router.post '/Inscription', (req, res) ->
      client = db "#{__dirname}/../db"
      client.users.get req.body.username, (err, user) ->
        return next err if err
        if user.username is req.body.username
          res.json
            message: "L'identifiant est déjà utilisé"
          client.close()
        else
          client.users.getByEmail req.body.email, (err, userByEmail) ->
            return next err if err
            client.users.get userByEmail.username, (err, user) ->
              return next err if err
              if user.email is req.body.email
                res.json
                  message: "L'email est déjà utilisé"
                client.close()
              else
                client.users.set req.body.username,
                  lastname: req.body.lastname
                  firstname: req.body.firstname
                  password: req.body.password
                  email: req.body.email
                , (err) ->
                  return next err if err
                  client.users.setByEmail req.body.email,
                    username: req.body.username
                  , (err) ->
                    return next err if err
                    client.users.get req.body.username, (err, user) ->
                      return next err if err
                      if user.username is req.body.username and user.password is req.body.password
                        setSessionCookie req, user
                        res.json
                          user: user
                        client.close()
                      else
                        res.json
                          message: "Une erreur inattendue est survenue"
                        client.close()

## POST Log out

    router.post '/Deconnexion', (req, res) ->
      req.session.username = null
      req.session.lastname = null
      req.session.firstname = null
      req.session.email = null
      req.session.cookie.maxAge = 0
      res.json
        message: "Déconnexion"

    module.exports = router
