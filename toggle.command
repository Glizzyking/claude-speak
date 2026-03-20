#!/bin/bash
# Claude Speak Toggle — double-click this file to enable/disable auto-speak

TOGGLE="$HOME/.claude/speak_on"

if [ -f "$TOGGLE" ]; then
  rm "$TOGGLE"
  osascript -e 'display notification "Auto-speak is now OFF" with title "Claude Speak"'
  echo "Auto-speak disabled."
else
  touch "$TOGGLE"
  osascript -e 'display notification "Auto-speak is now ON" with title "Claude Speak"'
  echo "Auto-speak enabled."
fi
