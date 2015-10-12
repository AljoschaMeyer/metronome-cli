#! /usr/bin/env node
(function() {
  var avg, bpm, chalk, delimiterString, expectFloat, expectInt, globalFrequency, logger, onetwoeight, setBPM, sound, startMetronome, startTone, stopMetronome, stopTone, tol, vorpal, vorpalLog;

  vorpal = (require('vorpal'))();

  vorpalLog = require('vorpal-log');

  chalk = require('chalk');

  onetwoeight = require('onetwoeight');

  sound = require('./sound');

  avg = 20;

  tol = 0.5;

  bpm = new onetwoeight(avg, tol);

  globalFrequency = 440;

  expectInt = function(arg, cb) {
    var int;
    int = parseInt(arg);
    if ((int != null) && int > 0) {
      return cb(int);
    } else {
      return logger.warn("invalid argument, expected " + arg + " to be a nonzero, positive integer");
    }
  };

  expectFloat = function(arg, cb) {
    var flt;
    flt = parseFloat(arg);
    if ((arg != null) && (!isNaN(flt)) && (flt !== 0)) {
      return cb(flt);
    } else {
      return logger.warn("invalid argument, expected " + arg + " to be a nonzero float");
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

  setBPM = function(bpm) {
    var changed;
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
    if (changed) {
      vorpal.delimiter(delimiterString());
      return logger.confirm("set bpm to " + bpm);
    }
  };

  vorpal.use(vorpalLog, {
    markdown: true
  }).delimiter(delimiterString()).show();

  logger = vorpal.logger;

  vorpal.command('start').description('start the metronome').alias('play').action(function(args, cb) {
    startMetronome();
    return cb();
  });

  vorpal.command('stop').description('stops the metronome').alias('end').action(function(args, cb) {
    stopMetronome();
    return cb();
  });

  vorpal.command('meter [meter]').description('set the current meter').action(function(args, cb) {
    if (args.meter == null) {
      logger.info("meter: " + sound.meter);
      return cb();
    }
    expectInt(args.meter, function(m) {
      sound.meter = m;
      return logger.confirm("set meter to " + m);
    });
    return cb();
  });

  vorpal.command('freq [frequency]').description('set the pitch').alias('frequency').action(function(args, cb) {
    if (args.frequency == null) {
      logger.info("frequency: " + globalFrequency);
      return cb();
    }
    expectInt(args.frequency, function(f) {
      globalFrequency = f;
      sound.freq = f;
      return logger.confirm("set frequency to " + f);
    });
    return cb();
  });

  vorpal.command('length [seconds]').description('set the length of the metronome ticks').action(function(args, cb) {
    if (args.seconds == null) {
      logger.info("length: " + sound.length);
      return cb();
    }
    expectFloat(args.seconds, function(l) {
      sound.length = l;
      return logger.confirm("set length to " + l);
    });
    return cb();
  });

  vorpal.command('tone [frequency] [seconds]').description('play the current or given frequency').action(function(args, cb) {
    var dur, f;
    if (sound.runningSine) {
      logger.error('already playing tone');
      return cb();
    } else {
      f = globalFrequency;
      if (args.frequency != null) {
        f = args.frequency;
      }
      dur = 2;
      if ((args.seconds != null) && (typeof args.seconds) === 'number') {
        dur = args.seconds;
      }
      expectInt(f, function(frequ) {
        sound.freq = frequ;
        startTone();
        return setTimeout(function(frequency) {
          stopTone();
          return sound.freq = frequency;
        }, dur * 1000, globalFrequency);
      });
      return cb();
    }
  });

  vorpal.command('bpm [bpm]').description('set the current bpm').action(function(args, cb) {
    if (args.bpm == null) {
      logger.info("bpm: " + sound.bpm);
      return cb();
    }
    expectInt(args.bpm, function(b) {
      return setBPM(b);
    });
    return cb();
  });

  vorpal.command('add <bpm>').description('add to the current bpm').action(function(args, cb) {
    expectInt(args.bpm, function(b) {
      return setBPM(sound.bpm + b);
    });
    return cb();
  });

  vorpal.command('mul <factor>').description('multiply the current bpm with the factor').alias('multiply').action(function(args, cb) {
    expectFloat(args.factor, function(f) {
      return setBPM(Math.round(sound.bpm * f));
    });
    return cb();
  });

  vorpal.command('tapwindow [window]').description('how many of the last taps are used when tapping a tempo').action(function(args, cb) {
    if (args.window == null) {
      logger.info("window: " + avg);
      return cb();
    }
    expectInt(args.window, function(w) {
      avg = w;
      bpm = new onetwoeight(avg, tol);
      return logger.confirm("set tapwindow to " + w);
    });
    return cb();
  });

  vorpal.command('taptolerance [tolerance]').description('tolerance when tapping a tempo').action(function(args, cb) {
    if (args.tolerance == null) {
      logger.info("tolerance: " + tol);
      return cb();
    }
    expectFloat(args.tolerance, function(t) {
      tol = t;
      bpm = new onetwoeight(avg, tol);
      return logger.confirm("set taptolerance to " + t);
    });
    return cb();
  });

  vorpal["catch"]('[input...]').action(function(args, cb) {
    if ((args.input != null) && (args.input.length = 1)) {
      expectInt(args.input[0], function(b) {
        return setBPM(b);
      });
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

  logger.info('# Welcome to metronome-cli');

  logger.info('run `help` for a overview of the available commands');

  logger.info('tap `space` while holding `ctrl` to set bpm');

  logger.info('protip: `ctrl + p` toggles playing');

  logger.info('protip#2: use `<ctrl | alt> + <arrow_left | arrow_right>` to add or subtract from the current bpm');

  logger.info('protip#3: just enter any number to set bpm without needing a command');

}).call(this);
