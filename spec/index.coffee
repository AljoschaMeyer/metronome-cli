metronome = require '../src/index'

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
