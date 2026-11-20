# PocketMac — Reversible macOS "Vacation Mode" lid-close toggles
# Source this file from ~/.zshrc:
#   source "$HOME/.pocketmac.zsh"

# Enable Vacation Mode: stay awake with lid closed while plugged into AC power
pocket-on() {
  sudo pmset -a disablesleep 1 || return 1
  pkill -x caffeinate 2>/dev/null
  nohup caffeinate -s >/dev/null 2>&1 &!
  echo "PocketMac Vacation Mode ON: Safe to close lid while plugged in."
}

# Disable Vacation Mode: stop caffeinate and restore normal lid-close sleep
pocket-off() {
  pkill -x caffeinate 2>/dev/null
  sudo pmset -a disablesleep 0 || return 1
  echo "PocketMac Vacation Mode OFF: Normal lid-close sleep restored."
}

# Print current Vacation Mode status in plain English
pocket-status() {
  local sleep_disabled
  sleep_disabled=$(pmset -g | grep SleepDisabled | awk '{print $2}')
  if [[ "$sleep_disabled" == "1" ]]; then
    echo "PocketMac Vacation Mode is ON (SleepDisabled=1: lid-close sleep is disabled)."
  else
    echo "PocketMac Vacation Mode is OFF (SleepDisabled=0: normal lid-close sleep is active)."
  fi
}

# Print dynamic connection details for this Mac (Tailscale IP, SMB, VNC, status)
pocket-info() {
  local ts_bin ts_ip ts_dns mac_user
  if command -v tailscale >/dev/null 2>&1; then
    ts_bin="tailscale"
  elif [[ -x "/Applications/Tailscale.app/Contents/MacOS/Tailscale" ]]; then
    ts_bin="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
  fi

  mac_user=$(whoami)
  echo "=== PocketMac Connection Info ==="
  echo "macOS User:  $mac_user"

  if [[ -n "$ts_bin" ]]; then
    ts_ip=$("$ts_bin" ip -4 2>/dev/null | head -n 1)
    ts_dns=$("$ts_bin" status --json 2>/dev/null | awk -F'"' '/"DNSName":/ {sub(/\.$/, "", $4); print $4; exit}')
    echo "Tailscale IP: ${ts_ip:-not connected}"
    [[ -n "$ts_dns" ]] && echo "MagicDNS:     $ts_dns"
    [[ -n "$ts_ip" ]] && echo "SMB (Files):  smb://$ts_ip"
    [[ -n "$ts_ip" ]] && echo "VNC (Screen): $ts_ip (port 5900)"
  else
    echo "Tailscale:    not installed (run: brew install --cask tailscale-app)"
  fi

  pocket-status
}
