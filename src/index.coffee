vorpal = (require 'vorpal')()
vorpalLog = require 'vorpal-log'
vorpalSOP = require 'vorpal-setorprint'
chalk = require 'chalk'
onetwoeight = require 'onetwoeight'
parse = require 'note-parser'

sound = require './sound'

settings =
  tapwindow: 20
  taptolerance: 0.5

bpm = new onetwoeight settings.tapwindow, settings.taptolerance

expectInt = (arg) ->
  int = parseInt arg
  if int? and int > 0
    return int
  else
    return null

expectFloat = (arg) ->
  flt = parseFloat arg
  if arg? and (not isNaN flt) and (flt isnt 0)
    return flt
  else
    return null

expectFrequency = (arg) ->
  int = parseInt arg
  if int? and int > 0
    return int
  else
    try
      note = parse arg
      return note.freq
    catch e
      return null

delimiterString = () ->
  tempoInfo = "#{Math.round sound.bpm}"
  while tempoInfo.length < 3
    tempoInfo = " #{tempoInfo}"
  return "[bpm: #{tempoInfo}]:"

startMetronome = () ->
  if sound.runningMetro
    logger.error 'already playing metronome'
  else
    if sound.runningSine
      logger.warn 'stopping tone'
      sound.stopSine()
    sound.startMetro()
    logger.confirm 'started metronome'

stopMetronome = () ->
  if sound.runningMetro
    sound.stopMetro()
    logger.confirm 'stopped metronome'

startTone = () ->
  if sound.runningSine
    logger.error 'already playing tone'
  else
    if sound.runningMetro
      logger.warn 'stopping metronome'
      sound.stopMetro()
    sound.startSine()
    logger.confirm 'started tone'

stopTone = () ->
  if sound.runningSine
    sound.stopSine()
    logger.confirm 'stopped tone'

setBPM = (bpm, forceConfirmation = false) ->
  if bpm > 500
    bpm = 500
    logger.warn 'can not set bpm higher than 500'
  if bpm < 1
    bpm = 1
    logger.warn 'can not set bpm lower than 1'
  changed = bpm isnt sound.bpm
  sound.bpm = bpm
  if changed or forceConfirmation
    vorpal.delimiter delimiterString()
    logger.confirm "set bpm to #{bpm}"

vorpal.use vorpalLog
  .use vorpalSOP
  .delimiter delimiterString()
  .show()

logger = vorpal.logger
sop = vorpal.sop

vorpal.command 'start'
  .description 'start the metronome'
  .alias 'play'
  .action (args, cb) ->
    metronome.startMetronome()
    cb()

vorpal.command 'stop'
  .description 'stops the metronome'
  .alias 'end'
  .action (args, cb) ->
    metronome.stopMetronome()
    cb()

vorpal.command 'tone [frequency] [seconds]'
  .description 'play the current or given frequency'
  .action (args, cb) ->
    if sound.runningSine
      logger.error 'already playing tone'
      cb()
    else
      f = sound.freq
      oldFreq = f
      f = args.frequency if args.frequency?
      dur = 2
      dur = args.seconds if args.seconds? and (typeof args.seconds) is 'number'

      frequ = expectFrequency f
      unless frequ is null
        sound.freq = frequ
        startTone()

        setTimeout (frequency) ->
          stopTone()
          sound.freq = frequency
        , dur * 1000, oldFreq
      cb()

sop.command 'meter', sound, {validate: expectInt}
  .hidden()
sop.command 'freq', sound, {validate: expectFrequency}
  .description 'set or print frequency, accepts integers or note names, e.g. g#5'
sop.command 'length', sound, {validate: expectFloat}
sop.command 'bpm', sound, {
  validate: expectInt
  passedValidation: (key, arg, value) ->
    setBPM value, true
}

vorpal.command 'add <bpm>'
  .description 'add to the current bpm'
  .action (args, cb) ->
    b = expectInt args.bpm
    metronome.setBPM sound.bpm + b unless b is null
    cb()

vorpal.command 'mul <factor>'
  .description 'multiply the current bpm with the factor'
  .alias 'multiply'
  .action (args, cb) ->
    f = expectFloat args.factor
    metronome.setBPM Math.round sound.bpm * f unless f is null
    cb()

sop.command 'tapwindow', settings, {
  validate: expectInt
  passedValidation: (key, arg, value) ->
    logger.confirm "set tapwindow to #{arg}"
    bpm = new onetwoeight settings.tapwindow, settings.taptolerance
}
  .description 'set or print how many of the last taps are used when tapping a tempo'

sop.command 'taptolerance', settings, {
  validate: expectFloat
  passedValidation: (key, arg, value) ->
    logger.confirm "set taptolerance to #{arg}"
    bpm = new onetwoeight settings.tapwindow, settings.taptolerance
}
  .description 'set or print tolerance when tapping a tempo'

vorpal.catch '[input...]'
  .action (args, cb) ->
    if args.input? and args.input.length = 1
      b = expectInt args.input[0]
      setBPM b unless b is null
      return cb()
    vorpal.exec 'help'
    cb()

vorpal.on 'keypress', (data) ->
  if data?
    if data.e.key.ctrl and data.e.key.name is 'p'
      if sound.runningMetro
        stopMetronome()
      else
        startMetronome()
    else if data.e.key.ctrl and data.e.key.name is 'left'
      setBPM(sound.bpm - 1)
      vorpal.ui.delimiter delimiterString()
    else if data.e.key.ctrl and data.e.key.name is 'right'
      setBPM(sound.bpm + 1)
      vorpal.ui.delimiter delimiterString()
    else if data.e.key.meta and data.e.key.name is 'left'
      setBPM(sound.bpm - 4)
      vorpal.ui.delimiter delimiterString()
    else if data.e.key.meta and data.e.key.name is 'right'
      setBPM(sound.bpm + 4)
      vorpal.ui.delimiter delimiterString()
    else if data.e.key.ctrl and data.e.key.name is '`'
      bpm.tap()
      newbpm = bpm.bpm()
      if newbpm?
        setBPM newbpm
        vorpal.ui.delimiter delimiterString()

logger.info chalk.bold.magenta 'Welcome to metronome-cli'
logger.info "run #{chalk.yellow 'help'} for a overview of the available commands"
logger.info "tap #{chalk.yellow 'space'} while holding #{chalk.yellow 'ctrl'} to set bpm"
logger.info "protip: #{chalk.yellow 'ctrl + p'} toggles playing"
logger.info "protip#2: use #{chalk.yellow '<ctrl | alt> + <arrow_left | arrow_right>'} to add or subtract from the current bpm"
logger.info 'protip#3: just enter any number to set bpm without needing a command'

# for testability
module.exports = metronome =
  startMetronome: startMetronome
  stopMetronome: stopMetronome
  startTone: startTone
  stopTone: stopTone
  setBPM: setBPM
  expectInt: expectInt
  expectFloat: expectFloat
  expectFrequency: expectFrequency
  vorpal: vorpal
