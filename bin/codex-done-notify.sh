#!/bin/bash
# Codex turn-complete notifier. Wired in via `notify` in ~/.codex/config.toml,
# which invokes this with a single JSON arg describing the event.
# Mirrors claude-done-notify.sh: quiet toast when VS Code is focused,
# loud notification + sound when you've tabbed away.
payload="${1:-}"
event=$(printf '%s' "$payload" | jq -r '.type // empty' 2>/dev/null)
[ "$event" = "agent-turn-complete" ] || exit 0

ACTIVE=$(DISPLAY=${DISPLAY:-:0} xdotool getactivewindow getwindowname 2>/dev/null || echo "")
if echo "$ACTIVE" | grep -qi "visual studio code"; then
    notify-send -u normal -t 4000 -i dialog-information 'Codex' 'Done'
else
    notify-send -u critical -i dialog-information 'Codex' 'Finished running'
    pw-play /usr/share/sounds/freedesktop/stereo/complete.oga 2>/dev/null
fi
