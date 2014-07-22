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
      connectApp.use livereload port: 35729
      connectApp.use serveStatic(dir)
      connectApp.use serveIndex dir,
        hidden: true
        icons: true
        view: 'details'

      server = connectApp
        .listen(port)
        .on 'listening', ->
          logger.info "#{params.name} server started on #{port}"
          shell.settings.servers ?= {}
          shell.settings.servers[params.name] = new AppServer
            name: params.name
            server: @
            port: port
          deferred.resolve(@)

    shell.once 'quit', ->
      _.each shell.settings.servers, (server) ->
        server.close()

    deferred.promise
