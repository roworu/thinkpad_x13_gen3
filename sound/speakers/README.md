# Dolby Atmos speaker tuning

Dolby speaker-correction EQ, ported from the Windows driver, as a native
PipeWire filter-chain.

## Requirements
```bash
sudo pacman -S lsp-plugins calf
```

## Install
```bash
./install.sh
```
Prompts for a profile (Balanced/Detailed/Warm), that was also extracted from Windows Dolby. Re-run to switch, removes the current one first.

