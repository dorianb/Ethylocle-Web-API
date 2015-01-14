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
        picture: "null"
        lastname: "Zhou"
        firstname: "Maoqiao"
        age: "22"
        gender: "M"
        weight: "75.5"
        address: "162 Boulevard du Général de Gaulle"
        zipCode: "78700"
        city: "Conflans-Sainte-Honorine"
        country: "France"
        phone: "+330619768399"
        vehicul: "Renault mégane"
        password : "1234"
        , (err) ->
        return next err if err
        client.users.get "dorian@ethylocle.com", (err, user) ->
          return next err if err
          user.email.should.eql "dorian@ethylocle.com"
          user.picture.should.eql "null"
          user.lastname.should.eql "Zhou"
          user.firstname.should.eql "Maoqiao"
          user.age.should.eql "22"
          user.gender.should.eql "M"
          user.weight.should.eql "75.5"
          user.address.should.eql "162 Boulevard du Général de Gaulle"
          user.zipCode.should.eql "78700"
          user.city.should.eql "Conflans-Sainte-Honorine"
          user.country.should.eql "France"
          user.phone.should.eql "+330619768399"
          user.vehicul.should.eql "Renault mégane"
          user.password.should.eql "1234"
          client.close()
          next()

        res.json
          result: true
          data: null

## Get user information

    router.post '/Utilisateur', (req, res) ->
      if req.session.email is undefined
        res.json
          result: false
          data: "Authentification requise"
      else
        res.json
          result: true
          data: null

## Delete

    router.post '/Delete', (req, res) ->
      if req.session.email is undefined
        res.json
          result: false
          data: "Authentification requise"
      else
        client = db "#{__dirname}/../db"
        client.users.get req.session.email, (err, user) ->
          return next err if err
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
