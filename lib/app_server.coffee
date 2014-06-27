_ = require 'lodash'

module.exports = class AppServer

  constructor: (options) ->
    @name = options.name
    @server = options.server
    @port = options.port

    @sockets = []

    @server.on 'connection', (socket) =>
      @sockets.push socket
      socket.on 'close', =>
        @sockets.splice @sockets.indexOf(socket), 1

  close: (callback) ->
    _.each @sockets, (socket) -> socket.destroy()
    @server.close callback
