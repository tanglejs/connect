path = require 'path'
Outbreak = require 'outbreak'

describe 'App server', ->
  @timeout 5000
  before ->
    @client = new Outbreak.Client
      name: 'app'
      command: path.resolve(__dirname, '..', 'lib', 'servers', 'app.coffee')
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

    describe 'when the livereload service is running', ->
      before (done) ->
        @livereloadClient = new Outbreak.Client
          name: 'livereload'
          command: path.resolve(__dirname, '..', 'lib', 'servers', 'livereload.coffee')
          args: []
          cwd: path.join(__dirname, 'fixtures')

        @livereloadClient.connect (err, client, events) =>
          client.end()
          done()

      it 'should be running', ->
        @livereloadClient.isRunning().should.be.true

      describe 'the livereload port', ->
        it 'should be null', (done) ->
          @client.connect (err, client, events) =>
            client.on 'remote', (remote) ->
              remote.call 'findLivereload', (port) ->
                port.should.be.above 1024
                done()

  describe 'when killed', ->
    before (done) -> @client.kill -> done()

    it 'should not be running', ->
      @client.isRunning().should.be.false

    it 'should unlink the pidfile',  ->
      @client.getPidfile().should.not.be.a.path()

    it 'should unlink the socket',  ->
      @client.getSocket().should.not.be.a.path()
