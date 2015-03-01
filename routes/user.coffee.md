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
        model().get User({id: req.session.userId}), (err, message) ->
          if err
            send res, error(err)
          else
            send res, message
      else
        send res, {result: false, data: "Authentification requise"}

## Get user by Id

    router.post '/getbyid', (req, res) ->
      if req.session.userId and req.session.email
        if req.body.hasOwnProperty('id')
          model().getById User({id: req.body.id}), (err, message) ->
            if err
              send res, error(err)
            else
              send res, message
        else
          send res, {result: false, data: "Identifiant manquant"}
      else
        send res, {result: false, data: "Authentification requise"}

## Delete

    router.post '/delete', (req, res) ->
      if req.session.userId and req.session.email
        model().delete User({id: req.session.userId}), (err, message) ->
          if err
            send res, error(err)
          else if message.result
            req.session.destroy (err) ->
              if err
                send res, error(err)
              else
                send res, message
          else
            send res, message
      else
        send res, {result: false, data: "Authentification requise"}

## Sign out

    router.post '/signout', (req, res) ->
      if req.session.userId and req.session.email
        req.session.destroy (err) ->
          if err
            send res, error(err)
          else
            send res, {result: true, data: null}
      else
        send res, {result: false, data: "Authentification requise"}

    module.exports = router
