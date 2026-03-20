#!/bin/bash
# Claude Speak — Installer
# Sets up Piper TTS and registers the speak hook with Claude Code

set -e

CLAUDE_DIR="$HOME/.claude"
HOOKS_DIR="$CLAUDE_DIR/hooks"
VENV_DIR="$CLAUDE_DIR/piper-venv"
VOICES_DIR="$CLAUDE_DIR/piper-voices"
SETTINGS="$CLAUDE_DIR/settings.json"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Claude Speak Installer ==="

# 1. Create directories
mkdir -p "$HOOKS_DIR" "$VOICES_DIR"

# 2. Copy hook scripts
cp "$SCRIPT_DIR/speak.sh" "$HOOKS_DIR/speak.sh"
cp "$SCRIPT_DIR/read_last.sh" "$HOOKS_DIR/read_last.sh"
chmod +x "$HOOKS_DIR/speak.sh" "$HOOKS_DIR/read_last.sh"
echo "✓ Hook scripts installed"

# 3. Set up Piper Python venv if not already present
if [ ! -f "$VENV_DIR/bin/python3" ]; then
  echo "Setting up Piper TTS virtual environment..."
  python3 -m venv "$VENV_DIR"
  "$VENV_DIR/bin/pip" install --quiet piper-tts
  echo "✓ Piper TTS installed"
else
  echo "✓ Piper TTS already installed"
fi

# 4. Download voice model if not already present
VOICE_MODEL="$VOICES_DIR/en_US-lessac-high.onnx"
if [ ! -f "$VOICE_MODEL" ]; then
  echo "Downloading voice model (en_US-lessac-high, ~108 MB)..."
  VOICE_URL="https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/lessac/high/en_US-lessac-high.onnx"
  CONFIG_URL="https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/lessac/high/en_US-lessac-high.onnx.json"
  curl -L --progress-bar -o "$VOICE_MODEL" "$VOICE_URL"
  curl -L --silent -o "${VOICE_MODEL}.json" "$CONFIG_URL"
  echo "✓ Voice model downloaded"
else
  echo "✓ Voice model already present"
fi

# 5. Register hook in settings.json
if [ ! -f "$SETTINGS" ]; then
  echo '{}' > "$SETTINGS"
fi

python3 - <<EOF
import json, sys

settings_path = "$SETTINGS"
hook_cmd = "$HOOKS_DIR/speak.sh"

with open(settings_path) as f:
    settings = json.load(f)

hooks = settings.setdefault("hooks", {})
stop_hooks = hooks.setdefault("Stop", [])

# Check if already registered
for hook in stop_hooks:
    if isinstance(hook, dict):
        for matcher in hook.get("hooks", []):
            if hook_cmd in matcher.get("command", ""):
                print("✓ Hook already registered in settings.json")
                sys.exit(0)

# Add the hook
stop_hooks.append({
    "matcher": "",
    "hooks": [{"type": "command", "command": hook_cmd}]
})

with open(settings_path, "w") as f:
    json.dump(settings, f, indent=2)

print("✓ Hook registered in settings.json")
EOF

echo ""
echo "=== Installation complete! ==="
echo ""
echo "Usage:"
echo "  Auto-speak ON:   touch ~/.claude/speak_on"
echo "  Auto-speak OFF:  rm ~/.claude/speak_on"
echo "  Read last:       bash ~/.claude/hooks/read_last.sh"
echo ""
echo "Or double-click toggle.command / read.command on your Desktop."
