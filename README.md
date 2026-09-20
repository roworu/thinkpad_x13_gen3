# ThinkPad X13 Gen 3: Linux tweaks

Configs, source files, and install scripts to improve this laptop
behavior after Linux install.

- **`sound/speakers/`** - Dolby Atmos speaker profile, ported from the
  Windows driver (PipeWire filter-chain).
- **`sound/mic/`** - RNNoise background-noise suppression on the internal
  mic (PipeWire filter-chain).
- **`power/`** - power-saving tweaks.

See each folder `README.md` for what it does, why, and how to
install or tune it.

## Requirements
```bash
sudo pacman -S lsp-plugins calf noise-suppression-for-voice
```

## Install everything
```bash
sound/speakers/install.sh
sound/mic/install.sh
sudo power/install.sh
```
