# Routing user requests

    express = require 'express'
    router = express.Router()
    db = require '../lib/db'

    setSessionCookie = (req, user) ->
      req.session.email = user.email
      req.session.cookie.maxAge = null
      console.log "Cookie: " + req.session.email + " " + req.session.cookie.maxAge/1000 + "s"

    errorMessage = (res, err) ->
      res.json
        result: false
        data: "Une erreur inattendue est survenue: " + err

## Sign in

    router.post '/signin', (req, res) ->
      client = db "#{__dirname}/../db"
      client.users.get req.body.email, (err, user) ->
        if err
          errorMessage(res, err)
        else
          if user.email is req.body.email and user.password is req.body.password
            setSessionCookie req, user
            res.json
              result: true
              data: null
          else
            res.json
              result: false
              data: "Email ou mot de passe incorrect"
        client.close()

## Sign up

    router.post '/signup', (req, res) ->
      client = db "#{__dirname}/../db"
      client.users.get req.body.email, (err, user) ->
        if err
          errorMessage(res, err)
          client.close()
        else
          if user.email is req.body.email
            res.json
              result: false
              data: "L'email n'est pas disponible"
            client.close()
          else
            client.users.set req.body.email,
              password: req.body.password
            , (err) ->
              if err
                errorMessage(res, err)
                client.close()
              else
                client.users.get req.body.email, (err, user) ->
                  if err
                    errorMessage(res, err)
                  else
                    if user.email is req.body.email and user.password is req.body.password
                      setSessionCookie req, user
                      res.json
                        result: true
                        data: null
                    else
                      errorMessage(res, err)
                  client.close()

## Update user data

    router.post '/update', (req, res) ->
      console.log "Update user data: " + req.session.email
      if req.session.email
        client = db "#{__dirname}/../db"
        data = {}
        for k, v of req.body
          continue unless v
          data[k] = v
        client.users.set req.session.email, data, (err) ->
          if err
            errorMessage(res, err)
          else
            res.json
              result: true
              data: null
          client.close()
      else
        res.json
          result: false
          data: "Authentification requise"

## Get user data

    router.post '/get', (req, res) ->
      console.log "Get user data: " + req.session.email
      if req.session.email
        client = db "#{__dirname}/../db"
        client.users.get req.session.email, (err, user) ->
          if err
            errorMessage(res, err)
          else
            data = {}
            for k, v of user
              continue if k is 'password'
              data[k] = v
            res.json
              result: true
              data: data
          client.close()
      else
        res.json
          result: false
          data: "Authentification requise"

## Delete

    router.post '/delete', (req, res) ->
      if req.session.email
        client = db "#{__dirname}/../db"
        client.users.get req.session.email, (err, user) ->
          if err
            errorMessage(res, err)
            client.close()
          else
            client.users.del req.session.email, user, (err) ->
              if err
                errorMessage(res, err)
              else
                res.json
                  result: true
                  data: null
              client.close()
      else
        res.json
          result: false
          data: "Authentification requise"

## Sign out

    router.post '/signout', (req, res) ->
      if req.session.email
        req.session.email = undefined
        req.session.cookie.maxAge = 0
        res.json
          result: true
          data: null
      else
        res.json
          result: false
          data: "Authentification requise"

    module.exports = router
