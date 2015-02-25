# Model Factory

    config = require '../../package'
    levelDB = require '../model/levelDB/up'

    ModelFactory = () ->
      switch config.factory
        when "levelDB" then new levelDB "#{__dirname}/../../db/tmp"
        when "postgreSQL" then null

    module.exports = ModelFactory
