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
      data: "Une erreur inattendue est survenue: " + err.message

    send = (res, message) ->
      res.json
        result: message.result
        data: message.data

## Sign in

    router.post '/signin', (req, res) ->
      return send res, {result: false, data: "Email ou mot de passe manquant"} unless req.body.hasOwnProperty("email") and req.body.hasOwnProperty("password")
      model().signIn User(req.body), (err, message) ->
        return send res, error(err) if err
        session req, message.user if message.result
        send res, message

## Check password

    router.post '/checkpassword', (req, res) ->
      return send res, {result: false, data: "Authentification requise"} unless req.session.userId and req.session.email
      return send res, {result: false, data: "Mot de passe manquant"} unless req.body.hasOwnProperty("password")
      model().checkPassword User({id: req.session.userId, password: req.body.password}), (err, message) ->
        return send res, error(err) if err
        send res, message

## Sign up

    router.post '/signup', (req, res) ->
      return send res, {result: false, data: "Email ou mot de passe manquant"} unless req.body.hasOwnProperty("email") and req.body.hasOwnProperty("password")
      user = User req.body
      return send res, {result: false, data: "Cette adresse email est invalide"} unless user.isEmail()
      return send res, {result: false, data: "Le mot de passe doit comporter au moins 8 caractères"} unless user.isPassword()
      model().signUp user, (err, message) ->
        return send res, error(err) if err
        session req, message.user if message.result
        send res, message

## Update email

    router.post '/updateemail', (req, res) ->
      return send res, {result: false, data: "Authentification requise"} unless req.session.userId and req.session.email
      return send res, {result: false, data: "Email manquant"} unless req.body.hasOwnProperty("email")
      user = User()
      user.id = req.session.userId
      user.email = req.body.email
      return send res, {result: false, data: "Cette adresse email est invalide"} unless user.isEmail()
      model().updateEmail user, (err, message) ->
        return send res, error(err) if err
        session req, user if message.result
        send res, message

## Update user data

    router.post '/update', (req, res) ->
      return send res, {result: false, data: "Authentification requise"} unless req.session.userId and req.session.email
      return send res, {result: false, data: "La requête ne comporte aucun argument"} unless Object.keys(req.body).length > 0
      user = User req.body
      user.id = req.session.userId
      user.email = ""
      return send res, {result: false, data: "Le mot de passe doit comporter au moins 8 caractères"} if req.body.hasOwnProperty("password") and !user.isPassword()
      model().update user, (err, message) ->
        return send res, error(err) if err
        send res, message

## Get user

    router.post '/get', (req, res) ->
      return send res, {result: false, data: "Authentification requise"} unless req.session.userId and req.session.email
      model().get User({id: req.session.userId}), (err, message) ->
        return send res, error(err) if err
        send res, message

## Get user by Id

    router.post '/getbyid', (req, res) ->
      return send res, {result: false, data: "Authentification requise"} unless req.session.userId and req.session.email
      return send res, {result: false, data: "Identifiant manquant"} unless req.body.hasOwnProperty('id')
      model().getById User({id: req.body.id}), (err, message) ->
        return send res, error(err) if err
        send res, message

## Delete

    router.post '/delete', (req, res) ->
      return send res, {result: false, data: "Authentification requise"} unless req.session.userId and req.session.email
      model().delete User({id: req.session.userId}), (err, message) ->
        return send res, error(err) if err
        if message.result
          req.session.destroy (err) ->
            return send res, error(err) if err
            send res, message
        else
          send res, message

## Sign out

    router.post '/signout', (req, res) ->
      return send res, {result: false, data: "Authentification requise"} unless req.session.userId and req.session.email
      req.session.destroy (err) ->
        return send res, error(err) if err
        send res, {result: true, data: null}

    module.exports = router
