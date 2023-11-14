#!/usr/bin/env bash

# Terminate already running bar instances
# If all your bars have ipc enabled, you can use 
polybar-msg cmd quit
# Otherwise you can use the nuclear option:
killall -q polybar

rm -f /tmp/polybar*.log
if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar --reload primary 2>&1 | tee -a /tmp/polybar-${BAR}-$m.log & disown
  done
  MONITOR=eDP-1-1 polybar -c ~/.config/polybar/bottom.ini --reload bottom 2>&1 | tee -a /tmp/polybar-bottom.log & disown
else
  polybar --reload primary 2>&1 | tee -a /tmp/polybar-primary.log & disown
  polybar -c ~/.config/polybar/bottom.ini --reload bottom 2>&1 | tee -a /tmp/polybar-bottom.log & disown
fi
