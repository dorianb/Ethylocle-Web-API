# Export

    stream = require 'stream'
    util = require 'util'

    exportStream = (source, format = format: 'csv', options) ->
      return new exportStream source, format, options unless this instanceof exportStream
      this.source = source
      this.format = format.format
      this._inBody = true
      stream.Readable.call this, options
      ###
      this._inBody = false
      this._sawFirstCr = false

      this._source = source

      self = this
      source.on 'end', () ->
        self.push null

      source.on 'readable', () ->
        self.users.

      this._rawHeader = []
      this.header = null
      ###

    util.inherits exportStream, stream.Readable
    exportStream.prototype._read = (n) ->

      unless this._inBody
        chunk = this.source.read()

        if chunk == null
          return this.push ''

        #check if the chunk has a \n\n
        ###split = -1;
        for (var i = 0; i < chunk.length; i++) {
          if (chunk[i] === 10) { // '\n'
            if (this._sawFirstCr) {
              split = i;
              break;
            } else {
              this._sawFirstCr = true;
            }
          } else {
            this._sawFirstCr = false;
          }
        }

        if (split === -1)
        {
          #still waiting for the \n\n
          #stash the chunk, and try again.
          this._rawHeader.push(chunk);
          this.push('');
        }
        else
        {
          this._inBody = true;
          var h = chunk.slice(0, split);
          this._rawHeader.push(h);
          var header = Buffer.concat(this._rawHeader).toString();
          try {
            this.header = JSON.parse(header);
          }
          catch (er) {
            this.emit('error', new Error('invalid simple protocol data'));
            return;
          }
          #now, because we got some extra data, unshift the rest
          #back into the read queue so that our consumer will see it.
          b = chunk.slice(split);
          this.unshift(b);

          // and let them know that we are done parsing the header.
          this.emit('header', this.header);
        }###
      else
        #from there on, just provide the data to our consumer.
        #careful not to push(null), since that would indicate EOF.
        #chunk = this._source.read()
        this.source.users.get "\x00", (err, users) ->
          console.log "Chunk: " + users.user
        console.log "Chunk: " + chunk

        if chunk
          this.push(chunk)

    module.exports = exportStream
