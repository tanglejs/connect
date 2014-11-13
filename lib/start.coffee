path = require 'path'
Q = require 'q'
Outbreak = require 'outbreak'

module.exports = (params, shell) ->
  (config) ->
    logger = shell.settings.logger
    deferred = Q.defer()

    logger.info "Starting #{params.name} server..."

    app = new Outbreak.Client
      name: 'app'
      command: path.resolve(__dirname, 'servers', 'app.coffee')
      args: []
      cwd: process.cwd()

    app.connect (err, client, events) =>
      throw new Error err if err

      client.on 'remote', (remote) ->
        remote.call 'getPort', (port) ->
          logger.info "Listening on port #{port}"
          client.end()

      deferred.resolve()
    deferred.promise
