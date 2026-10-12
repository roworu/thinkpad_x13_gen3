# Mic noise suppression

RNNoise background-noise removal on the internal mic, as a native
PipeWire filter-chain, set as default input.

## Requirements

Arch/CachyOS:
```bash
sudo pacman -S noise-suppression-for-voice
```

Fedora: not packaged in the official repos. Build
`noise-suppression-for-voice` from source (or a COPR) to get
`librnnoise_ladspa.so`.

## Install
```bash
./install.sh
```

## Tuning
Edit the `control` block in `99-input-denoising.conf`, then
`systemctl --user restart pipewire pipewire-pulse`:
- `VAD Threshold (%)` - voice-detection confidence to pass audio
- `VAD Grace Period (ms)` - hold time after voice stops
