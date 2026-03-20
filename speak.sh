#!/bin/bash
# Claude Speak — TTS hook for Claude Code using Piper local AI voice
# Toggle auto-speak: touch ~/.claude/speak_on  /  rm ~/.claude/speak_on
#
# Install: copy this file to ~/.claude/hooks/speak.sh and register it
# as a "Stop" hook in ~/.claude/settings.json (see README.md)

TOGGLE="$HOME/.claude/speak_on"
PIPER="$HOME/.claude/piper-venv/bin/python3"
MODEL="$HOME/.claude/piper-voices/en_US-lessac-high.onnx"
TMP_WAV="/tmp/claude_speak_$$.wav"
LAST_RESPONSE="$HOME/.claude/last_response.txt"

# Read the hook input
INPUT=$(cat)

# Extract and clean last_assistant_message directly from the JSON
TEXT=$(echo "$INPUT" | "$PIPER" -c "
import sys, json, re

try:
    data = json.load(sys.stdin)
    content = data.get('last_assistant_message', '')

    if not content or content == 'HEARTBEAT_OK':
        sys.exit(0)

    # Strip code blocks
    content = re.sub(r'\`\`\`.*?\`\`\`', 'code block omitted.', content, flags=re.DOTALL)
    content = re.sub(r'\`[^\`]+\`', '', content)

    # Clean markdown
    content = re.sub(r'#{1,6}\s+', '', content)
    content = re.sub(r'\*{1,2}([^*]+)\*{1,2}', r'\1', content)
    content = re.sub(r'_{1,2}([^_]+)_{1,2}', r'\1', content)
    content = re.sub(r'\[([^\]]+)\]\([^\)]+\)', r'\1', content)
    content = re.sub(r'\n+', ' ', content).strip()

    if len(content) > 1500:
        content = content[:1500] + '... response truncated.'

    print(content)
except Exception as e:
    sys.exit(0)
" 2>/dev/null)

# Always save the last response for /read on-demand
if [ -n "$TEXT" ]; then
  echo "$TEXT" > "$LAST_RESPONSE"
fi

# Only auto-speak if toggle is on
if [ ! -f "$TOGGLE" ]; then
  exit 0
fi

if [ -n "$TEXT" ]; then
  echo "$TEXT" | "$PIPER" -m piper \
    --model "$MODEL" \
    --output_file "$TMP_WAV" 2>/dev/null
  afplay "$TMP_WAV" 2>/dev/null
  rm -f "$TMP_WAV"
fi
