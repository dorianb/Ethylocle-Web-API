# Routing user requests

    express = require 'express'
    router = express.Router()
    db = require '../lib/db'

    setSessionCookie = (req, user) ->
      req.session.id = user.id
      req.session.email = user.email
      req.session.cookie.maxAge = 3600000
      console.log "Cookie: " + req.session.id + " " + req.session.email + " " + req.session.cookie.maxAge/1000 + "s"

    errorMessage = (res, err) ->
      res.json
        result: false
        data: "Une erreur inattendue est survenue: " + err.message

## Sign in

    router.post '/signin', (req, res) ->
      client = db "#{__dirname}/../db/user"
      client.users.getByEmail req.body.email, (err, user) ->
        if err
          errorMessage res, err
          client.close()
        else
          client.users.get user.id, (err, user) ->
            if err
              errorMessage res, err
            else if user.email is req.body.email and user.password is req.body.password
              setSessionCookie req, user
              res.json
                result: true
                data: null
            else
              res.json
                result: false
                data: "Email ou mot de passe incorrect"
            client.close()

## Check password

    router.post '/checkpassword', (req, res) ->
      if req.session.id and req.session.email
        client = db "#{__dirname}/../db/user"
        client.users.get req.session.id, (err, user) ->
          if err
            errorMessage res, err
          else if user.email is req.session.email and user.password is req.body.password
            res.json
              result: true
              data: null
          else
            res.json
              result: false
              data: null
          client.close()
      else
        res.json
          result: false
          data: "Authentification requise"

## Sign up

    router.post '/signup', (req, res) ->
      if req.body.email and req.body.password
        client = db "#{__dirname}/../db/user"
        client.users.getByEmail req.body.email, (err, user) ->
          if err
            errorMessage res, err
            client.close()
          else if user.email is req.body.email
            res.json
              result: false
              data: "L'email est déjà utilisé pour un autre compte"
            client.close()
          else
            client.users.getMaxId (err, maxId) ->
              if err
                errorMessage res, err
                client.close()
              else
                data =
                  email: req.body.email
                  password: req.body.password
                data.id = ++maxId
                client.users.set data.id, data, (err) ->
                  if err
                    errorMessage res, err
                    client.close()
                  else
                    client.users.setByEmail data.email, data, (err) ->
                      if err
                        errorMessage res, err
                      else
                        setSessionCookie req, data
                        res.json
                          result: true
                          data: null
                      client.close()
      else
        res.json
          result: false
          data: "L'email ou le mot de passe envoyé est nul"

## Update email

    router.post '/updateemail', (req, res) ->
      if req.session.id and req.session.email
        if req.body.email
          client = db "#{__dirname}/../db/user"
          client.users.getByEmail req.body.email, (err, user) ->
            if err
              errorMessage res, err
              client.close()
            else if user.email is req.body.email
              res.json
                result: false
                data: "L'email est déjà utilisé pour un autre compte"
              client.close()
            else
              client.users.get req.session.id, (err, user) ->
                if err
                  errorMessage res, err
                  client.close()
                else
                  client.users.delByEmail req.session.email, user, (err) ->
                    if err
                      errorMessage res, err
                      client.close()
                    else
                      client.users.setByEmail req.body.email,
                        id: req.session.id
                      , (err) ->
                        if err
                          errorMessage res, err
                          client.close()
                        else
                          client.users.set req.session.id,
                            email: req.body.email
                          , (err) ->
                            if err
                              errorMessage res, err
                            else
                              setSessionCookie req,
                                id: req.session.id
                                email: req.body.email
                              res.json
                                result: true
                                data: null
                            client.close()
        else
          res.json
            result: false
            data: "L'email envoyé est nul"
      else
        res.json
          result: false
          data: "Authentification requise"

## Update user data

    router.post '/update', (req, res) ->
      if req.session.id and req.session.email
        client = db "#{__dirname}/../db/user"
        data = {}
        for k, v of req.body
          continue unless v and k in ["image", "lastname", "firstname", "birthDate", "gender", "weight", "address", "zipCode", "city", "country", "phone", "password", "latitude", "longitude", "lastKnownPositionDate", "bac", "lastBacKnownDate"]
          data[k] = v
        client.users.set req.session.id, data, (err) ->
          if err
            errorMessage res, err
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
      if req.session.id and req.session.email
        client = db "#{__dirname}/../db/user"
        client.users.get req.session.id, (err, user) ->
          if err
            errorMessage res, err
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
      if req.session.id and req.session.email
        client = db "#{__dirname}/../db/user"
        client.users.get req.session.id, (err, user) ->
          if err
            errorMessage res, err
            client.close()
          else
            client.users.del req.session.id, user, (err) ->
              if err
                errorMessage res, err
                client.close()
              else
                client.users.delByEmail req.session.email, user, (err) ->
                  if err
                    errorMessage res, err
                    client.close()
                  else
                    req.session.destroy (err) ->
                      if err
                        errorMessage res, err
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
      if req.session.id and req.session.email
        req.session.destroy (err) ->
          if err
            errorMessage res, err
          else
            res.json
              result: true
              data: null
      else
        res.json
          result: false
          data: "Authentification requise"

    module.exports = router
