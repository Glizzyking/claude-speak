#!/bin/bash
# Reads the last saved Claude response aloud using Kokoro TTS (voice: af_aoede)

KOKORO="$HOME/.claude/kokoro-venv/bin/kokoro-tts"
MODEL="$HOME/.claude/kokoro-models/kokoro-v1.0.onnx"
VOICES="$HOME/.claude/kokoro-models/voices-v1.0.bin"
LAST_RESPONSE="$HOME/.claude/last_response.txt"
TMP_WAV="/tmp/claude_read_$$.wav"
TMP_TXT="/tmp/claude_read_$$.txt"

if [ ! -f "$LAST_RESPONSE" ]; then
  echo "No response saved yet."
  exit 1
fi

cp "$LAST_RESPONSE" "$TMP_TXT"

"$KOKORO" "$TMP_TXT" "$TMP_WAV" \
  --voice af_aoede \
  --model "$MODEL" \
  --voices "$VOICES" 2>/dev/null && afplay "$TMP_WAV"

rm -f "$TMP_WAV" "$TMP_TXT"
