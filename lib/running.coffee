Q = require 'q'
_ = require 'lodash'

module.exports = (params, shell) ->
  (config) ->
    logger = shell.settings.logger
    _.each shell.settings.servers, (server) ->
      logger.log 'info',
        name: server.name
        port: server.port
        sockets: server.sockets.length

    Q.fcall -> shell.settings.servers
