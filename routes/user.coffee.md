# Routing user requests

    express = require 'express'
    router = express.Router()
    model = require '../lib/factory/model'
    User = require '../lib/entity/user'

    session = (req, user) ->
      req.session.userId = user.id
      req.session.email = user.email
      req.session.cookie.maxAge = 3600000
      #console.log "Cookie: " + req.session.userId + " " + req.session.email + " " + req.session.cookie.maxAge/1000 + "s"

    error = (err) ->
      result: false
      data: "Une erreur inattendue est survenue: " + err.send

    send = (res, message) ->
      res.json
        result: message.result
        data: message.data

## Sign in

    router.post '/signin', (req, res) ->
      if req.body.hasOwnProperty("email") and req.body.hasOwnProperty("password")
        model().signIn User(req.body), (err, message) ->
          if err
            send res, error(err)
          else if message.result
            session req, message.user
            send res, message
          else
            send res, message
      else
        send res, {result: false, data: "Email ou mot de passe manquant"}

## Check password

    router.post '/checkpassword', (req, res) ->
      if req.session.userId and req.session.email
        if req.body.hasOwnProperty("password")
          model().checkPassword User({id: req.session.userId, password: req.body.password}), (err, message) ->
            if err
              send res, error(err)
            else
              send res, message
        else
          send res, {result: false, data: "Mot de passe manquant"}
      else
        send res, {result: false, data: "Authentification requise"}

## Sign up

    router.post '/signup', (req, res) ->
      if req.body.hasOwnProperty("email") and req.body.hasOwnProperty("password")
        user = User req.body
        if user.isEmail()
          if user.isPassword()
            model().signUp user, (err, message) ->
              if err
                send res, error(err)
              else if message.result
                session req, message.user
                send res, message
              else
                send res, message
          else
            send res, {result: false, data: "Le mot de passe doit comporter au moins 8 caractères"}
        else
          send res, {result: false, data: "Cette adresse email est invalide"}
      else
        send res, {result: false, data: "Email ou mot de passe manquant"}

## Update email

    router.post '/updateemail', (req, res) ->
      if req.session.userId and req.session.email
        if req.body.hasOwnProperty("email")
          user = User()
          user.id = req.session.userId
          user.email = req.body.email
          if user.isEmail()
            model().updateEmail user, (err, message) ->
              if err
                send res, error(err)
              else if message.result
                session req, user
                send res, message
              else
                send res, message
          else
            send res, {result: false, data: "Cette adresse email est invalide"}
        else
          send res, {result: false, data: "Email manquant"}
      else
        send res, {result: false, data: "Authentification requise"}

## Update user data

    router.post '/update', (req, res) ->
      if req.session.userId and req.session.email
        if Object.keys(req.body).length > 0
          user = User req.body
          user.id = req.session.userId
          user.email = ""
          if req.body.hasOwnProperty("password") and !user.isPassword()
            return send res, {result: false, data: "Le mot de passe doit comporter au moins 8 caractères"}
          model().update user, (err, message) ->
            if err
              send res, error(err)
            else
              send res, message
        else
          send res, {result: false, data: "La requête ne comporte aucun argument"}
      else
        send res, {result: false, data: "Authentification requise"}

## Get user

    router.post '/get', (req, res) ->
      if req.session.userId and req.session.email
        client = db "#{__dirname}/../db/user"

        # Get
        # Envoie l'id
        # Retourne true ou false avec les données privées et publics sans le mot de passe

        ###client.users.get req.session.userId, (err, user) ->
          if err
            errorsend res, err
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
              errorsend res, err
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
        # Retourne true ou false avec un send

        ###client.trips.getByPassengerTripInProgress req.session.userId, moment(), (err, trip) ->
          if err
            client.close()
            errorsend res, err
          else if trip.id
            client.close()
            res.json
              result: false
              data: "Impossible de supprimer votre compte si vous avez un trajet en cours"
          else
            client.close (err) ->
              if err
                errorsend res, err
              else
                client = db "#{__dirname}/../db/user"
                client.users.get req.session.userId, (err, user) ->
                  if err
                    errorsend res, err
                    client.close()
                  else
                    client.users.del req.session.userId, user, (err) ->
                      if err
                        errorsend res, err
                        client.close()
                      else
                        client.users.delByEmail req.session.email, user, (err) ->
                          if err
                            errorsend res, err
                            client.close()
                          else
                            req.session.destroy (err) ->
                              if err
                                errorsend res, err
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
            errorsend res, err
          else
            res.json
              result: true
              data: null
      else
        res.json
          result: false
          data: "Authentification requise"

    module.exports = router
