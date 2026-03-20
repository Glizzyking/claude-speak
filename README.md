# Claude Speak

Local text-to-speech for Claude Code using [Piper TTS](https://github.com/rhasspy/piper). All audio is generated on-device — no API calls, no cloud.

## What it does

- **Auto-speak**: After every Claude response, the text is read aloud automatically
- **On-demand read**: Read the last response whenever you want
- **Smart cleaning**: Code blocks and markdown formatting are stripped before speaking

## Quick Setup

```bash
bash install.sh
```

This will:
1. Install Piper TTS into `~/.claude/piper-venv/`
2. Download the `en_US-lessac-high` voice model (~108 MB) to `~/.claude/piper-voices/`
3. Copy hook scripts to `~/.claude/hooks/`
4. Register the hook in `~/.claude/settings.json`

> **Requires**: Python 3, macOS (uses `afplay` for playback)

## Manual Setup

Copy scripts to your Claude hooks directory:
```bash
cp speak.sh ~/.claude/hooks/speak.sh
cp read_last.sh ~/.claude/hooks/read_last.sh
chmod +x ~/.claude/hooks/speak.sh ~/.claude/hooks/read_last.sh
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

## Usage

| Action | Command |
|---|---|
| Enable auto-speak | `touch ~/.claude/speak_on` |
| Disable auto-speak | `rm ~/.claude/speak_on` |
| Read last response | `bash ~/.claude/hooks/read_last.sh` |

**Desktop shortcuts** (double-click):
- `toggle.command` — toggles auto-speak on/off with a notification
- `read.command` — reads the last Claude response aloud

## Files

| File | Purpose |
|---|---|
| `speak.sh` | Stop hook — extracts, cleans, and speaks Claude responses |
| `read_last.sh` | Reads the last saved response on demand |
| `toggle.command` | Double-clickable macOS toggle |
| `read.command` | Double-clickable read trigger |
| `install.sh` | One-shot installer |

## Voice Model

Uses `en_US-lessac-high` — a high-quality US English neural voice at 22050 Hz. Other voices are available at [rhasspy/piper-voices](https://huggingface.co/rhasspy/piper-voices).

To swap voices, update the `MODEL` variable in `speak.sh` and `read_last.sh`.
