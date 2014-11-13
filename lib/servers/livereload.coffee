#!/usr/bin/env coffee

HOST = '0.0.0.0'
MIN_PORT = 35729
MAX_PORT = 35739

path = require 'path'
portscanner = require 'portscanner'
express = require 'express'
tinylr = require 'tiny-lr'
body = require 'body-parser'
Outbreak = require 'outbreak'

module.exports = class LivereloadServer
  constructor: (options={}) ->
    @root = options.root || path.join process.cwd(), 'build', 'app'
    @port = options.port || @findPort()
    @server = new Outbreak.Server
      name: 'livereload'
      remoteMethods:
        getPort: (cb) => cb @port
        getRoot: (cb) => cb @root
    @server.connect()

  start: ->
    @app = @listen()

  findPort: ->
    portscanner.findAPortNotInUse MIN_PORT, MAX_PORT, HOST, (error, port) =>
      throw new Error error if error
      @port = port

  init: ->
    lr = express()
    lr
      .use body()
      .use tinylr.middleware app: lr
      .use express.static(@root)
    lr

  listen: ->
    @init()
      .listen @port, =>
        @server.publish 'listening',
          port: @port

if !module.parent
  livereloadServer = new LivereloadServer
  livereloadServer.start()
