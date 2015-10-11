{EventEmitter} = require 'events'

module.exports = () ->
  eventEmitter = new EventEmitter
  intervalObject = null
  start = ->
    changed = metronome.mode isnt 'running'
    metronome.mode = 'running'
    #clearInterval metronome.intervalObject if metronome.intervalObject?
    #metronome.intervalObject = setInterval onMetronomeTick, ((60 / metronome.bpm) * 1000), metronome.bpm
    eventEmitter.emit 'started' if changed
  stop = ->
    changed = metronome.mode isnt 'idle'
    metronome.mode = 'idle'
    eventEmitter.emit 'stopped' if changed
  mute = ->
    changed = not metronome.silent
    metronome.silent = true
    eventEmitter.emit 'muted' if changed
  unmute = ->
    changed = metronome.silent
    metronome.silent = false
    eventEmitter.emit 'unmuted' if changed
  setBPM = (bpm) ->
    changed = metronome.bpm isnt bpm
    metronome.bpm = bpm
    eventEmitter.emit 'bpm', bpm if changed

  return metronome =
    eventEmitter: eventEmitter
    mode: 'idle'
    bpm: 120
    silent: false
    start: start
    stop: stop
    mute: mute
    unmute: unmute
    setBPM: setBPM
