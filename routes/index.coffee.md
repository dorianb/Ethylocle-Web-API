# Routing from index

    express = require 'express'
    router = express.Router()
    db = require '../lib/db'

## Sign in

    router.post '/Connexion', (req, res) ->
      client = db "#{__dirname}/../db"
      client.users.get req.body.email, (err, user) ->
        if err
          res.json
            result: false
            data: "Une erreur inattendue est survenue"
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

    setSessionCookie = (req, user) ->
      req.session.email = user.email
      req.session.cookie.maxAge = null
      console.log "Cookie: " + req.session.email + " " + req.session.cookie.maxAge/1000 + "s"

## Sign up

    router.post '/Inscription', (req, res) ->
      client = db "#{__dirname}/../db"
      client.users.get req.body.email, (err, user) ->
        if err
          res.json
            result: false
            data: "Une erreur inattendue est survenue"
          client.close()
        else
          if user.email is req.body.email
            res.json
              result: false
              data: "L'email n'est pas disponible"
          else
            client.users.set req.body.email,
              email: req.body.email
              password: req.body.password
            , (err) ->
              if err
                res.json
                  result: false
                  data: "Une erreur inattendue est survenue"
                client.close()
              else
                client.users.get req.body.email, (err, user) ->
                  if err
                    res.json
                      result: false
                      data: "Une erreur inattendue est survenue"
                  else
                    if user.email is req.body.email and user.password is req.body.password
                      setSessionCookie req, user
                      res.json
                        result: true
                        data: null
                    else
                      res.json
                        result: false
                        data: "Une erreur inattendue est survenue"
                  client.close()

## Update user information

    router.post '/Update', (req, res) ->
      if req.session.email is undefined
        res.json
          result: false
          data: "Authentification requise"
      else
        client = db "#{__dirname}/../db"
        client.users.set req.session.email,
          email: req.session.email
          image: req.body.image unless req.body.image is undefined
          lastname: req.body.lastname unless req.body.lastname is undefined
          firstname: req.body.firstname unless req.body.firstname is undefined
          age: req.body.age unless req.body.age is undefined
          gender: req.body.gender unless req.body.gender is undefined
          weight: req.body.weight unless req.body.weight is undefined
          address: req.body.address unless req.body.address is undefined
          zipCode: req.body.zipCode unless req.body.zipCode is undefined
          city: req.body.city unless req.body.city is undefined
          country: req.body.country unless req.body.country is undefined
          phone: req.body.phone unless req.body.phone is undefined
          vehicul: req.body.vehicul unless req.body.vehicul is undefined
          password: req.body.password unless req.body.password is undefined
        , (err) ->
          if err
            res.json
              result: false
              data: "Une erreur inattendue est survenue"
          else
            res.json
              result: true
              data: null
          client.close()

## Get user information

    router.post '/Utilisateur', (req, res) ->
      if req.session.email is undefined
        res.json
          result: false
          data: "Authentification requise"
      else
        client = db "#{__dirname}/../db"
        client.users.get req.session.email, (err, user) ->
          if err
            res.json
              result: false
              data: "Une erreur inattendue est survenue"
          else
            res.json
              result: true
              data: user

## Delete

    router.post '/Delete', (req, res) ->
      if req.session.email is undefined
        res.json
          result: false
          data: "Authentification requise"
      else
        client = db "#{__dirname}/../db"
        client.users.get req.session.email, (err, user) ->
          if err
            res.json
              result: false
              data: "Une erreur inattendue est survenue"
            client.close()
          else
            client.users.del req.session.email, user, (err) ->
              if err
                res.json
                  result: false
                  data: "Une erreur inattendue est survenue"
              else
                res.json
                  result: true
                  data: null
              client.close()

## Sign out

    router.post '/Deconnexion', (req, res) ->
      if req.session.email is undefined
        res.json
          result: false
          data: "Authentification requise"
      else
        req.session.email = undefined
        req.session.cookie.maxAge = 0
        res.json
          result: true
          data: null

    module.exports = router
