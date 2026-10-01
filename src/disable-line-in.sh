#!/bin/sh
# disable-line-in.sh — stop forwarding Move's line-in audio to norns
# scripts (the default). Use this when nothing is plugged into line-in,
# to avoid floating-input noise reaching scripts with input gain/feedback.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
rm -f "$SCRIPT_DIR/line_in_enabled"
echo "Line-in disabled."
