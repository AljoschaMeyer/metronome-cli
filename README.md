# Metronome-CLI

The result of playing around with a few features of [vorpal](https://github.com/dthree/vorpal), but also a useful cli utility.

Tap for bpm, or set set bpm directly and play them.

## Usage

- `start` alias `play`: starts the metronome
- `stop` alias `end`: stops the metronome
- `bpm <bpm>`: set the current bpm
- `add` <bpm>: add to the current bpm
- `mul <factor>` alias `multiply <factor>`: multiply the current bpm with factor
- `meter <meter>`: set the meter, the first tone of a meter is played higher
- `freq <frequency>` alias `frequency <frequency>`: set the pitch to use
- `tone [frequency] [seconds]`: play the current or given frequency
- `tapwindow [window]`: integer which specifies how many of the last taps should be used when setting bpm by tapping
- `taptolerance`: factor that determines when tapping stopped when setting bpm by tapping
  - example: when tapping at 60 bpm with tolerance of 0.5, tempo resets if you don't tap for (60sec/60bpm)\*((1 + 0.5)bpm) = 1.5 sec, or if you tap to fast (twice in (60sec/60bpm)\*((1 - 0.5)bpm) = 0.5 sec)

Bpm will be set automatically by tapping `space` while holding `ctrl`.

Shortcuts:
  - use `ctrl + p` to toggle playing
  - use `ctrl + arrow_left` and `ctrl + arrow_right` to decrement/increment bpm
  - use `alt + arrow_left` and `alt + arrow_right` to decrement/increment bpm by 4
  - writing an integer without any command sets the bpm to that integer

- TODO read args as ints
- TODO freq without arg to print frequency
- TODO meter without arg to print meter
- TODO tapwindow without arg to print tapwindow
- TODO taptolerance without arg to print taptolerance
