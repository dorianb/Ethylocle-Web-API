# Routing trip requests

    express = require 'express'
    router = express.Router()
    db = require '../lib/db'
    tripSearch = require '../lib/tripsearch'
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
              data: trip.id
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
        tripSearch "#{__dirname}/../db", req.session.userId, body, (err, trips) ->
          data = []
          client = db "#{__dirname}/../db/trip"
          getTripDetails = (i) ->
            if i < trips.length
              client.trips.get trips[i], (err, trip) ->
                if err
                  errorMessage res, err
                else
                  datum = {}
                  datum.id = trip.id
                  datum.distanceToStart = geolib.getDistance({latitude: body.latStart, longitude: body.lonStart}, {latitude: trip.latStart, longitude: trip.lonStart})/1000
                  datum.distanceToEnd = geolib.getDistance({latitude: body.latEnd, longitude: body.lonEnd}, {latitude: trip.latEnd, longitude: trip.lonEnd})/1000
                  datum.dateTime = trip.dateTime
                  datum.numberOfPassenger = trip.numberOfPassenger
                  # Créer une fonction pour déterminer le prix maximal en fonction du nombre de parties prenantes
                  datum.maxPrice = trip.price
                  data.push datum
                  getTripDetails i+1
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
      if req.session.userId and req.session.email
        if req.body.numberOfPeople > 3
          res.json
            result: false
            data: "Impossible de rejoindre un trajet si plus de 3 personnes"
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
                    client.trips.set req.body.id, data, (err) ->
                      if err
                        errorMessage res, err
                        client.close()
                      else
                        client.trips.get req.body.id, (err, trip) ->
                          if err
                            errorMessage res, err
                            client.close()
                          else
                            client.trips.setByPassenger req.session.userId, trip, (err) ->
                              res.json
                                result: true
                                data: trip.id
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
        if req.body.numberOfPeople > 2
          res.json
            result: false
            data: "Impossible de créer un trajet pour plus de 2 personnes"
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
                  i = 1
                  while i < v
                    data["passenger_" + ++i] = req.session.userId
                else
                  data[k] = v
              if counter == 8
                data.price = '30' # A déterminer à partir du prix de la course via l'API G7
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
                                data: trip.id
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
                  continue unless k in ["addressStart", "latStart", "lonStart", "addressEnd", "latEnd", "lonEnd", "dateTime", "numberOfPassenger"]
                  data[k] = v
                # Renvoyer le prix qu'a payé l'utilisateur et non le prix global de la course calculé à partir de l'API G7
                data.price = trip.price
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

    module.exports = router
