path = require 'path'
Q = require 'q'
connect = require 'connect'
serveStatic = require 'serve-static'
serveIndex = require 'serve-index'
_ = require 'lodash'
portscanner = require 'portscanner'
livereload = require 'connect-livereload'

AppServer = require path.join(__dirname, 'app_server')

module.exports = (params, shell) ->
  (config) ->

    logger = shell.settings.logger
    deferred = Q.defer()

    switch params.name
      when 'app'
        dir = path.join process.cwd(), 'build', 'app'

    hostname = '0.0.0.0'
    portscanner.findAPortNotInUse 3000, 3010, hostname, (error, port) ->
      throw new Error error if error

      connectApp = connect()

      if lr = shell.settings.servers?['livereload']
        logger.info "Using livereload server on port #{lr.port}."
        connectApp.use livereload port: lr.port

      connectApp.use serveStatic(dir)
      connectApp.use serveIndex dir,
        hidden: true
        icons: true
        view: 'details'

      server = connectApp
        .listen(port)
        .on 'listening', ->
          shell.settings.servers ?= {}
          shell.settings.servers[params.name] = new AppServer
            name: params.name
            server: @
            port: port
          deferred.resolve
            server_name: params.name
            port: port
            status: 'listening'


    shell.once 'quit', ->
      _.each shell.settings.servers, (server) ->
        server.close()

    deferred.promise
