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
  setBPM = (bpm) ->
    bpm = 800 if bpm > 800
    changed = metronome.bpm isnt bpm
    metronome.bpm = bpm
    eventEmitter.emit 'bpm', bpm if changed
  setMeter = (meter) ->
    changed = metronome.meter isnt meter
    metronome.meter = meter
    eventEmitter.emit 'meter', meter if changed

  meterTrack = 0

  onTick = (expectedBPM) ->
    eventEmitter.emit if meterTrack is 0 then 'tick' else 'tock'

    meterTrack++
    meterTrack = 0 if meterTrack >= metronome.meter

    if expectedBPM isnt metronome.bpm
      clearInterval intervalObject

      intervalObject = setInterval onTick, ((60 / metronome.bpm) * 1000), metronome.bpm

  return metronome =
    eventEmitter: eventEmitter
    mode: 'idle'
    bpm: 120
    meter: 1
    start: start
    stop: stop
    setBPM: setBPM
    setMeter: setMeter
