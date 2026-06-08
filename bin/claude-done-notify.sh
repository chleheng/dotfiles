#!/bin/bash
ACTIVE=$(DISPLAY=${DISPLAY:-:0} xdotool getactivewindow getwindowname 2>/dev/null || echo "")
if echo "$ACTIVE" | grep -qi "visual studio code"; then
    notify-send -u normal -t 4000 -i dialog-information 'Claude Code' 'Done'
else
    notify-send -u critical -i dialog-information 'Claude Code' 'Finished running'
    pw-play /usr/share/sounds/freedesktop/stereo/complete.oga 2>/dev/null
fi
