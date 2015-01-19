# Export

    level = require 'level'
    stream = require 'stream'
    util = require 'util'

    exportStream = (source, format = 'csv', options) ->
      return new exportStream source, format, options unless this instanceof exportStream
      this.source = level source if typeof source is 'string'
      this.format = format
      this.counter = 0
      this._inBody = true
      stream.Readable.call this, options

    util.inherits exportStream, stream.Readable
    exportStream.prototype._read = (n) ->
      that = this
      user = {}
      that.source.createReadStream
        gte: "users:"
        lte: "users:\xff"
      .on 'data', (data) ->
        [_, email, key] = data.key.split ':'
        if user.email
          unless user.email is email
            counter = 1
            length = Object.keys(user).length
            chunk = ""
            for k, v of user
              chunk += v
              chunk += ';' unless length is counter
              chunk += '\n' if length is counter
              delete user[k]
              counter++
            that.push chunk
        user.email = email
        user[key] = data.value
      .on 'error', (err) ->
        console.log err.message
      .on 'end', ->
        that.source.close()
        counter = 1
        length = Object.keys(user).length
        chunk = ""
        for k, v of user
          chunk += v
          chunk += ';' unless length is counter
          chunk += '\n' if length is counter
          counter++
        that.push chunk
        return that.push null

    module.exports = exportStream
