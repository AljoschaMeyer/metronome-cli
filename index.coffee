vorpal = (require 'vorpal')()
vorpalLog = require 'vorpal-log'
chalk = require 'chalk'
onetwoeight = require 'onetwoeight'

sound = require './sound'

avg = 20
tol = 0.5
bpm = new onetwoeight avg, tol
globalFrequency = 440

# execute cb if arg can be parsed as nonzero, positive integer, else log
expectInt = (arg, cb) ->
  int = parseInt arg
  if int? and int > 0
    cb int
  else
    logger.warn "invalid argument, expected #{arg} to be a nonzero, positive integer"

expectFloat = (arg, cb) ->
  flt = parseFloat arg
  if arg? and (not isNaN flt) and (flt isnt 0)
    cb flt
  else
    logger.warn "invalid argument, expected #{arg} to be a nonzero float"

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

setBPM = (bpm) ->
  bpm = 440 if bpm > 440
  changed = bpm isnt sound.bpm
  sound.bpm = bpm
  if changed
    vorpal.delimiter delimiterString()
    logger.confirm "set bpm to #{bpm}"

vorpal.use vorpalLog, {markdown: true}
  .delimiter delimiterString()
  .show()

logger = vorpal.logger

vorpal.command 'start'
  .description 'start the metronome'
  .alias 'play'
  .action (args, cb) ->
    startMetronome()
    cb()

vorpal.command 'stop'
  .description 'stops the metronome'
  .alias 'end'
  .action (args, cb) ->
    stopMetronome()
    cb()

vorpal.command 'freq [frequency]'
  .description 'set the pitch'
  .alias 'frequency'
  .action (args, cb) ->
    unless args.frequency?
      logger.info "frequency: #{globalFrequency}"
      return cb()
    expectInt args.frequency, (f) ->
      globalFrequency = f
      sound.freq = f
      logger.confirm "set frequency to #{f}"
    cb()

vorpal.command 'length [seconds]'
  .description 'set the length of the metronome ticks'
  .action (args, cb) ->
    unless args.seconds?
      logger.info "length: #{sound.length}"
      return cb()
    expectFloat args.seconds, (l) ->
      sound.length = l
      logger.confirm "set length to #{l}"
    cb()

vorpal.command 'tone [frequency] [seconds]'
  .description 'play the current or given frequency'
  .action (args, cb) ->
    if sound.runningSine
      logger.error 'already playing tone'
      cb()
    else
      f = globalFrequency
      f = args.frequency if args.frequency?
      dur = 2
      dur = args.seconds if args.seconds? and (typeof args.seconds) is 'number'

      expectInt f, (frequ) ->
        sound.freq = frequ
        startTone()

        setTimeout (frequency) ->
          stopTone()
          sound.freq = frequency
        , dur * 1000, globalFrequency
      cb()

vorpal.command 'bpm [bpm]'
  .description 'set the current bpm'
  .action (args, cb) ->
    unless args.bpm?
      logger.info "bpm: #{sound.bpm}"
      return cb()
    expectInt args.bpm, (b) ->
      setBPM b
    cb()

vorpal.command 'add <bpm>'
  .description 'add to the current bpm'
  .action (args, cb) ->
    expectInt args.bpm, (b) ->
      setBPM sound.bpm + b
    cb()

vorpal.command 'mul <factor>'
  .description 'multiply the current bpm with the factor'
  .alias 'multiply'
  .action (args, cb) ->
    expectFloat args.factor, (f) ->
      setBPM Math.round sound.bpm * f
    cb()

vorpal.command 'tapwindow [window]'
  .description 'how many of the last taps are used when tapping a tempo'
  .action (args, cb) ->
    unless args.window?
      logger.info "window: #{avg}"
      return cb()
    expectInt args.window, (w)->
      avg = w
      bpm = new onetwoeight avg, tol
      logger.confirm "set tapwindow to #{w}"
    cb()

vorpal.command 'taptolerance [tolerance]'
  .description 'tolerance when tapping a tempo'
  .action (args, cb) ->
    unless args.tolerance?
      logger.info "tolerance: #{tol}"
      return cb()
    expectFloat args.tolerance, (t) ->
      tol = t
      bpm = new onetwoeight avg, tol
      logger.confirm "set taptolerance to #{t}"
    cb()

vorpal.catch '[input...]'
  .action (args, cb) ->
    if args.input? and args.input.length = 1
      expectInt args.input[0], (b) ->
        setBPM b
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

logger.info '# Welcome to metronome-cli'
logger.info 'run `help` for a overview of the available commands'
logger.info 'tap `space` while holding `ctrl` to set bpm'
logger.info 'protip: `ctrl + p` toggles playing'
logger.info 'protip#2: use `<ctrl | alt> + <arrow_left | arrow_right>` to add or subtract from the current bpm'
logger.info 'protip#3: just enter any number to set bpm without needing a command'
