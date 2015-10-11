# Metronome-CLI

The result of playing around with a few features of [vorpal](https://github.com/dthree/vorpal), but also a useful cli utility.

Tap for bpm, or set set bpm directly and play them.
Can also play arbitrary sine tones.

## Installation

```bash
npm install -g metronome-cli
```

## Usage

Run `metronome` to start an [immersive session](https://github.com/dthree/vorpal#what-is-an-immersive-cli-app) with the following commands:

- `start` alias `play`: starts the metronome
- `stop` alias `end`: stops the metronome
- `bpm <bpm>`: set or print the current bpm
- `add` <bpm>: add to the current bpm
- `mul <factor>` alias `multiply <factor>`: multiply the current bpm with factor
- `freq <frequency>` alias `frequency <frequency>`: set or print the pitch to use
- `tone [frequency] [seconds]`: play the current or given frequency
- `tapwindow [window]`: set or print the integer which specifies how many of the last taps should be used when setting bpm by tapping
- `taptolerance`: set or print the factor that determines when tapping stopped when setting bpm by tapping
  - example: when tapping at 60 bpm with tolerance of 0.5, tempo resets if you don't tap for (60sec/60bpm)\*((1 + 0.5)bpm) = 1.5 sec, or if you tap to fast (twice in (60sec/60bpm)\*((1 - 0.5)bpm) = 0.5 sec)
- `length [seconds]`: set or print the length of the metronome ticks

Bpm will be set automatically by tapping `space` while holding `ctrl`.

Shortcuts:
  - use `ctrl + p` to toggle playing
  - use `ctrl + arrow_left` and `ctrl + arrow_right` to decrement/increment bpm
  - use `alt + arrow_left` and `alt + arrow_right` to decrement/increment bpm by 4
  - writing an integer without any command sets the bpm to that integer
