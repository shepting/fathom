#!/bin/zsh
# shellcheck shell=bash

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT_DIR="$PROJECT_DIR/fastlane/screenshots/en-US"
SCREENSHOT_PATH="/tmp/simulator-screenshot.png"

typeset -A DEVICES=(
  ["iPhone 11 Pro Max"]="iPhone-65-1.png"
  ["iPad Pro 13-inch (M4)"]="iPad-13-1.png"
)
mkdir -p "$OUTPUT_DIR"

slugify() {
  echo "$1" | tr ' ' '-' | tr '()' '__' | tr -cd 'A-Za-z0-9_\n-'
}

shutdown_all() {
  xcrun simctl shutdown all >/dev/null 2>&1 || true
}

shutdown_all

for device in "${(@k)DEVICES}"; do
  echo "==== Capturing screenshots for $device ===="
  "$PROJECT_DIR/run.sh" "$device"
  sleep 20  # Wait for the app to fully load
  "$PROJECT_DIR/screenshot.sh"

  if [[ ! -s "$SCREENSHOT_PATH" ]]; then
    echo "Failed to capture screenshot for $device" >&2
    exit 1
  fi

  slug=$(slugify "$device")
  device_file="$OUTPUT_DIR/${slug}.png"
  cp "$SCREENSHOT_PATH" "$device_file"
  echo "Saved raw screenshot to $device_file"

  if [[ -n "${DEVICES[$device]:-}" ]]; then
    cp "$SCREENSHOT_PATH" "$OUTPUT_DIR/${DEVICES[$device]}"
    echo "Saved App Store screenshot to $OUTPUT_DIR/${DEVICES[$device]}"
  fi

  shutdown_all
  echo
done

echo "All screenshots saved under $OUTPUT_DIR"
