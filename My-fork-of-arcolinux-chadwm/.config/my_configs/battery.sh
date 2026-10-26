#!/bin/bash
# usage: battery.sh percentage | status | icon
bat=$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -n1)
[ -z "$bat" ] && exit 0

cap=$(<"$bat/capacity")
status=$(<"$bat/status")

case "$1" in
  percentage) echo "$cap" ;;
  status)     echo "$status" ;;
  icon)
    # Nerd Font glyphs written as UTF-8 bytes so the locale doesn't matter
    if   [ "$status" = "Charging" ]; then printf '\xef\x83\xa7'  # bolt
    elif [ "$cap" -ge 90 ]; then printf '\xef\x89\x80'           # full
    elif [ "$cap" -ge 65 ]; then printf '\xef\x89\x81'           # 3/4
    elif [ "$cap" -ge 40 ]; then printf '\xef\x89\x82'           # half
    elif [ "$cap" -ge 15 ]; then printf '\xef\x89\x83'           # 1/4
    else                         printf '\xef\x89\x84'           # empty
    fi ;;
esac
