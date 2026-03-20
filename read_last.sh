#!/bin/bash
# Claude Speak — Read last Claude response aloud using Piper
# Called by the /read command in Claude Code

PIPER="$HOME/.claude/piper-venv/bin/python3"
MODEL="$HOME/.claude/piper-voices/en_US-lessac-high.onnx"
LAST_RESPONSE="$HOME/.claude/last_response.txt"
TMP_WAV="/tmp/claude_read_$$.wav"

if [ ! -f "$LAST_RESPONSE" ]; then
  echo "No response saved yet."
  exit 1
fi

TEXT=$(cat "$LAST_RESPONSE")

if [ -z "$TEXT" ]; then
  echo "Last response is empty."
  exit 1
fi

echo "$TEXT" | "$PIPER" -m piper \
  --model "$MODEL" \
  --output_file "$TMP_WAV" 2>/dev/null && afplay "$TMP_WAV"

rm -f "$TMP_WAV"
