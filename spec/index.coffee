metronome = require '../src/index'
sound = require '../src/sound'
parse = require 'note-parser'

describe 'The startMetronome function', ->
  beforeEach ->
    metronome.stopTone()
    metronome.stopMetronome()

  it 'calls sound.startMetro if it wasn\'t playing already', ->
    spyOn sound, 'startMetro'
    expect(sound.runningMetro).toBe false
    metronome.startMetronome()
    expect(sound.startMetro).toHaveBeenCalled()

  it 'does not call sound.startMetro if it was already playing', ->
    expect(sound.runningMetro).toBe false
    metronome.startMetronome()
    expect(sound.runningMetro).toBe true
    spyOn sound, 'startMetro'
    metronome.startMetronome()
    expect(sound.startMetro).not.toHaveBeenCalled()

  it 'calls sound.stopSine and sound.startMetro if a sine tone was playing', ->
    expect(sound.runningMetro).toBe false
    expect(sound.runningSine).toBe false
    metronome.startTone()
    expect(sound.runningSine).toBe true
    spyOn sound, 'stopSine'
    spyOn sound, 'startMetro'
    metronome.startMetronome()
    expect(sound.stopSine).toHaveBeenCalled()
    expect(sound.startMetro).toHaveBeenCalled()

describe 'The stopMetronome function', ->
  beforeEach ->
    metronome.stopTone()
    metronome.stopMetronome()

  it 'calls sound.stopMetro only if sound.runningMetro', ->
    expect(sound.runningMetro).toBe false
    spyOn sound, 'stopMetro'
    metronome.stopMetronome()
    expect(sound.stopMetro).not.toHaveBeenCalled()
    sound.runningMetro = true
    metronome.stopMetronome()
    expect(sound.stopMetro).toHaveBeenCalled()

describe 'The startTone function', ->
  beforeEach ->
    metronome.stopTone()
    metronome.stopMetronome()

  it 'calls sound.startSine if it wasn\'t playing already', ->
    spyOn sound, 'startSine'
    expect(sound.runningSine).toBe false
    metronome.startTone()
    expect(sound.startSine).toHaveBeenCalled()

  it 'does not call sound.startSine if it was already playing', ->
    expect(sound.runningSine).toBe false
    metronome.startTone()
    expect(sound.runningSine).toBe true
    spyOn sound, 'startSine'
    metronome.startTone()
    expect(sound.startSine).not.toHaveBeenCalled()

  it 'calls sound.stopMetro and sound.startSine if the metronome was playing', ->
    expect(sound.runningMetro).toBe false
    expect(sound.runningSine).toBe false
    metronome.startMetronome()
    expect(sound.runningMetro).toBe true
    spyOn sound, 'stopMetro'
    spyOn sound, 'startSine'
    metronome.startTone()
    expect(sound.stopMetro).toHaveBeenCalled()
    expect(sound.startSine).toHaveBeenCalled()

describe 'The stopTone function', ->
  beforeEach ->
    metronome.stopTone()
    metronome.stopMetronome()

  it 'calls sound.stopSine only if sound.runningSine', ->
    expect(sound.runningSine).toBe false
    spyOn sound, 'stopSine'
    metronome.stopTone()
    expect(sound.stopSine).not.toHaveBeenCalled()
    sound.runningSine = true
    metronome.stopTone()
    expect(sound.stopSine).toHaveBeenCalled()

describe 'The setBPM function', ->
  beforeEach ->
    sound.bpm = 120

  it 'sets sound.bpm', ->
    metronome.setBPM 121
    expect(sound.bpm).toBe 121

  it 'allows a maximum bpm of 500', ->
    metronome.setBPM 99999
    expect(sound.bpm).toBe 500

  it 'allows a minimum bpm of 1', ->
    metronome.setBPM 0
    expect(sound.bpm).toBe 1
    metronome.setBPM -2348
    expect(sound.bpm).toBe 1

describe 'The expectInt function', ->
  it 'does not accept strings', ->
    expect(metronome.expectInt 'foo').toBeNull()

  it 'does not accept negative integers', ->
    expect(metronome.expectInt -1).toBeNull()

  it 'does not accept zero', ->
    expect(metronome.expectInt 0).toBeNull()

  it 'accepts integers', ->
    expect(metronome.expectInt 5).toBe 5

  it 'accepts numbers and rounds them down', ->
    expect(metronome.expectInt 7.49).toBe 7
    expect(metronome.expectInt 7.99).toBe 7

  it 'parses numeric strings', ->
    expect(metronome.expectInt '6').toBe 6

describe 'The expectFloat function', ->
  it 'does not accept strings', ->
    expect(metronome.expectFloat 'foo').toBeNull()

  it 'does not accept zero', ->
    expect(metronome.expectFloat 0).toBeNull()

  it 'accepts numbers', ->
    expect(metronome.expectFloat 7.49).toBe 7.49
    expect(metronome.expectFloat 7.99).toBe 7.99

  it 'accepts negative numbers', ->
    expect(metronome.expectFloat -4.67).toBe -4.67

  it 'parses numeric strings', ->
    expect(metronome.expectFloat '-2.7').toBe -2.7

describe 'The expectFrequency function', ->
  it 'does not accept negative integers', ->
    expect(metronome.expectFrequency -1).toBeNull()

  it 'does not accept zero', ->
    expect(metronome.expectFrequency 0).toBeNull()

  it 'accepts integers', ->
    expect(metronome.expectFrequency 5).toBe 5

  it 'accepts numbers and rounds them down', ->
    expect(metronome.expectFrequency 7.49).toBe 7
    expect(metronome.expectFrequency 7.99).toBe 7

  it 'parses numeric strings', ->
    expect(metronome.expectFrequency '6').toBe 6

  it 'does not accept non-note strings', ->
    expect(metronome.expectFrequency 'foo').toBeNull()

  it 'returns the frequency for note strings', ->
    expect(metronome.expectFrequency 'a').toBe parse('a').freq
    expect(metronome.expectFrequency 'b#--').toBe parse('b#--').freq
    expect(metronome.expectFrequency 'ab2').toBe parse('ab2').freq

describe 'The start command', ->
  it 'runs startMetronome()', ->
    spyOn metronome, 'startMetronome'
    metronome.vorpal.exec 'start', (err, data) ->
      expect(metronome.startMetronome.calls.length).toBe 1

describe 'The stop command', ->
  it 'runs stopMetronome()', ->
    spyOn metronome, 'stopMetronome'
    metronome.vorpal.exec 'stop', (err, data) ->
      expect(metronome.stopMetronome.calls.length).toBe 1

describe 'The add command', ->
  it 'adds to the bpm', ->
    oldBPM = sound.bpm
    spyOn metronome, 'setBPM'
    metronome.vorpal.exec 'add 5', (err, data) ->
      expect(metronome.setBPM.mostRecentCall.args[0]).toBe(oldBPM + 5)

describe 'The mul command', ->
  it 'multiplies the bpm', ->
    metronome.setBPM 120
    oldBPM = sound.bpm
    console.log oldBPM
    spyOn metronome, 'setBPM'
    metronome.vorpal.exec 'mul 1.1', (err, data) ->
      expect(metronome.setBPM.mostRecentCall.args[0]).toBe(oldBPM * 1.1)
