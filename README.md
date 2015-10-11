# Metronome-CLI

The result of playing around with a few features of [vorpal](https://github.com/dthree/vorpal), but also a useful cli utility.

Tap for bpm, or set set bpm directly and play them.

## Usage

- `start` alias `play`: starts the metronome
- `stop` alias `end`: stops the metronome
- `mute`: turn off sound
- `unmute`: `turn on sound`
- `bpm <bpm>`: set the current bpm
- `add` <bpm>: add to the current bpm
- `mul <factor>` alias `multiply <factor>`: multiply the current bpm with factor
- `tap [avg] [tolerance]`: set the current bpm by tapping any keys.
  - `[avg]`: integer which specifies how many of the last taps should be used
    - defaults to 20
  - `[tolerance]`: A factor that determines when tapping stopped
    - defaults to 1.
    - example: when tapping at 60 bpm with tolerance of 0.5, tap mode will end if you don't tap for (60sec/60bpm)\*((1 + 0.5)bpm) = 1.5 sec, or if you tap to fast (twice in (60sec/60bpm)\*((1 - 0.5)bpm) = 0.5 sec)

Shortcuts:
  - the empty command toggles between starting and stopping the metronome
  - writing an integer without any command sets the bpm to that integer
