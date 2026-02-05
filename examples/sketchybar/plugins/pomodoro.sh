#!/bin/sh

POMODORO="$HOME/go/bin/pomodoro"
STATUS=$($POMODORO status 2>/dev/null)

if [ -z "$STATUS" ]; then
  sketchybar --set "$NAME" \
    icon="󰔟" \
    label="00:00" \
    icon.color=0xff9a67ea
else
  REMAINING=$($POMODORO status -f "%r" 2>/dev/null)

  if [ "$REMAINING" = "0:00" ]; then
    sketchybar --set "$NAME" \
      icon="󰾫" \
      label="Done" \
      icon.color=0xff9a67ea
  else
    sketchybar --set "$NAME" \
      icon="󱎫" \
      label="$REMAINING" \
      icon.color=0xffff6961
  fi
fi
