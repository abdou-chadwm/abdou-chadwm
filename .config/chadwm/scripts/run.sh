#!/bin/sh

conky -c /home/abdou/.config/conky/system-overview &
xrdb merge ~/.Xresources 
xbacklight -set 10 &
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
nitrogen --restore &
dunst &
redshift &
picom &
numlockx on &

dash ~/.config/chadwm/scripts/bar.sh &
while type chadwm >/dev/null; do chadwm && continue || break; done
