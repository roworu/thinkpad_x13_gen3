#!/usr/bin/env bash
# installs mic noise suppression (RNNoise via LADSPA) for ThinkPad X13 Gen 3
# targets the internal Digital Microphone (Realtek ALC257, HDA Mic1).
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONF_DIR="$HOME/.config/pipewire/pipewire.conf.d"

# ladspa plugins live under /usr/lib on arch, /usr/lib64 on fedora
find_rnnoise() {
  local d
  for d in /usr/lib/ladspa /usr/lib64/ladspa /usr/local/lib/ladspa /usr/local/lib64/ladspa; do
    [[ -f "$d/librnnoise_ladspa.so" ]] && { printf '%s\n' "$d/librnnoise_ladspa.so"; return 0; }
  done
  return 1
}

if ! PLUGIN="$(find_rnnoise)"; then
  echo "Missing plugin (librnnoise_ladspa.so). Install it first:" >&2
  if command -v pacman >/dev/null 2>&1; then
    echo "  sudo pacman -S noise-suppression-for-voice   # Arch/CachyOS" >&2
  elif command -v dnf >/dev/null 2>&1; then
    echo "  Not in the Fedora repos - build from source or install from a COPR." >&2
  fi
  exit 1
fi

MIC_NODE="alsa_input.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Mic1__source"
if command -v pw-cli >/dev/null && ! pw-cli ls Node 2>/dev/null | grep -q "$MIC_NODE"; then
  echo "Warning: expected mic node '$MIC_NODE' not found on this machine." >&2
  echo "The filter chain may not link to the right input - check with: pw-cli ls Node | grep alsa_input" >&2
fi

mkdir -p "$CONF_DIR"
# point the chain at wherever the plugin actually lives on this distro
sed -E "s#plugin = .*librnnoise_ladspa\.so#plugin = $PLUGIN#" \
  "$HERE/99-input-denoising.conf" > "$CONF_DIR/99-input-denoising.conf"

systemctl --user restart pipewire pipewire-pulse
sleep 1
pactl set-default-source rnnoise_source

echo "Installed. 'Noise Canceling source' is now the default mic input."
