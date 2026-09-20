#!/usr/bin/env bash
# applies power-saving tweaks confirmed safe by a powertop measurement
# on ThinkPad X13 Gen 3 (i5-1235U). Needs root.
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Run with sudo: sudo ./install.sh" >&2
  exit 1
fi

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cp "$HERE/audio-powersave.conf" /etc/modprobe.d/audio-powersave.conf
mkdir -p /etc/NetworkManager/conf.d
cp "$HERE/wifi-powersave.conf" /etc/NetworkManager/conf.d/wifi-powersave.conf

# apply now, without waiting for reboot
echo 1 > /sys/module/snd_hda_intel/parameters/power_save
systemctl reload NetworkManager
nmcli radio wifi off || true
sleep 1
nmcli radio wifi on

echo "Installed. Audio codec + WiFi power-save active now, and on every boot."
