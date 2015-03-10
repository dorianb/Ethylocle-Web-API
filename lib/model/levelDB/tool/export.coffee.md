# Export

    stream = require 'stream'
    util = require 'util'

    ExportStream = (format = 'csv', options) ->
      return new ExportStream format, options unless this instanceof ExportStream
      this.format = format
      stream.Transform.call this, options
      this.data = {}
      this.iterator = 0

    util.inherits ExportStream, stream.Transform

    ExportStream.prototype._transform = (data, encoding, done) ->
      [_, id, key] = data.key.split ':'
      if this.data.id
        unless this.data.id is id
          chunk = ""
          length = Object.keys(this.data).length
          if this.iterator is 0
            counter = 1
            for k, v of this.data
              chunk += k
              chunk += ';' unless length is counter
              chunk += '\n' if length is counter
              counter++
            this.iterator++
          counter = 1
          for k, v of this.data
            chunk += '"' + v + '"'
            chunk += ';' unless length is counter
            chunk += '\n' if length is counter
            delete this.data[k]
            counter++
          this.iterator++
          #console.log chunk
          this.push chunk
      this.data.id = id
      this.data[key] = data.value
      done()

    ExportStream.prototype._flush = (done) ->
      chunk = ""
      counter = 1
      length = Object.keys(this.data).length
      for k, v of this.data
       chunk += '"' + v + '"'
       chunk += ';' unless length is counter
       chunk += '\n' if length is counter
       delete this.data[k]
       counter++
      this.iterator++
      #console.log chunk
      this.push chunk
      done()

    module.exports = ExportStream
