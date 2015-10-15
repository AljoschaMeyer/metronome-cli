sound = require '../src/sound'

describe 'The start and stop functions', ->
  beforeEach ->
    sound.runningSine = false
    sound.runningMetro = false

  afterEach ->
    sound.runningSine = false
    sound.runningMetro = false

  it 'correctly set controls.runningSine and controls.runningMetro', ->
    expect(sound.runningSine).toBe false
    expect(sound.runningMetro).toBe false

    sound.startSine()
    expect(sound.runningSine).toBe true
    expect(sound.runningMetro).toBe false

    sound.stopSine()
    expect(sound.runningSine).toBe false
    expect(sound.runningMetro).toBe false

    sound.startMetro()
    expect(sound.runningMetro).toBe true
    expect(sound.runningSine).toBe false

    sound.stopMetro()
    expect(sound.runningMetro).toBe false
    expect(sound.runningSine).toBe false
