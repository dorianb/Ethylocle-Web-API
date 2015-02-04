# Routing trip requests

    express = require 'express'
    router = express.Router()
    db = require '../lib/db'
    tripSearch = require '../lib/tripsearch'
    tripPrice = require '../lib/tripprice'
    geolib = require 'geolib'
    moment = require 'moment'

    errorMessage = (res, err) ->
      res.json
        result: false
        data: "Une erreur inattendue est survenue: " + err

## Has trip

    router.post '/hastrip', (req, res) ->
      if req.session.userId and req.session.email
        client = db "#{__dirname}/../db/trip"
        client.trips.getByPassengerTripInProgress req.session.userId, moment(), (err, trip) ->
          if err
            errorMessage res, err
          else if trip.id
            res.json
              result: true
              data: null
          else
            res.json
              result: false
              data: "Aucun trajet en cours"
          client.close()
      else
        res.json
          result: false
          data: "Authentification requise"

## Get trips

    router.post '/gettrips', (req, res) ->
      if req.session.userId and req.session.email
        body = {}
        for k, v of req.body
          continue unless v and k in ["latStart", "lonStart", "latEnd", "lonEnd", "dateTime", "numberOfPeople"]
          body[k] = v
        if body.numberOfPeople < 1
          res.json
            result: false
            data: "Le nombre de personne est inférieur à 1"
        else
          tripSearch "#{__dirname}/../db", req.session.userId, body, (err, trips) ->
            tripsearchClient = db "#{__dirname}/../db/tripsearch"
            tripsearchClient.tripsearch.getByUser req.session.userId, (err, result) ->
              if err
                tripsearchClient.close()
                errorMessage res, err
              else
                delTripSearchByUser = (i) ->
                  if i < result.length
                    tripsearchClient.tripsearch.del result[i].userId, result[i].distance, result[i].tripId, (err) ->
                      if err
                        tripsearchClient.close()
                        errorMessage res, err
                      else
                        delTripSearchByUser i+1
                  else
                    tripsearchClient.close()
                    client = db "#{__dirname}/../db/trip"
                    data = []
                    getTripDetails = (i) ->
                      if i < trips.length
                        client.trips.get trips[i], (err, trip) ->
                          if err
                            client.close()
                            errorMessage res, err
                          else
                            datum = {}
                            datum.id = trip.id
                            datum.distanceToStart = geolib.getDistance({latitude: body.latStart, longitude: body.lonStart}, {latitude: trip.latStart, longitude: trip.lonStart})/1000
                            datum.distanceToEnd = geolib.getDistance({latitude: body.latEnd, longitude: body.lonEnd}, {latitude: trip.latEnd, longitude: trip.lonEnd})/1000
                            datum.dateTime = trip.dateTime
                            datum.numberOfPassenger = trip.numberOfPassenger
                            tripPrice().getPresumedPrice trip, (err, price) ->
                              datum.maxPrice = price
                              data.push datum
                              getTripDetails i+1
                      else
                        client.close()
                        res.json
                          result: true
                          data: data
                    getTripDetails 0
                delTripSearchByUser 0
      else
        res.json
          result: false
          data: "Authentification requise"

## Join trip

    router.post '/jointrip', (req, res) ->
      if req.session.userId and req.session.email
        unless req.body.numberOfPeople
          res.json
            result: false
            data: "Veuillez fournir un nombre de personne"
        else if req.body.numberOfPeople > 3
          res.json
            result: false
            data: "Impossible de rejoindre un trajet si plus de 3 personnes"
        else if req.body.numberOfPeople < 1
          res.json
            result: false
            data: "Le nombre de personne est inférieur à 1"
        else unless req.body.id
          res.json
            result: false
            data: "Veuillez fournir l'identifiant du trajet"
        else
          client = db "#{__dirname}/../db/trip"
          client.trips.getByPassengerTripInProgress req.session.userId, moment(), (err, trip) ->
            if err
              errorMessage res, err
              client.close()
            else if trip.id
              res.json
                result: false
                data: "Vous avez déjà un trajet en cours"
              client.close()
            else
              client.trips.get req.body.id, (err, trip) ->
                if err
                  errorMessage res, err
                  client.close()
                else if trip.id
                  if req.body.numberOfPeople <= 4 - +trip.numberOfPassenger
                    data = {}
                    data.numberOfPassenger = +trip.numberOfPassenger + +req.body.numberOfPeople
                    i = trip.numberOfPassenger
                    while i < data.numberOfPassenger
                      data["passenger_" + ++i] = req.session.userId
                    client.trips.set trip.id, data, (err) ->
                      if err
                        errorMessage res, err
                        client.close()
                      else
                        client.trips.get trip.id, (err, trip) ->
                          if err
                            errorMessage res, err
                            client.close()
                          else
                            client.trips.setByPassenger req.session.userId, trip, (err) ->
                              res.json
                                result: true
                                data: null
                              client.close()
                  else
                    res.json
                      result: false
                      data: "Il n'y a plus assez de places disponibles pour ce trajet"
                    client.close()
                else
                  res.json
                    result: false
                    data: "Le trajet n'existe plus"
                  client.close()
      else
        res.json
          result: false
          data: "Authentification requise"

