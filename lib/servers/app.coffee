#!/usr/bin/env coffee

HOST = '0.0.0.0'
MIN_PORT = 3000
MAX_PORT = 3010

path = require 'path'
connect = require 'connect'
livereload = require 'connect-livereload'
portscanner = require 'portscanner'
serveStatic = require 'serve-static'
serveIndex = require 'serve-index'
Outbreak = require 'outbreak'

module.exports = class AppServer
  constructor: (options={}) ->
    @root = options.root || path.join process.cwd(), 'build', 'app'
    @port = options.port || @findPort()
    @server = new Outbreak.Server
      name: 'app'
      remoteMethods:
        getPort: (cb) => cb @port
        getRoot: (cb) => cb @root
        findLivereload: (cb) => @findLivereload(cb)
    @server.connect()

  start: ->
    @findLivereload (port) =>
      @livereloadPort = port
      @app = @listen()

  findPort: ->
    portscanner.findAPortNotInUse MIN_PORT, MAX_PORT, HOST, (error, port) =>
      throw new Error error if error
      @port = port

  init: ->
    app = connect()
    if @livereloadPort
      app.use livereload
        port: @livereloadPort
    app.use serveStatic @root
    app.use serveIndex @root,
      hidden: true
      icons: true
      view: 'details'
    app

  listen: ->
    @init()
      .listen(@port)
      .on 'listening', =>
        @server.publish 'listening',
          port: @port

  findLivereload: (cb) ->
    client = new Outbreak.Client
      name: 'livereload'
      command: path.resolve(__dirname, 'livereload.coffee')
      args: []
      cwd: process.cwd()
    client.connect (err, client, events) =>
      if err
        cb null
      else
        client.on 'remote', (remote) ->
          remote.call 'getPort', (port) ->
            cb port

if !module.parent
  appServer = new AppServer
  appServer.start()
