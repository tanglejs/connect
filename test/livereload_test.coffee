path = require 'path'
Outbreak = require 'outbreak'

describe 'Livereload server', ->
  @timeout 6000
  before ->
    @client = new Outbreak.Client
      name: 'livereload'
      command: path.resolve(__dirname, '..', 'lib', 'servers', 'livereload.coffee')
      args: []
      cwd: path.join(__dirname, 'fixtures')

  describe 'when connected', ->
    before (done) ->
      @client.connect (err, client, events) =>
        client.end()
        done()

    it 'should be running', ->
      @client.isRunning().should.be.true

    describe 'the web root', ->
      it 'should be queryable', (done) ->
        @client.connect (err, client, events) =>
          client.on 'remote', (remote) ->
            remote.call 'getRoot', (root) ->
              root.should.have.string 'build/app'
              done()

    describe 'the listening port', ->
      it 'should be queryable', (done) ->
        @client.connect (err, client, events) =>
          client.on 'remote', (remote) ->
            remote.call 'getPort', (port) ->
              port.should.be.above 1024
              done()

  after (done) -> @client.kill -> done()
