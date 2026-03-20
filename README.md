# Claude Speak

Local on-demand text-to-speech for Claude Code using [Piper TTS](https://github.com/rhasspy/piper). All audio is generated on-device — no API calls, no cloud.

## How it works

Claude never speaks automatically. After any conversation, just run:

```bash
speak
```

That's it. The last response is read aloud.

## Quick Setup

```bash
bash install.sh
```

This will:
1. Install Piper TTS into `~/.claude/piper-venv/`
2. Download the `en_US-lessac-high` voice model (~108 MB) to `~/.claude/piper-voices/`
3. Copy hook scripts to `~/.claude/hooks/`
4. Register the Stop hook in `~/.claude/settings.json` (saves text silently after each response)
5. Install the `speak` command to `~/.local/bin/speak`

> **Requires**: Python 3, macOS (uses `afplay` for playback), `~/.local/bin` in your PATH

## Manual Setup

```bash
# Hook (saves response text silently)
cp speak.sh ~/.claude/hooks/speak.sh
chmod +x ~/.claude/hooks/speak.sh

# CLI command
cp speak-cli ~/.local/bin/speak
chmod +x ~/.local/bin/speak
```

Add to `~/.claude/settings.json`:
```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [{ "type": "command", "command": "~/.claude/hooks/speak.sh" }]
      }
    ]
  }
}
```

## Files

| File | Purpose |
|---|---|
| `speak.sh` | Stop hook — silently extracts and saves each Claude response to `~/.claude/last_response.txt` |
| `speak-cli` | Terminal command — reads the saved response aloud (install as `~/.local/bin/speak`) |
| `read_last.sh` | Alias for speak-cli, used by the `/read` slash command |
| `toggle.command` | Double-clickable toggle for legacy auto-speak mode |
| `read.command` | Double-clickable trigger to read last response |
| `install.sh` | One-shot installer |

## Voice Model

Uses `en_US-lessac-high` — a high-quality US English neural voice at 22050 Hz. Other voices available at [rhasspy/piper-voices](https://huggingface.co/rhasspy/piper-voices).

To swap voices, update the `MODEL` variable in `speak-cli` and `read_last.sh`.
