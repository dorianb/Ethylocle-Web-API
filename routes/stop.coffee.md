# Routing stop requests

    express = require 'express'
    router = express.Router()
    db = require '../lib/db'

    errorMessage = (res, err) ->
      res.json
        result: false
        data: "Une erreur inattendue est survenue: " + err

    module.exports = router
