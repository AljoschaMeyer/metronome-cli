{EventEmitter} = require 'events'

module.exports = () ->
  eventEmitter = new EventEmitter
  intervalObject = null
  start = ->
    changed = metronome.mode isnt 'running'
    metronome.mode = 'running'
    if changed
      eventEmitter.emit 'started'
      intervalObject = setInterval onTick, ((60 / metronome.bpm) * 1000), metronome.bpm
  stop = ->
    changed = metronome.mode isnt 'idle'
    metronome.mode = 'idle'
    clearInterval intervalObject
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

  onTick = (expectedBPM) ->
    eventEmitter.emit 'tick'
    if expectedBPM isnt metronome.bpm
      clearInterval intervalObject

      intervalObject = setInterval onTick, ((60 / metronome.bpm) * 1000), metronome.bpm      

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
