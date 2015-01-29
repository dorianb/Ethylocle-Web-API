# Routing trip requests

    express = require 'express'
    router = express.Router()
    db = require '../lib/db'
    tripSearch = require '../lib/tripsearch'
    geolib = require 'geolib'

    errorMessage = (res, err) ->
      res.json
        result: false
        data: "Une erreur inattendue est survenue: " + err

## Get trips

    router.post '/gettrips', (req, res) ->
      if req.session.userId and req.session.email
        body = {}
        for k, v of req.body
          continue unless v and k in ["latStart", "lonStart", "latEnd", "lonEnd", "dateTime", "numberOfPeople"]
          body[k] = v
        tripSearch "#{__dirname}/../db", req.session.userId, body, (err, trips) ->
          data = []
          datum = {}
          client = db "#{__dirname}/../db/trip"
          getTripDetails = (i) ->
            if i < trips.length
              client.trips.get trips[i], (err, trip) ->
                if err
                  errorMessage res, err
                else
                  datum.id = trip.id
                  datum.distanceToStart = geolib.getDistance({latitude: body.latStart, longitude: body.lonStart}, {latitude: trip.latStart, longitude: trip.lonStart})/1000
                  datum.distanceToEnd = geolib.getDistance({latitude: body.latEnd, longitude: body.lonEnd}, {latitude: trip.latEnd, longitude: trip.lonEnd})/1000
                  datum.dateTime = trip.dateTime
                  datum.numberOfPeople = trip.numberOfPeople
                  # Créer une fonction pour déterminer le prix maximal en fonction du nombre de parties prenantes
                  datum.maxPrice = trip.price
                  data.push datum
            else
              client.close()
              res.json
                result: true
                data: data
          getTripDetails 0
      else
        res.json
          result: false
          data: "Authentification requise"

## Join trip

    router.post '/jointrip', (req, res) ->

## Create trip

    router.post '/createtrip', (req, res) ->
      if req.session.userId and req.session.email
        if req.body.numberOfPeople > 2
          res.json
            result: false
            data: "Impossible de créer un trajet pour plus de 2 personnes"
        else
          client = db "#{__dirname}/../db/trip"
          data = {}
          for k, v of req.body
            continue unless v and k in ["adressStart", "latStart", "lonStart", "addressEnd", "latEnd", "lonEnd", "dateTime", "numberOfPeople"]
            data[k] = v
            if k is 'numberOfPeople'
              i = 1
              while i < v
                data["passenger_" + ++i] = req.session.userId
          data.price = '30' #A déterminer à l'aide de l'api taxi G7
          client.trips.getMaxId (err, maxId) ->
            if err
              errorMessage res, err
              client.close()
            else
              client.trips.set ++maxId, data, (err) ->
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

## Get trip data

    router.post '/gettripdata', (req, res) ->

    module.exports = router
