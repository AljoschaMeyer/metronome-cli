vorpal = (require 'vorpal')()
vorpalLog = require 'vorpal-log'
chalk = require 'chalk'

metronome = (require './metronome')()

vorpal.updateDelimiter = ->
  tempoInfo = "#{Math.round metronome.bpm}"
  while tempoInfo.length < 3
    tempoInfo = " #{tempoInfo}"

  muteInfo = ''
  muteInfo = chalk.bold.red ' M' if metronome.silent

  modeInfo = ''
  modeInfo = ' tap' if metronome.mode is 'tap'

  delText = "[#{tempoInfo}#{muteInfo}#{modeInfo}]:"
  delText = chalk.dim delText if metronome.silent

  return @delimiter delText

metronome.eventEmitter.on 'started', ->
  vorpal.updateDelimiter()
  logger.confirm 'started metronome'

metronome.eventEmitter.on 'stopped', ->
  vorpal.updateDelimiter()
  logger.confirm 'stopped metronome'

metronome.eventEmitter.on 'muted', ->
  vorpal.updateDelimiter()
  logger.confirm 'muted sound'

metronome.eventEmitter.on 'unmuted', ->
  vorpal.updateDelimiter()
  logger.confirm 'unmuted sound'

metronome.eventEmitter.on 'bpm', (bpm) ->
    vorpal.updateDelimiter()
    logger.confirm "changed bpm to #{bpm}"

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
    if data.e.key.ctrl and data.e.key.name is 's'
      if metronome.silent
        metronome.unmute()
      else
        metronome.mute()
    else if data.e.key.ctrl and data.e.key.name is 'p'
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

logger.info '# Welcome to metronome-cli'
logger.info 'run `help` for a overview of the available commands'
logger.info 'protip: `ctrl + p` toggles playing, `ctrl + s` toggles silent mode'
logger.info 'protip#2: use `<ctrl | alt> + <arrow_left | arrow_right>` to add or subtract from the current bpm'
logger.info 'protip#3: just enter any number to set bpm without needing a command'
