#!/usr/bin/env bash
# read-only status check: reports whether the speaker, mic, and power tweaks
# in this repo are installed and active on this machine. exits non-zero if
# any component is missing or not fully applied.
set -uo pipefail

CONF_DIR="$HOME/.config/pipewire/pipewire.conf.d"
AUDIO_MODPROBE="/etc/modprobe.d/audio-powersave.conf"
WIFI_NM_CONF="/etc/NetworkManager/conf.d/wifi-powersave.conf"
AUDIO_POWER_SAVE="/sys/module/snd_hda_intel/parameters/power_save"

problems=0
warnings=0

ok() { printf '  [ ok ] %s\n' "$*"; }
miss() { printf '  [miss] %s\n' "$*"; problems=$((problems + 1)); }
warn() { printf '  [warn] %s\n' "$*"; warnings=$((warnings + 1)); }

check_speakers() {
  local conf variant irs path node

  printf '\nSpeaker filter (Dolby):\n'

  conf="$(ls "$CONF_DIR"/Dolby_*.conf 2>/dev/null | head -n1)"
  if [[ -z "$conf" ]]; then
    miss "not installed (no Dolby_*.conf in $CONF_DIR)"
    return
  fi
  variant="$(basename "$conf" .conf)"
  ok "installed: $variant"

  irs="$CONF_DIR/$variant.irs"
  if [[ -f "$irs" ]]; then
    ok "impulse response: $variant.irs"
  else
    miss "missing impulse response: $variant.irs"
  fi

  path="$(sed -nE 's/.*filename = "([^"]+)".*/\1/p' "$conf" | head -n1)"
  if [[ -n "$path" && -f "$path" ]]; then
    ok "convolver path resolves"
  else
    miss "convolver path does not resolve: ${path:-none}"
  fi

  node="${variant//_/-}"
  if command -v pw-cli >/dev/null 2>&1; then
    if pw-cli ls Node 2>/dev/null | grep -qF "$node"; then
      ok "filter node loaded"
    else
      miss "filter node not loaded (restart pipewire?)"
    fi
  fi

  if pgrep -x easyeffects >/dev/null 2>&1; then
    warn "EasyEffects is running - it will double-process the audio"
  fi
}

check_mic() {
  local conf plugin default

  printf '\nMic noise suppression (RNNoise):\n'

  conf="$CONF_DIR/99-input-denoising.conf"
  if [[ ! -f "$conf" ]]; then
    miss "not installed (missing $conf)"
    return
  fi
  ok "conf installed"

  plugin="$(sed -nE 's/^[[:space:]]*plugin = (.*)$/\1/p' "$conf" | head -n1)"
  if [[ -n "$plugin" && -f "$plugin" ]]; then
    ok "plugin present: $plugin"
  else
    miss "plugin missing: ${plugin:-none}"
  fi

  if command -v pactl >/dev/null 2>&1; then
    default="$(pactl get-default-source 2>/dev/null || true)"
    if [[ "$default" == "rnnoise_source" ]]; then
      ok "default source: rnnoise_source"
    else
      miss "default source is '${default:-unknown}', expected rnnoise_source"
    fi
  fi
}

check_power() {
  local value state iface

  printf '\nPower tweaks:\n'

  if [[ -f "$AUDIO_MODPROBE" ]]; then
    ok "audio power-save conf installed"
  else
    miss "missing $AUDIO_MODPROBE"
  fi

  if [[ -f "$WIFI_NM_CONF" ]]; then
    ok "wifi power-save conf installed"
  else
    miss "missing $WIFI_NM_CONF"
  fi

  if [[ -r "$AUDIO_POWER_SAVE" ]]; then
    value="$(cat "$AUDIO_POWER_SAVE")"
    if [[ "$value" == "1" ]]; then
      ok "audio codec power_save active"
    else
      miss "audio codec power_save=$value (expected 1 - reboot or re-run)"
    fi
  else
    warn "cannot read $AUDIO_POWER_SAVE (snd_hda_intel not loaded?)"
  fi

  if command -v iw >/dev/null 2>&1; then
    iface="$(iw dev 2>/dev/null | awk '/Interface/{print $2; exit}')"
    if [[ -n "$iface" ]]; then
      state="$(iw dev "$iface" get power_save 2>/dev/null | awk -F': ' '/[Pp]ower save/{print $2}')"
      if [[ "$state" == "on" ]]; then
        ok "wifi power_save on ($iface)"
      else
        miss "wifi power_save ${state:-unknown} ($iface)"
      fi
    fi
  fi
}

printf 'ThinkPad X13 Gen 3 - status\n'
check_speakers
check_mic
check_power

printf '\n'
if [[ "$problems" -gt 0 ]]; then
  echo "$problems component check(s) need attention."
  exit 1
fi
if [[ "$warnings" -gt 0 ]]; then
  echo "All tweaks applied, but see the warnings above."
  exit 0
fi
echo "All tweaks applied."
exit 0
