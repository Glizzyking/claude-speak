#!/bin/bash
# Claude Speak — Stop hook: silently saves last response text for on-demand TTS
# Run `speak` in your terminal to hear the last response.

PIPER="$HOME/.claude/piper-venv/bin/python3"
LAST_RESPONSE="$HOME/.claude/last_response.txt"

INPUT=$(cat)

"$PIPER" -c "
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
except Exception:
    sys.exit(0)
" <<< "$INPUT" > "$LAST_RESPONSE" 2>/dev/null
