vorpal = (require 'vorpal')()
vorpalLog = require 'vorpal-log'
chalk = require 'chalk'
onetwoeight = require 'onetwoeight'

metronome = (require './metronome')()
sound = require './sound'

avg = 20
tol = 0.5
bpm = new onetwoeight avg, tol

vorpal.updateDelimiter = ->
  tempoInfo = "#{Math.round metronome.bpm}"
  while tempoInfo.length < 3
    tempoInfo = " #{tempoInfo}"
  delText = "[bpm: #{tempoInfo}]:"

  return @delimiter delText

metronome.eventEmitter.on 'started', ->
  vorpal.updateDelimiter()
  logger.confirm 'started metronome'

metronome.eventEmitter.on 'stopped', ->
  vorpal.updateDelimiter()
  logger.confirm 'stopped metronome'

metronome.eventEmitter.on 'bpm', (bpm) ->
  vorpal.updateDelimiter()
  logger.confirm "changed bpm to #{bpm}"

freq = 440

metronome.eventEmitter.on 'tick', ->
  sound freq, 0.05

metronome.eventEmitter.on 'tock', ->
  sound freq / 2, 0.05

vorpal.use vorpalLog, {markdown: true}
  .updateDelimiter()
  .show()

logger = vorpal.logger

vorpal.command 'start'
  .description 'start the metronome'
  .alias 'play'
  .action (args, cb) ->
    metronome.start()
    cb()

vorpal.command 'stop'
  .description 'stops the metronome'
  .alias 'end'
  .action (args, cb) ->
    metronome.stop()
    cb()

vorpal.command 'freq [frequency]'
  .description 'set the pitch'
  .alias 'frequency'
  .action (args, cb) ->
    unless args.frequency?
      logger.info "frequency: #{freq}"
      return cb()
    freq = args.frequency
    cb()

vorpal.command 'tone [frequency] [seconds]'
  .description 'play the current or given frequency'
  .action (args, cb) ->
    metronome.stop()
    f = freq
    f = args.frequency if args.frequency?
    dur = 2
    dur = args.seconds if args.seconds?

    sound f, dur
    cb()

vorpal.command 'meter [meter]'
  .description 'set the current meter'
  .action (args, cb) ->
    unless args.meter?
      logger.info "meter: #{metronome.meter}"
      return cb()
    metronome.setMeter args.meter
    cb()

vorpal.command 'bpm [bpm]'
  .description 'set the current bpm'
  .action (args, cb) ->
    unless args.bpm?
      loggerole.info "bpm: #{metronome.bpm}"
      return cb()
    metronome.setBPM args.bpm
    cb()

vorpal.command 'add <bpm>'
  .description 'add to the current bpm'
  .action (args, cb) ->
    metronome.setBPM(metronome.bpm + args.bpm)
    cb()

vorpal.command 'mul <factor>'
  .description 'multiply the current bpm with the factor'
  .alias 'multiply'
  .action (args, cb) ->
    metronome.setBPM(metronome.bpm * args.factor)
    cb()

vorpal.command 'tapwindow [window]'
  .description 'how many of the last tabs are used when tapping a tempo'
  .action (args, cb) ->
    unless args.window?
      logger.info "window: #{avg}"
      return cb()
    avg = args.window
    bpm = new onetwoeight avg, tol
    cb()

vorpal.command 'taptolerance [tolerance]'
  .description 'tolerance when tapping a tempo'
  .action (args, cb) ->
    unless args.tolerance?
      logger.info "tolerance: #{tol}"
      return cb()
    tol = args.tolerance
    bpm = new onetwoeight avg, tol
    cb()

vorpal.catch '[input...]'
  .action (args, cb) ->
    if args.input? and args.input.length = 1
      bpm = parseInt args.input[0]
      if bpm > 0
        metronome.setBPM bpm
        return cb()

    vorpal.exec 'help'
    cb()

vorpal.on 'keypress', (data) ->
  if data?
    logger.debug data
    if data.e.key.ctrl and data.e.key.name is 'p'
      if metronome.mode is 'idle'
        metronome.start()
      else if metronome.mode is 'running'
        metronome.stop()
    else if data.e.key.ctrl and data.e.key.name is 'left'
      metronome.setBPM(metronome.bpm - 1)
    else if data.e.key.ctrl and data.e.key.name is 'right'
      metronome.setBPM(metronome.bpm + 1)
    else if data.e.key.meta and data.e.key.name is 'left'
      metronome.setBPM(metronome.bpm - 4)
    else if data.e.key.meta and data.e.key.name is 'right'
      metronome.setBPM(metronome.bpm + 4)
    else if data.e.key.ctrl and data.e.key.name is '`'
      bpm.tap()
      newbpm = bpm.bpm()
      metronome.setBPM newbpm if newbpm?

logger.info '# Welcome to metronome-cli'
logger.info 'run `help` for a overview of the available commands'
logger.info 'protip: `ctrl + p` toggles playing'
logger.info 'protip#2: use `<ctrl | alt> + <arrow_left | arrow_right>` to add or subtract from the current bpm'
logger.info 'protip#3: just enter any number to set bpm without needing a command'
