#!/bin/bash

# --- 1. THE "HIGHWAY" (D-BUS & THEME) ---
# Start the session bus so applets don't crash
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval $(dbus-launch --sh-syntax --exit-with-session)
fi

# Fix for the black icons: Force dark theme/icons for GTK applets
export GTK_THEME="Adwaita:dark"
export ICON_THEME="Papirus-Dark"

# --- 2. HELPER FUNCTION ---
function run {
  if ! pgrep -x "$1" > /dev/null; then
    "$@" &
  fi
}

# --- 3. AUDIO SETUP ---
pkill -9 pipewire wireplumber pipewire-pulse 2>/dev/null
pkill pulseaudio 2>/dev/null
pulseaudio --start &

run "udiskie"
run "dunst"
run "redshift"
run "/usr/libexec/polkit-gnome-authentication-agent-1"
run "xautolock" -time 10 -locker blurlock

# Input & Display
sxhkd -c ~/.config/arco-chadwm/sxhkd/sxhkdrc &
picom -b --config ~/.config/arco-chadwm/picom/picom.conf &
run "nitrogen" --restore
run "conky" -c "$HOME/.config/arco-chadwm/conky/system-overview"

# --- 6. THE BAR & WINDOW MANAGER ---
pkill bar.sh
~/.config/arco-chadwm/scripts/bar.sh &

while type chadwm >/dev/null; do
    chadwm && continue || break
done
