# Model Factory

    levelDB = require '../model/levelDB/db'
    postgreSQL= require '../model/postgreSQL/db'

    ModelFactory = (db="#{__dirname}/../../db") ->
      switch require('../../package').factory
        when "levelDB" then levelDB db
        when "postgreSQL" then postgreSQL db

    module.exports = ModelFactory
