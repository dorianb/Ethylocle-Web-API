# Routing trip requests

    express = require 'express'
    router = express.Router()

    model = require '../lib/factory/model'
    User = require '../lib/entity/user'
    Trip = require '../lib/entity/trip'
    TripCriteria = require '../lib/entity/tripCriteria'

    moment = require 'moment'

    error = (err) ->
      result: false
      data: "Une erreur inattendue est survenue: " + err.message

    send = (res, message) ->
      res.json
        result: message.result
        data: message.data

## Has trip

    router.post '/has', (req, res) ->
      return send res, {result: false, data: "Authentification requise"} unless req.session.userId and req.session.email
      model().hasTrip User(id: req.session.userId), (err, message) ->
        return send res, error(err) if err
        send res, message

## Search trips

    router.post '/search', (req, res) ->
      return send res, {result: false, data: "Authentification requise"} unless req.session.userId and req.session.email
      tripCriteria = TripCriteria req.body
      return send res, {result: false, data: "Le nombre de personnes < 1"} if tripCriteria.numberOfPeople < 1
      model().searchTrip User({id: req.session.userId}), tripCriteria, (err, message) ->
        return send res, error(err) if err
        send res, message

## Join trip

    router.post '/join', (req, res) ->
      return send res, {result: false, data: "Authentification requise"} unless req.session.userId and req.session.email
      return send res, {result: false, data: "Nombre de personnes manquant"} unless req.body.hasOwnProperty('numberOfPeople')
      return send res, {result: false, data: "Identifiant du trajet manquant"} unless req.body.hasOwnProperty('id')
      tripCriteria = TripCriteria req.body
      trip = Trip req.body
      return send res, {result: false, data: "Le nombre de personnes est nul"} if tripCriteria.numberOfPeople < 1
      return send res, {result: false, data: "Impossible de rejoindre un trajet avec plus de 3 personnes"} if tripCriteria.numberOfPeople > 3
      model().joinTrip User({id: req.session.userId}), trip, tripCriteria, (err, message) ->
        return send res, error(err) if err
        send res, message

## Create trip

    router.post '/create', (req, res) ->
      return send res, {result: false, data: "Authentification requise"} unless req.session.userId and req.session.email
      user = User {id: req.session.userId}
      tripCriteria = TripCriteria req.body
      return send res, {result: false, data: "Le nombre d'arguments est insuffisant"} if Object.keys(tripCriteria.get()).length < 8
      return send res, {result: false, data: "Le nombre de personnes est nul"} if tripCriteria.numberOfPeople < 1
      return send res, {result: false, data: "Impossible de créer un trajet pour plus de 2 personnes"} if tripCriteria.numberOfPeople > 2
      return send res, {result: false, data: "La date et l'heure fournies sont passées"} if moment(tripCriteria.dateTime, "DD-MM-YYYY H:mm") < moment()
      model = model()
      model.hasTrip user, (err, message) ->
        return send res, error(err) if err
        return send res, {result: false, data: "Vous avez déjà un trajet en cours"} if message.result
        trip = Trip tripCriteria
        trip.numberOfPassenger = tripCriteria.numberOfPeople
        i = 0
        while i < +trip.numberOfPassenger
          trip["passenger_" + ++i] = user.id
        trip.setPrice()
        model.createTrip user, trip, (err, message) ->
          return send res, error(err) if err
          send res, message

## Get trip

    router.post '/get', (req, res) ->
      return send res, {result: false, data: "Authentification requise"} unless req.session.userId and req.session.email
      model().getTrip User({id: req.session.userId}), (err, message) ->
        return send res, error(err) if err
        send res, message

## Get trip by id

    router.post '/getbyid', (req, res) ->
      return send res, {result: false, data: "Authentification requise"} unless req.session.userId and req.session.email
      return send res, {result: false, data: "Identifiant du trajet manquant"} unless req.body.hasOwnProperty('id')
      model().getTripById Trip({id: req.body.id}), (err, message) ->
        return send res, error(err) if err
        send res, message

    module.exports = router
