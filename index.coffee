path = require 'path'

start = require path.join(__dirname, 'lib', 'start')
stop = require path.join(__dirname, 'lib', 'stop')
#running = require path.join(__dirname, 'lib', 'running')

module.exports =
  start: start
  stop: stop
  #running: running

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
    'stop livereload':
      description: 'Stop the livereload server'
      action: stop
      defaults:
        name: 'livereload'
