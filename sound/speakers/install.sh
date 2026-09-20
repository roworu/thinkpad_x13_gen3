#!/usr/bin/env bash
# installs the Dolby Atmos PipeWire filter-chain for ThinkPad X13 Gen 3
# (Realtek ALC257, subsystem 17AA22EF)
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONF_DIR="$HOME/.config/pipewire/pipewire.conf.d"

if ! command -v pipewire >/dev/null; then
  echo "pipewire not found - this setup only applies to a PipeWire system." >&2
  exit 1
fi

if [[ ! -d /usr/lib/lv2/lsp-plugins.lv2 ]] || [[ ! -d /usr/lib/lv2/calf.lv2 ]]; then
  echo "Missing LV2 plugins. Install them first:" >&2
  echo "  sudo pacman -S lsp-plugins calf   # Arch/CachyOS" >&2
  exit 1
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
