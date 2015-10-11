# based on https://github.com/TooTallNate/node-speaker/blob/master/examples/sine.js

module.exports = (freq, duration) ->

  # the Readable "_read()" callback function
  read = (n) ->
    sampleSize = @bitDepth / 8
    blockAlign = sampleSize * @channels
    numSamples = n / blockAlign | 0
    buf = new Buffer(numSamples * blockAlign)
    amplitude = 32760 # Max amplitude for 16-bit audio

    # the "angle" used in the function, adjusted for the number of
    # channels and sample rate. This value is like the period of the wave.
    t = (Math.PI * 2 * freq) / @sampleRate
    i = 0

    while i < numSamples

      # fill with a simple sine wave at max amplitude
      channel = 0

      while channel < @channels
        s = @samplesGenerated + i
        val = Math.round(amplitude * Math.sin(t * s)) # sine wave
        offset = (i * sampleSize * @channels) + (channel * sampleSize)
        buf["writeInt" + @bitDepth + "LE"] val, offset
        channel++
      i++
    @push buf
    @samplesGenerated += numSamples

    # after generating "duration" second of audio, emit "end"
    @push null  if @samplesGenerated >= @sampleRate * duration

  Readable = require("stream").Readable
  Speaker = require("speaker")

  #freq = parseFloat(process.argv[2], 10) or 440.0
  #duration = parseFloat(process.argv[3], 10) or 2.0

  sine = new Readable()
  sine.bitDepth = 16
  sine.channels = 2
  sine.sampleRate = 44100
  sine.samplesGenerated = 0
  sine._read = read
  sine.pipe new Speaker()
