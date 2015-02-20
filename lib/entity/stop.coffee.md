# Stop Entity

    Entity = require './entity'

    Stop = (stop) ->
      return new Stop stop unless this instanceof Stop
      Entity.apply this, [stop]
      this.name = stop.name
      this.desc = stop.desc
      this.lat = stop.lat
      this.lon = stop.lon
      this.lineType = stop.lineType
      this.lineName = stop.lineName

    Stop.prototype = Object.create Entity.prototype
    Stop.prototype.constructor = Stop

    Stop.prototype.get = () ->
      result = {}
      for k, v of this
        if v and typeof v is 'string'
          result[k]=v
      return result

    Stop.prototype.toString = () ->
      result = "Stop"
      for k, v of this.get()
        result += " " + k + ":" + v
      return result

    module.exports = Stop
