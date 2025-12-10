#!/bin/zsh
# shellcheck shell=bash

# Take a screenshot of the iOS Simulator

set -euo pipefail  # Fail on errors

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/common.sh"

OUTPUT_PATH="/tmp/simulator-screenshot.png"

# Find the booted simulator UUID
SIMULATOR=$(xcrun simctl list devices booted | grep -E "\([A-F0-9-]+\)" | head -1 | sed 's/.*(\([A-F0-9-]*\)).*/\1/')

if [ -z "$SIMULATOR" ]; then
    echo "Error: No booted simulator found"
    xcrun simctl list devices booted
    exit 1
fi

echo "Using booted simulator: $SIMULATOR"

# Wait for the app to render
sleep 3

echo "Taking screenshot..."

# Try to take screenshot, with retries for CI environments
for i in 1 2 3; do
    if xcrun simctl io "$SIMULATOR" screenshot "$OUTPUT_PATH" 2>/dev/null; then
        echo "Screenshot saved to $OUTPUT_PATH"
        exit 0
    fi
    echo "Attempt $i failed, waiting..."
    sleep 2
done

# If screenshot still fails, try using screencapture as fallback
echo "simctl screenshot failed, trying screencapture fallback..."
screencapture -x "$OUTPUT_PATH" 2>/dev/null || true

if [ -s "$OUTPUT_PATH" ]; then
    echo "Screenshot saved to $OUTPUT_PATH (via screencapture)"
else
    echo "Warning: Could not capture screenshot"
    # Create a placeholder so the upload doesn't fail
    echo "Screenshot capture failed in CI" > "$OUTPUT_PATH.txt"
fi
