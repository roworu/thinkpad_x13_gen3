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

Arch/CachyOS:
```bash
sudo pacman -S lsp-plugins noise-suppression-for-voice
```

Fedora:
```bash
sudo dnf install pipewire-module-filter-chain-lv2 lsp-plugins-lv2
```
The LV2 backend (`pipewire-module-filter-chain-lv2`) is required for the
speaker filter on Fedora, since it is not part of the base `pipewire` package.
The mic denoiser (`noise-suppression-for-voice`) is not in the Fedora repos;
build it from source or install it from a COPR.

## Install everything
```bash
sound/speakers/install.sh
sound/mic/install.sh
sudo power/install.sh
```
