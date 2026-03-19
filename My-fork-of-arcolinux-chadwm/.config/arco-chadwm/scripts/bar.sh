#!/bin/dash

# ^c$var^ = fg color
# ^b$var^ = bg color

interval=0

# load colors
. ~/.config/arco-chadwm/scripts/bar_themes/onedark

cpu() {
  cpu_val=$(grep -o "^[^ ]*" /proc/loadavg)
  printf "^c$white^  ^b$black^ CPU ^c$white^^b$black^$cpu_val"
}

pkg_updates() {
  updates=$(xbps-install -un 2>/dev/null | wc -l)
  if [ "$updates" -gt 0 ]; then
    printf "^c$green^ 󰅢 ^c$white^$updates updates"
  else
    printf "^c$green^ 󰅢 ^c$white^Updated"
  fi
}

# --- NEW VOLUME FUNCTION ---
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
battery() {
  bat_path=$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -n 1)
  if [ -n "$bat_path" ]; then
    capacity=$(cat "$bat_path/capacity" 2>/dev/null)
    status=$(cat "$bat_path/status" 2>/dev/null)
    [ "$status" = "Charging" ] && icon="󰂄" || icon=""
    printf "^c$blue^ $icon $capacity%%"
  else
    printf "^c$blue^  No Bat"
  fi
}

brightness() {
  backlight_val=$(cat /sys/class/backlight/*/brightness | head -n 1)
  printf "^c$red^  ^c$red^$backlight_val"
}

mem() {
  printf "^c$blue^^b$black^  ^c$blue^$(free -m | awk '/^Mem/ { print $3 }')MB"
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
  if [ $interval = 0 ] || [ $((interval % 600)) = 0 ]; then
    updates=$(pkg_updates)
    interval=0
  fi
  
  interval=$((interval + 1))

  # Added $(vol) to the root name string
  xsetroot -name "$updates  $(vol)  $(battery)  $(brightness)  $(cpu)$(mem)  $(wlan)  $(clock)"
  
  sleep 3
done
