#!/bin/bash

# OneDark Colors
black="#1e222a"
white="#abb2bf"
red="#e06c75"
green="#98c379"
yellow="#e5c07b"
blue="#61afef"
magenta="#c678dd"

interval=0

pkg_updates() {
  updates=$(xbps-install -un 2>/dev/null | wc -l)
  printf "^c$green^ 󰅢 ^c$white^$updates updates"
}

vol() {
  # Check if muted first
  if [ "$(pamixer --get-mute)" = "true" ]; then
    printf "^c$red^ 󰝟 ^c$red^Muted"
  else
    # Get the raw number (e.g., 50)
    vol_num=$(pamixer --get-volume)
    printf "^c$green^ 󰕾 ^c$white^${vol_num}%%"
  fi
}

brightness() {
  backlight_val=$(cat /sys/class/backlight/*/brightness | head -n 1)
  printf "^c$red^  ^c$red^$backlight_val"
}

battery() {
  bat_path=$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -n 1)
  if [ -n "$bat_path" ]; then
    capacity=$(cat "$bat_path/capacity" 2>/dev/null)
    status=$(cat "$bat_path/status" 2>/dev/null)
    [ "$status" = "Charging" ] && icon="" || icon="󰁹"
    printf "^c$blue^ $icon $capacity%%"
  else
    printf "^c$blue^ 󰁹 No Bat"
  fi
}

blue_mod() {
  if ! pgrep -x "bluetoothd" >/dev/null; then
    printf "^c$red^ 󰂲 Off"
    return
  fi
  if timeout 0.1s bluetoothctl info 2>/dev/null | grep -q "Connected: yes"; then
    printf "^c$blue^ 󰂱 Connected"
  else
    printf "^c$magenta^ 󰂯 On"
  fi
}

cpu() {
  cpu_val=$(grep -o "^[^ ]*" /proc/loadavg)
  printf "^c$white^  ^b$black^ CPU ^c$white^^b$black^$cpu_val"
}

mem() {
  val=$(free -m | awk '/^Mem/ { print $3 }')
  printf "^c$blue^  ^c$white^${val}MB"
}

wlan() {
  case "$(cat /sys/class/net/wl*/operstate 2>/dev/null)" in
    up) printf "^c$black^ ^b$blue^ 󰤨 ^d^%s" " ^c$blue^Connected" ;;
    down) printf "^c$black^ ^b$blue^ 󰤭 ^d^%s" " ^c$blue^Disconnected" ;;
  esac
}

clock() {
    printf "^c$black^^b$blue^ $(date '+%d/%m/%y %I:%M %p') "
}

while true; do
  # Changed to -eq for safer number comparison in bash
  if [ "$interval" -eq 0 ] || [ "$((interval % 600))" -eq 0 ]; then
    upd=$(pkg_updates)
    interval=0
  fi
  
  interval=$((interval + 1))

  # Fixed spacing and added $(brightness)
  xsetroot -name "$upd  $(vol)  $(brightness)  $(battery)  $(blue_mod)  $(cpu)  $(mem)  $(wlan)  $(clock)"
  
  sleep 3
done
