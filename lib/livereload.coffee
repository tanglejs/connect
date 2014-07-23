path = require 'path'
Q = require 'q'
_ = require 'lodash'
portscanner = require 'portscanner'
express = require 'express'
tinylr = require 'tiny-lr'
body = require 'body-parser'

AppServer = require path.join(__dirname, 'app_server')

module.exports =
  
  start: (params, shell) ->
    (config) ->
      logger = shell.settings.logger
      deferred = Q.defer()

      hostname = '0.0.0.0'
      portscanner.findAPortNotInUse 35729, 35739, hostname, (error, port) ->
        throw new Error error if error

        app = express()
        app
          .use body()
          .use tinylr.middleware app: app
          .use express.static(path.resolve('./'))
          .listen port, ->
            shell.settings.servers ?= {}
            shell.settings.servers[params.name] = new AppServer
              name: params.name
              server: @
              port: port
            deferred.resolve
              server_name: params.name
              port: port
              status: 'listening'

      deferred.promise

  stop: (params, shell) ->
    (config) ->
      deferred = Q.defer()
      logger = shell.settings.logger
      server = shell.settings.servers?['livereload']
      if server
        server.close ->
          delete shell.settings.servers['livereload']
          logger.info 'livereload server killed'
          deferred.resolve server
      else
        deferred.reject new Error 'No livereload server running'
      deferred.promise
