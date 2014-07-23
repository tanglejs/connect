path = require 'path'

start = require path.join(__dirname, 'lib', 'start')
stop = require path.join(__dirname, 'lib', 'stop')
running = require path.join(__dirname, 'lib', 'running')

livereload = require path.join(__dirname, 'lib', 'livereload')

module.exports =
  start: start
  stop: stop
  running: running
  startLivereload: livereload.start
  stopLivereload: livereload.stop

  commands:
    'start app':
      description: 'Start the local app server'
      action: start
      defaults:
        name: 'app'
    'stop app':
      description: 'Stop the local app server'
      action: stop
      defaults:
        name: 'app'
    'start livereload':
      description: 'Start the livereload server'
      action: livereload.start
      defaults:
        name: 'livereload'
    'stop livereload':
      description: 'Stop the livereload server'
      action: livereload.stop
      defaults:
        name: 'livereload'
    'running':
      description: 'Show list of running servers'
      action: running
