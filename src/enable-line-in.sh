#!/bin/sh
# enable-line-in.sh — forward Move's line-in audio to norns scripts.
# Only touch this when you actually have a source plugged into line-in:
# left floating, the input picks up loud intermittent noise (see
# standalone_norns.c for why this isn't auto-detected). Takes effect
# within ~1s without needing to restart norns.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
touch "$SCRIPT_DIR/line_in_enabled"
echo "Line-in enabled."
