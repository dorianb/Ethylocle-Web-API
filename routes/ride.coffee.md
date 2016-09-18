# Routing ride requests

    express = require 'express'
    router = express.Router()

    model = require '../lib/factory/model'
    User = require '../lib/entity/user'
    Ride = require '../lib/entity/ride'
    RideCriteria = require '../lib/entity/rideCriteria'

    moment = require 'moment'

    error = (err) ->
      result: false
      data: "Une erreur inattendue est survenue: " + err.message

    send = (res, message) ->
      res.json
        result: message.result
        data: message.data

## Has ride

    router.post '/has', (req, res) ->
      return send res, {result: false, data: "Authentification requise"} unless req.session.userId and req.session.email
      model().hasRide User(id: req.session.userId), (err, message) ->
        return send res, error(err) if err
        send res, message

## Search rides

    router.post '/search', (req, res) ->
      return send res, {result: false, data: "Authentification requise"} unless req.session.userId and req.session.email
      rideCriteria = RideCriteria req.body
      return send res, {result: false, data: "Le nombre de personnes < 1"} if rideCriteria.numberOfPeople < 1
      model().searchRide User({id: req.session.userId}), rideCriteria, (err, message) ->
        return send res, error(err) if err
        send res, message

## Join ride

    router.post '/join', (req, res) ->
      return send res, {result: false, data: "Authentification requise"} unless req.session.userId and req.session.email
      return send res, {result: false, data: "Nombre de personnes manquant"} unless req.body.hasOwnProperty('numberOfPeople')
      return send res, {result: false, data: "Identifiant du trajet manquant"} unless req.body.hasOwnProperty('id')
      user = User id: req.session.userId
      rideCriteria = RideCriteria req.body
      ride = Ride req.body
      return send res, {result: false, data: "Le nombre de personnes est nul"} if rideCriteria.numberOfPeople < 1
      return send res, {result: false, data: "Impossible de rejoindre un trajet avec plus de 3 personnes"} if rideCriteria.numberOfPeople > 3
      model().hasRide user, (err, message) ->
        return send res, error(err) if err
        return send res, {result: false, data: "Vous avez déjà un trajet en cours"} if message.result
        model().joinRide user, ride, rideCriteria, (err, message) ->
          return send res, error(err) if err
          send res, message

## Create ride

    router.post '/create', (req, res) ->
      return send res, {result: false, data: "Authentification requise"} unless req.session.userId and req.session.email
      user = User {id: req.session.userId}
      rideCriteria = RideCriteria req.body
      return send res, {result: false, data: "Le nombre d'arguments est insuffisant"} if Object.keys(rideCriteria.get()).length < 8
      return send res, {result: false, data: "Le nombre de personnes est nul"} if +rideCriteria.numberOfPeople < 1
      return send res, {result: false, data: "Impossible de créer un trajet pour plus de 2 personnes"} if +rideCriteria.numberOfPeople > 2
      return send res, {result: false, data: "La date et l'heure fournies sont passées"} if moment(rideCriteria.dateTime, "DD-MM-YYYY H:mm").isBefore moment()
      model().hasRide user, (err, message) ->
        return send res, error(err) if err
        return send res, {result: false, data: "Vous avez déjà un trajet en cours"} if message.result
        ride = Ride rideCriteria
        ride.numberOfPassenger = rideCriteria.numberOfPeople
        i = 0
        while i < +ride.numberOfPassenger
          ride["passenger_" + ++i] = user.id
        ride.setPrice()
        model().createRide user, ride, (err, message) ->
          return send res, error(err) if err
          send res, message

## Get ride

    router.post '/get', (req, res) ->
      return send res, {result: false, data: "Authentification requise"} unless req.session.userId and req.session.email
      model().getRide User({id: req.session.userId}), (err, message) ->
        return send res, error(err) if err
        send res, message

## Get ride by id

    router.post '/getbyid', (req, res) ->
      return send res, {result: false, data: "Authentification requise"} unless req.session.userId and req.session.email
      return send res, {result: false, data: "Identifiant du trajet manquant"} unless req.body.hasOwnProperty('id')
      model().getRideById Ride({id: req.body.id}), (err, message) ->
        return send res, error(err) if err
        send res, message

    module.exports = router
