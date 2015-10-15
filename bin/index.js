#! /usr/bin/env node
(function() {
  var bpm, chalk, delimiterString, expectFloat, expectFrequency, expectInt, logger, metronome, onetwoeight, parse, setBPM, settings, sop, sound, startMetronome, startTone, stopMetronome, stopTone, vorpal, vorpalLog, vorpalSOP;

  vorpal = (require('vorpal'))();

  vorpalLog = require('vorpal-log');

  vorpalSOP = require('vorpal-setorprint');

  chalk = require('chalk');

  onetwoeight = require('onetwoeight');

  parse = require('note-parser');

  sound = require('./sound');

  settings = {
    tapwindow: 20,
    taptolerance: 0.5
  };

  bpm = new onetwoeight(settings.tapwindow, settings.taptolerance);

  expectInt = function(arg) {
    var int;
    int = parseInt(arg);
    if ((int != null) && int > 0) {
      return int;
    } else {
      return null;
    }
  };

  expectFloat = function(arg) {
    var flt;
    flt = parseFloat(arg);
    if ((arg != null) && (!isNaN(flt)) && (flt !== 0)) {
      return flt;
    } else {
      return null;
    }
  };

  expectFrequency = function(arg) {
    var e, error, int, note;
    int = parseInt(arg);
    if ((int != null) && int > 0) {
      return int;
    } else {
      try {
        note = parse(arg);
        return note.freq;
      } catch (error) {
        e = error;
        return null;
      }
    }
  };

  delimiterString = function() {
    var tempoInfo;
    tempoInfo = "" + (Math.round(sound.bpm));
    while (tempoInfo.length < 3) {
      tempoInfo = " " + tempoInfo;
    }
    return "[bpm: " + tempoInfo + "]:";
  };

  startMetronome = function() {
    if (sound.runningMetro) {
      return logger.error('already playing metronome');
    } else {
      if (sound.runningSine) {
        logger.warn('stopping tone');
        sound.stopSine();
      }
      sound.startMetro();
      return logger.confirm('started metronome');
    }
  };

  stopMetronome = function() {
    if (sound.runningMetro) {
      sound.stopMetro();
      return logger.confirm('stopped metronome');
    }
  };

  startTone = function() {
    if (sound.runningSine) {
      return logger.error('already playing tone');
    } else {
      if (sound.runningMetro) {
        logger.warn('stopping metronome');
        sound.stopMetro();
      }
      sound.startSine();
      return logger.confirm('started tone');
    }
  };

  stopTone = function() {
    if (sound.runningSine) {
      sound.stopSine();
      return logger.confirm('stopped tone');
    }
  };

  setBPM = function(bpm, forceConfirmation) {
    var changed;
    if (forceConfirmation == null) {
      forceConfirmation = false;
    }
    if (bpm > 500) {
      bpm = 500;
      logger.warn('can not set bpm higher than 500');
    }
    if (bpm < 1) {
      bpm = 1;
      logger.warn('can not set bpm lower than 1');
    }
    changed = bpm !== sound.bpm;
    sound.bpm = bpm;
    if (changed || forceConfirmation) {
      vorpal.delimiter(delimiterString());
      return logger.confirm("set bpm to " + bpm);
    }
  };

  vorpal.use(vorpalLog).use(vorpalSOP).delimiter(delimiterString()).show();

  logger = vorpal.logger;

  sop = vorpal.sop;

  vorpal.command('start').description('start the metronome').alias('play').action(function(args, cb) {
    metronome.startMetronome();
    return cb();
  });

  vorpal.command('stop').description('stops the metronome').alias('end').action(function(args, cb) {
    metronome.stopMetronome();
    return cb();
  });

  vorpal.command('tone [frequency] [seconds]').description('play the current or given frequency').action(function(args, cb) {
    var dur, f, frequ, oldFreq;
    if (sound.runningSine) {
      logger.error('already playing tone');
      return cb();
    } else {
      f = sound.freq;
      oldFreq = f;
      if (args.frequency != null) {
        f = args.frequency;
      }
      dur = 2;
      if ((args.seconds != null) && (typeof args.seconds) === 'number') {
        dur = args.seconds;
      }
      frequ = expectFrequency(f);
      if (frequ !== null) {
        sound.freq = frequ;
        startTone();
        setTimeout(function(frequency) {
          stopTone();
          return sound.freq = frequency;
        }, dur * 1000, oldFreq);
      }
      return cb();
    }
  });

  sop.command('meter', sound, {
    validate: expectInt
  }).hidden();

  sop.command('freq', sound, {
    validate: expectFrequency
  }).description('set or print frequency, accepts integers or note names, e.g. g#5');

  sop.command('length', sound, {
    validate: expectFloat
  });

  sop.command('bpm', sound, {
    validate: expectInt,
    passedValidation: function(key, arg, value) {
      return setBPM(value, true);
    }
  });

  vorpal.command('add <bpm>').description('add to the current bpm').action(function(args, cb) {
    var b;
    b = expectInt(args.bpm);
    if (b !== null) {
      metronome.setBPM(sound.bpm + b);
    }
    return cb();
  });

  vorpal.command('mul <factor>').description('multiply the current bpm with the factor').alias('multiply').action(function(args, cb) {
    var f;
    f = expectFloat(args.factor);
    if (f !== null) {
      metronome.setBPM(Math.round(sound.bpm * f));
    }
    return cb();
  });

  sop.command('tapwindow', settings, {
    validate: expectInt,
    passedValidation: function(key, arg, value) {
      logger.confirm("set tapwindow to " + arg);
      return bpm = new onetwoeight(settings.tapwindow, settings.taptolerance);
    }
  }).description('set or print how many of the last taps are used when tapping a tempo');

  sop.command('taptolerance', settings, {
    validate: expectFloat,
    passedValidation: function(key, arg, value) {
      logger.confirm("set taptolerance to " + arg);
      return bpm = new onetwoeight(settings.tapwindow, settings.taptolerance);
    }
  }).description('set or print tolerance when tapping a tempo');

  vorpal["catch"]('[input...]').action(function(args, cb) {
    var b;
    if ((args.input != null) && (args.input.length = 1)) {
      b = expectInt(args.input[0]);
      if (b !== null) {
        setBPM(b);
      }
      return cb();
    }
    vorpal.exec('help');
    return cb();
  });

  vorpal.on('keypress', function(data) {
    var newbpm;
    if (data != null) {
      if (data.e.key.ctrl && data.e.key.name === 'p') {
        if (sound.runningMetro) {
          return stopMetronome();
        } else {
          return startMetronome();
        }
      } else if (data.e.key.ctrl && data.e.key.name === 'left') {
        setBPM(sound.bpm - 1);
        return vorpal.ui.delimiter(delimiterString());
      } else if (data.e.key.ctrl && data.e.key.name === 'right') {
        setBPM(sound.bpm + 1);
        return vorpal.ui.delimiter(delimiterString());
      } else if (data.e.key.meta && data.e.key.name === 'left') {
        setBPM(sound.bpm - 4);
        return vorpal.ui.delimiter(delimiterString());
      } else if (data.e.key.meta && data.e.key.name === 'right') {
        setBPM(sound.bpm + 4);
        return vorpal.ui.delimiter(delimiterString());
      } else if (data.e.key.ctrl && data.e.key.name === '`') {
        bpm.tap();
        newbpm = bpm.bpm();
        if (newbpm != null) {
          setBPM(newbpm);
          return vorpal.ui.delimiter(delimiterString());
        }
      }
    }
  });

  logger.info(chalk.bold.magenta('Welcome to metronome-cli'));

  logger.info("run " + (chalk.yellow('help')) + " for a overview of the available commands");

  logger.info("tap " + (chalk.yellow('space')) + " while holding " + (chalk.yellow('ctrl')) + " to set bpm");

  logger.info("protip: " + (chalk.yellow('ctrl + p')) + " toggles playing");

  logger.info("protip#2: use " + (chalk.yellow('<ctrl | alt> + <arrow_left | arrow_right>')) + " to add or subtract from the current bpm");

  logger.info('protip#3: just enter any number to set bpm without needing a command');

  module.exports = metronome = {
    startMetronome: startMetronome,
    stopMetronome: stopMetronome,
    startTone: startTone,
    stopTone: stopTone,
    setBPM: setBPM,
    expectInt: expectInt,
    expectFloat: expectFloat,
    expectFrequency: expectFrequency,
    vorpal: vorpal
  };

}).call(this);
