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
      if req.session.email
        client = db "#{__dirname}/../db"
        client.users.set req.session.email,
          image: req.body.image if req.body.image
          lastname: req.body.lastname if req.body.lastname
          firstname: req.body.firstname if req.body.firstname
          age: req.body.birthDate if req.body.birthDate
          gender: req.body.gender if req.body.gender
          weight: req.body.weight if req.body.weight
          address: req.body.address if req.body.address
          zipCode: req.body.zipCode if req.body.zipCode
          city: req.body.city if req.body.city
          country: req.body.country if req.body.country
          phone: req.body.phone if req.body.phone
          vehicul: req.body.vehicul if req.body.vehicul
          password: req.body.password if req.body.password
          latitude: req.body.latitude if req.body.latitude
          longitude: req.body.longitude if req.body.longitude
          lastknownPositionDate: req.body.lastKnownPositionDate if req.body.lastKnownPositionDate
          bac: req.body.bac if req.body.bac
          lastBacKnownDate: req.body.lastBacKnownDate if req.body.lastBacKnownDate
        , (err) ->
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
      if req.session.email
        client = db "#{__dirname}/../db"
        client.users.get req.session.email, (err, user) ->
          if err
            errorMessage(res, err)
          else
            res.json
              result: true
              data: for k, v of user
                continue if k is 'password'
                key: k
                value: v
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
