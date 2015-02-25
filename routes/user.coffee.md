# Routing user requests

    express = require 'express'
    router = express.Router()
    model = require '../lib/factory/model'
    User = require '../lib/entity/user'

    session = (req, user) ->
      req.session.userId = user.id
      req.session.email = user.email
      req.session.cookie.maxAge = 3600000
      console.log "Cookie: " + req.session.userId + " " + req.session.email + " " + req.session.cookie.maxAge/1000 + "s"

    error = (err) ->
      result: false
      data: "Une erreur inattendue est survenue: " + err.message

    message = (res, response) ->
      res.json
        result: response.result
        data: response.data

## Sign in

    router.post '/signin', (req, res) ->
      if req.body.hasOwnProperty("email") and req.body.hasOwnProperty("password")
        model().signIn req.body, (err, response) ->
          if err
            message res, error(err)
          else if response.result
            session req, response.user
            message res, response
          else
            message res, response
      else
        message res, {result: false, data: "Email ou mot de passe manquant"}

## Check password

    router.post '/checkpassword', (req, res) ->
      if req.session.userId and req.session.email
        if req.body.hasOwnProperty("password")
          model().checkPassword {id: req.session.userId, password: req.body.password}, (err, response) ->
            if err
              message res, error(err)
            else
              message res, response
        else
          message res, {result: false, data: "Mot de passe manquant"}
      else
        message res, {result: false, data: "Authentification requise"}

## Sign up

    isEmail = (email) ->
      regEmail = new RegExp '^[0-9a-z._-]+@{1}[0-9a-z.-]{2,}[.]{1}[a-z]{2,5}$', 'i'
      regEmail.test email

    isPassword = (password) ->
      score = 0
      match = new RegExp "[a-z]+", ""
      if match.test password
        score++
      match = new RegExp "[A-Z]+", ""
      if match.test password
        score++
      match = new RegExp "[0-9]+", ""
      if match.test password
        score++
      match = new RegExp "[^A-Za-z0-9]+", ""
      if match.test password
        score++
      score += password.length
      if score > 8
        return true
      else
        return false

    router.post '/signup', (req, res) ->
      if req.body.email and req.body.password
        if isEmail req.body.email
          if isPassword req.body.password
            client = db "#{__dirname}/../db/user"

            # Sign up
            # Envoie l'email et le mot de passe
            # Retourne true ou false avec un message

            ###client.users.getByEmail req.body.email, (err, user) ->
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
                          client.close()###
          else
            res.json
              result: false
              data: "Le mot de passe doit comporter au moins 8 caractères"
        else
          res.json
            result: false
            data: "Cette adresse email est invalide"
      else
        res.json
          result: false
          data: "L'adresse email ou le mot de passe envoyé est nul"

## Update email

    router.post '/updateemail', (req, res) ->
      if req.session.userId and req.session.email
        if req.body.email
          if isEmail req.body.email
            client = db "#{__dirname}/../db/user"

            # Update email
            # Envoie l'id et l'email
            # Retourne true ou false avec un message

            ###client.users.getByEmail req.body.email, (err, user) ->
              if err
                errorMessage res, err
                client.close()
              else if user.email is req.body.email
                res.json
                  result: false
                  data: "L'email est déjà utilisé pour un autre compte"
                client.close()
              else
                client.users.get req.session.userId, (err, user) ->
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
                          id: req.session.userId
                        , (err) ->
                          if err
                            errorMessage res, err
                            client.close()
                          else
                            client.users.set req.session.userId,
                              email: req.body.email
                            , (err) ->
                              if err
                                errorMessage res, err
                              else
                                setSessionCookie req,
                                  id: req.session.userId
                                  email: req.body.email
                                res.json
                                  result: true
                                  data: null
                              client.close()###
          else
            res.json
              result: false
              data: "Cette adresse email est invalide"
        else
          res.json
            result: false
            data: "L'adresse email envoyée est nulle"
      else
        res.json
          result: false
          data: "Authentification requise"

## Update user data

    router.post '/update', (req, res) ->
      if req.session.userId and req.session.email
        ###data = {}
        for k, v of req.body
          continue unless v and k in ["image", "lastname", "firstname", "birthDate", "gender", "weight", "address", "zipCode", "city", "country", "phone", "password", "latitude", "longitude", "lastKnownPositionDate", "bac", "lastBacKnownDate"]
          data[k] = v###
        if data.password and !isPassword data.password
          res.json
            result: false
            data: "Le mot de passe doit comporter au moins 8 caractères"
        else
          client = db "#{__dirname}/../db/user"

          # Update
          # Envoie l'id et les données à mettre à jour
          # Retourne true ou false avec un message

          ###client.users.set req.session.userId, data, (err) ->
            if err
              errorMessage res, err
            else
              res.json
                result: true
                data: null
            client.close()###
      else
        res.json
          result: false
          data: "Authentification requise"

## Get user

    router.post '/get', (req, res) ->
      if req.session.userId and req.session.email
        client = db "#{__dirname}/../db/user"

        # Get
        # Envoie l'id
        # Retourne true ou false avec les données privées et publics sans le mot de passe

        ###client.users.get req.session.userId, (err, user) ->
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
          client.close()###
      else
        res.json
          result: false
          data: "Authentification requise"

## Get user by Id

    router.post '/getbyid', (req, res) ->
      if req.session.userId and req.session.email
        if req.body.id
          client = db "#{__dirname}/../db/user"

          # Get by id
          # Envoie l'id
          # Retourne true ou false avec les données publics

          ###client.users.get req.body.id, (err, user) ->
            if err
              errorMessage res, err
            else
              data = {}
              for k, v of user
                continue unless k in ["id", "image", "lastname", "firstname", "birthDate", "gender", "phone"]
                data[k] = v
              res.json
                result: true
                data: data
            client.close()###
        else
          res.json
            result: false
            data: "L'identifiant de l'utilisateur est nul"
      else
        res.json
          result: false
          data: "Authentification requise"

## Delete

    router.post '/delete', (req, res) ->
      if req.session.userId and req.session.email
        client = db "#{__dirname}/../db/trip"

        # Delete
        # Envoie l'id
        # Retourne true ou false avec un message

        ###client.trips.getByPassengerTripInProgress req.session.userId, moment(), (err, trip) ->
          if err
            client.close()
            errorMessage res, err
          else if trip.id
            client.close()
            res.json
              result: false
              data: "Impossible de supprimer votre compte si vous avez un trajet en cours"
          else
            client.close (err) ->
              if err
                errorMessage res, err
              else
                client = db "#{__dirname}/../db/user"
                client.users.get req.session.userId, (err, user) ->
                  if err
                    errorMessage res, err
                    client.close()
                  else
                    client.users.del req.session.userId, user, (err) ->
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
                              client.close()###
      else
        res.json
          result: false
          data: "Authentification requise"

## Sign out

    router.post '/signout', (req, res) ->
      if req.session.userId and req.session.email
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