## Create trip

    router.post '/createtrip', (req, res) ->
      if req.session.userId and req.session.email
        unless req.body.numberOfPeople
          res.json
            result: false
            data: "Veuillez fournir un nombre de personne"
        else if req.body.numberOfPeople > 2
          res.json
            result: false
            data: "Impossible de créer un trajet pour plus de 2 personnes"
        else if req.body.numberOfPeople < 1
          res.json
            result: false
            data: "Le nombre de personne est inférieur à 1"
        else unless req.body.dateTime
          res.json
            result: false
            data: "Veuillez fournir une date"
        else if moment(req.body.dateTime, "DD-MM-YYYY H:mm") < moment()
          res.json
            result: false
            data: "L'heure et la date fournie sont passées"
        else
          client = db "#{__dirname}/../db/trip"
          client.trips.getByPassengerTripInProgress req.session.userId, moment(), (err, trip) ->
            if err
              errorMessage res, err
            else if trip.id
              res.json
                result: false
                data: "Vous avez déjà un trajet en cours"
            else
              data = {}
              counter = 0
              for k, v of req.body
                continue unless v and k in ["addressStart", "latStart", "lonStart", "addressEnd", "latEnd", "lonEnd", "dateTime", "numberOfPeople"]
                counter++
                if k is 'numberOfPeople'
                  data.numberOfPassenger = v
                  i = 0
                  while i < v
                    data["passenger_" + ++i] = req.session.userId
                else
                  data[k] = v
              if counter == 8
                tripPrice().getGlobalPriceFromTaxiAPI data, (err, price) ->
                  data.price = price
                  client.trips.getMaxId (err, maxId) ->
                    if err
                      errorMessage res, err
                      client.close()
                    else
                      client.trips.set ++maxId, data, (err) ->
                        if err
                          errorMessage res, err
                          client.close()
                        else
                          client.trips.get maxId, (err, trip) ->
                            if err
                              errorMessage res, err
                              client.close()
                            else
                              client.trips.setByPassenger req.session.userId, trip, (err) ->
                                res.json
                                  result: true
                                  data: null
                                client.close()
              else
                res.json
                  result: false
                  data: "Le nombre d'arguments est insuffisant"
                client.close()
      else
        res.json
          result: false
          data: "Authentification requise"

## Get trip data

    router.post '/gettripdata', (req, res) ->
      if req.session.userId and req.session.email
        client = db "#{__dirname}/../db/trip"
        client.trips.getByPassengerTripInProgress req.session.userId, moment(), (err, trip) ->
          if err
            errorMessage res, err
            client.close()
          else if trip.id
            client.trips.get trip.id, (err, trip) ->
              if err
                errorMessage res, err
              else
                data = {}
                for k, v of trip
                  continue unless k in ["id", "addressStart", "latStart", "lonStart", "addressEnd", "latEnd", "lonEnd", "dateTime", "numberOfPassenger", "passenger_1", "passenger_2", "passenger_3", "passenger_4"]
                  data[k] = v
                tripPrice().getActualPrice trip, (err, price) ->
                  data.maxPrice = price
                  res.json
                    result: true
                    data: data
              client.close()
          else
            client.close()
            res.json
              result: false
              data: "Aucun trajet en cours"
      else
        res.json
          result: false
          data: "Authentification requise"

### Get trip data by id

    router.post '/gettripdatabyid', (req, res) ->
      if req.session.userId and req.session.email
        if req.body.id
          client = db "#{__dirname}/../db/trip"
          client.trips.get req.body.id, (err, trip) ->
            if err
              errorMessage res, err
            else if trip.id
              data = {}
              for k, v of trip
                continue unless k in ["id", "addressStart", "latStart", "lonStart", "addressEnd", "latEnd", "lonEnd", "dateTime", "numberOfPassenger"]
                data[k] = v
              tripPrice().getPresumedPrice trip, (err, price) ->
                data.maxPrice = price
                res.json
                  result: true
                  data: data
            else
              res.json
                result: false
                data: "Le trajet n'existe plus"
            client.close()
        else
          res.json
            result: false
            data: "L'identifiant du trajet est nul"
      else
        res.json
          result: false
          data: "Authentification requise"

    module.exports = router
