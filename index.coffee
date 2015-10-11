vorpal = (require 'vorpal')()
vorpalLog = require 'vorpal-log'
chalk = require 'chalk'

metronome =
  mode: 'idle'
  bpm: 120
  silent: false
  start: () ->
    metronome.mode = 'running'
    vorpal.updateDelimiter()
    logger.confirm 'started metronome'
  stop: () ->
    metronome.mode = 'idle'
    vorpal.updateDelimiter()
    logger.confirm 'stopped metronome'
  mute: () ->
    metronome.silent = true
    vorpal.updateDelimiter()
    logger.confirm 'muted sound'
  unmute: () ->
    metronome.silent = false
    vorpal.updateDelimiter()
    logger.confirm 'unmuted sound'
  setBPM: (bpm) ->
    metronome.bpm = bpm
    vorpal.updateDelimiter()
    logger.confirm "set bpm to #{bpm}"

vorpal.updateDelimiter = ->
  muteInfo = ''
  muteInfo = chalk.bold.red ' M' if metronome.silent

  modeInfo = ''
  modeInfo = ' tap' if metronome.mode is 'tap'

  delText = "[#{metronome.bpm}#{muteInfo}#{modeInfo}]:"
  delText = chalk.dim delText if metronome.silent

  return @delimiter delText

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

vorpal.command 'unmute'
  .description 'unmute the sound'
  .action (args, cb) ->
    metronome.unmute()
    cb()

vorpal.command 'mute'
  .description 'mute the sound'
  .action (args, cb) ->
    metronome.mute()
    cb()

vorpal.command 'bpm <bpm>'
  .description 'set the current bpm'
  .action (args, cb) ->
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
