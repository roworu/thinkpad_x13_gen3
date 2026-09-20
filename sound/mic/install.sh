#!/usr/bin/env bash
# installs mic noise suppression (RNNoise via LADSPA) for ThinkPad X13 Gen 3
# targets the internal Digital Microphone (Realtek ALC257, HDA Mic1).
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONF_DIR="$HOME/.config/pipewire/pipewire.conf.d"
PLUGIN="/usr/lib/ladspa/librnnoise_ladspa.so"

if [[ ! -f "$PLUGIN" ]]; then
  echo "Missing plugin. Install it first:" >&2
  echo "  sudo pacman -S noise-suppression-for-voice   # Arch/CachyOS" >&2
  exit 1
fi

MIC_NODE="alsa_input.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Mic1__source"
if command -v pw-cli >/dev/null && ! pw-cli ls Node 2>/dev/null | grep -q "$MIC_NODE"; then
  echo "Warning: expected mic node '$MIC_NODE' not found on this machine." >&2
  echo "The filter chain may not link to the right input - check with: pw-cli ls Node | grep alsa_input" >&2
fi

mkdir -p "$CONF_DIR"
cp "$HERE/99-input-denoising.conf" "$CONF_DIR/"

systemctl --user restart pipewire pipewire-pulse
sleep 1
pactl set-default-source rnnoise_source

echo "Installed. 'Noise Canceling source' is now the default mic input."
