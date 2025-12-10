#!/bin/zsh
# shellcheck shell=bash

set -euo pipefail  # Fail on errors

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$SCRIPT_DIR/common.sh"

export APPSTORE_SCREENSHOT_MODE="${APPSTORE_SCREENSHOT_MODE:-1}"

OUTPUT_DIR="$REPO_ROOT/fastlane/screenshots/en-US"

typeset -A DEVICES=(
  ["iPhone 11 Pro Max"]="iPhone-65-1.png"
  ["iPad Pro 13-inch (M4)"]="iPad-13-1.png"
)
mkdir -p "$OUTPUT_DIR"

shutdown_all() {
  xcrun simctl shutdown all >/dev/null 2>&1 || true
}

shutdown_all

# shellcheck disable=SC2296,SC2066
for device in "${(@k)DEVICES}"; do
  echo "==== Capturing screenshots for $device ===="
  "$SCRIPT_DIR/run.sh" "$device"
  sleep 20  # Wait for the app to fully load
  target_file="$OUTPUT_DIR/${DEVICES[$device]}"
  "$SCRIPT_DIR/screenshot.sh" "$target_file"
  echo "Saved App Store screenshot to $target_file"

  shutdown_all
  echo
done

echo "All screenshots saved under $OUTPUT_DIR"
