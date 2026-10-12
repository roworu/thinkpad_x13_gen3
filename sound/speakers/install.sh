#!/usr/bin/env bash
# installs the Dolby Atmos PipeWire filter-chain for ThinkPad X13 Gen 3
# (Realtek ALC257, subsystem 17AA22EF)
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONF_DIR="$HOME/.config/pipewire/pipewire.conf.d"

# lv2 bundles live under /usr/lib on arch, /usr/lib64 on fedora
find_lsp_lv2() {
  local d
  for d in /usr/lib/lv2 /usr/lib64/lv2 /usr/local/lib/lv2 /usr/local/lib64/lv2; do
    [[ -d "$d/lsp-plugins.lv2" ]] && return 0
  done
  return 1
}

find_lv2_backend() {
  local d
  for d in /usr/lib/spa-0.2 /usr/lib64/spa-0.2; do
    [[ -f "$d/filter-graph/libspa-filter-graph-plugin-lv2.so" ]] && return 0
  done
  return 1
}

if ! command -v pipewire >/dev/null; then
  echo "pipewire not found - this setup only applies to a PipeWire system." >&2
  exit 1
fi

if ! find_lsp_lv2; then
  echo "Missing LV2 plugins. Install them first:" >&2
  if command -v pacman >/dev/null 2>&1; then
    echo "  sudo pacman -S lsp-plugins                       # Arch/CachyOS" >&2
  elif command -v dnf >/dev/null 2>&1; then
    echo "  sudo dnf install pipewire-module-filter-chain-lv2 lsp-plugins-lv2   # Fedora" >&2
  elif command -v apt-get >/dev/null 2>&1; then
    echo "  sudo apt install lsp-plugins-lv2                 # Debian/Ubuntu" >&2
  fi
  exit 1
fi

# pipewire's lv2 filter-graph backend is a separate package on fedora
if ! find_lv2_backend; then
  echo "Warning: pipewire's LV2 filter-graph backend is missing." >&2
  echo "On Fedora install it with: sudo dnf install pipewire-module-filter-chain-lv2" >&2
fi

echo "Which voicing?"
echo "  1) Balanced (default) - Dolby's neutral tilt"
echo "  2) Detailed - brighter, more treble"
echo "  3) Warm - more bass/low-mid"
read -rp "Choice [1]: " choice
case "${choice:-1}" in
  1) VARIANT="Balanced" ;;
  2) VARIANT="Detailed" ;;
  3) VARIANT="Warm" ;;
  *) echo "Invalid choice." >&2; exit 1 ;;
esac

CONF_SRC="$HERE/Dolby_${VARIANT}.conf"
IRS_SRC="$HERE/Dolby_${VARIANT}.irs"
if [[ ! -f "$CONF_SRC" || ! -f "$IRS_SRC" ]]; then
  echo "Missing $CONF_SRC / $IRS_SRC" >&2
  exit 1
fi

mkdir -p "$CONF_DIR"

# remove any previously-installed variant first, so switching voicing
# replaces the chain instead of stacking two on the same sink
rm -f "$CONF_DIR"/Dolby_*.conf "$CONF_DIR"/Dolby_*.irs

cp "$IRS_SRC" "$CONF_DIR/"
# rewrite the embedded .irs path to wherever it actually lands, regardless
# of where it pointed when this bundle was generated
sed -E "s#filename = \"[^\"]*Dolby_${VARIANT}\.irs\"#filename = \"$CONF_DIR/Dolby_${VARIANT}.irs\"#" \
  "$CONF_SRC" > "$CONF_DIR/Dolby_${VARIANT}.conf"

# EasyEffects, if present, must not run - it would double-process the
# same audio alongside this filter-chain.
pkill -x easyeffects 2>/dev/null || true
rm -f "$HOME/.config/autostart"/*easyeffects*.desktop

systemctl --user restart pipewire pipewire-pulse

echo "Installed. Dolby-$VARIANT active on the internal speaker."
