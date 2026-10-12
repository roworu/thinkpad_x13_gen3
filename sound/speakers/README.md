# Dolby Atmos speaker tuning

Dolby speaker-correction EQ, ported from the Windows driver, as a native
PipeWire filter-chain.

## Requirements

Arch/CachyOS:
```bash
sudo pacman -S lsp-plugins
```

Fedora:
```bash
sudo dnf install pipewire-module-filter-chain-lv2 lsp-plugins-lv2
```
Fedora's base `pipewire` lacks the LV2 filter-graph backend, so
`pipewire-module-filter-chain-lv2` must be installed for the chain to load.

## Install
```bash
./install.sh
```
Prompts for a profile (Balanced/Detailed/Warm), that was also extracted from Windows Dolby. Re-run to switch, removes the current one first.

