Q = require 'q'

module.exports = (params, shell) ->
  (config) ->
    deferred = Q.defer()
    logger = shell.settings.logger
    server = shell.settings.servers?[params.name]
    if server
      server.close ->
        delete shell.settings.servers[params.name]
        logger.info "#{params.name} server killed"
        deferred.resolve server
    else
      deferred.reject new Error "No server running named #{params.name}"
    deferred.promise
