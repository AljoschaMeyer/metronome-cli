Generator = require 'audio-generator'
Speaker = require 'speaker'

speaker = new Speaker()
sine = Generator {
  generate: (time) ->
    return [Math.sin(Math.PI * 2 * time * controls.freq), Math.sin(Math.PI * 2 * time * controls.freq)]
  duration: Infinity,
  channels: 2,
  sampleRate: 44100,
  byteOrder: 'LE',
  bitDepth: 16,
  signed: true,
  float: false,
  samplesPerFrame: 64,
  interleaved: true
}
metro = Generator {
  generate: (time) ->
    return [0, 0] if (time % (60 / controls.bpm)) > controls.length
    if (time % (controls.meter / 2)) < 0.5
      return [Math.sin(Math.PI * 2 * time * controls.freq), Math.sin(Math.PI * 2 * time * controls.freq)]
    else
      return [Math.sin(Math.PI * 2 * time * controls.freq / 2), Math.sin(Math.PI * 2 * time * controls.freq / 2)]

  duration: Infinity,
  channels: 2,
  sampleRate: 44100,
  byteOrder: 'LE',
  bitDepth: 16,
  signed: true,
  float: false,
  samplesPerFrame: 64,
  interleaved: true
}

startMetro = () ->
  sine.unpipe()
  controls.runningSine = false
  controls.runningMetro = true
  metro.pipe speaker

stopMetro = () ->
 metro.unpipe()
 controls.runningMetro = false

startSine = () ->
  metro.unpipe()
  controls.runningMetro = false
  controls.runningSine = true
  sine.pipe speaker

stopSine = () ->
 sine.unpipe()
 controls.runningSine = false

module.exports = controls =
  startSine: startSine
  stopSine: stopSine
  startMetro: startMetro
  stopMetro: stopMetro
  runningSine: false
  runningMetro: false
  freq: 880
  bpm: 120
  length: 0.1
  meter: 1
