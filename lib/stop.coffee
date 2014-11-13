path = require 'path'
Q = require 'q'
Outbreak = require 'outbreak'

module.exports = (params, shell) ->
  (config) ->
    logger = shell.settings.logger

    logger.info "Stopping #{params.name} server..."

    @client = new Outbreak.Client
      name: params.name
      command: path.resolve(__dirname, 'servers', "#{params.name}.coffee")
      args: []
      cwd: process.cwd()

    Q.fcall =>
      @client.connect (err, client, events) =>
        client.on 'remote', (remote) =>
          @client.kill ->
            client.end()
