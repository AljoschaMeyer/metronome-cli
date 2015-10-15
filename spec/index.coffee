metronome = require '../src/index'
sound = require '../src/sound'

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
