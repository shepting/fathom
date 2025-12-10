#!/bin/zsh
# shellcheck shell=bash

# Build and run Fathom in the iOS Simulator

set -euo pipefail  # Fail on errors

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$SCRIPT_DIR/common.sh"

SCHEME="Fathom"
PROJECT="Fathom.xcodeproj"
BUNDLE_ID="com.hepting.Fathom"
DEFAULT_SIMULATOR="iPhone 17"

if [[ $# -gt 0 ]]; then
    SIMULATOR="$1"
else
    SIMULATOR="${SIMULATOR:-$DEFAULT_SIMULATOR}"
fi
BUILD_LOG="$REPO_ROOT/xcodebuild.log"
BUILD_DIR="${DERIVED_DATA_PATH:-$HOME/Library/Developer/Xcode/DerivedData/Fathom-CLI}"
LOG_FILE="$REPO_ROOT/simulator.log"

echo "Using simulator: $SIMULATOR"

if ! command -v xcbeautify &> /dev/null; then
    echo "Installing xcbeautify..."
    brew install xcbeautify
fi

echo "Building $SCHEME..."
echo "Build log: $BUILD_LOG"
mkdir -p "$BUILD_DIR"

system_and_log "xcodebuild -project \"$PROJECT\" \
    -scheme \"$SCHEME\" \
    -sdk iphonesimulator \
    -destination \"platform=iOS Simulator,name=$SIMULATOR\" \
    -derivedDataPath \"$BUILD_DIR\" \
    build 2>&1 | tee \"$BUILD_LOG\" | xcbeautify"

echo "Booting simulator..."
system_and_log "xcrun simctl boot \"$SIMULATOR\" 2>/dev/null" || true

echo "Waiting for simulator to finish booting..."
system_and_log "xcrun simctl bootstatus \"$SIMULATOR\" -b"

echo "Installing app..."
APP_PATH=$(find "$BUILD_DIR/Build/Products" -name "*.app" -type d | head -1)
system_and_log "xcrun simctl install \"$SIMULATOR\" \"$APP_PATH\""

# Kill any existing app or log process
pkill -f "simctl launch.*console" 2>/dev/null || true

# Clear previous logs
> "$LOG_FILE"

echo "Launching app with console output (writing to $LOG_FILE)..."
system_and_log "xcrun simctl launch --console-pty \"$SIMULATOR\" \"$BUNDLE_ID\" >> \"$LOG_FILE\" 2>&1 &"
APP_PID=$!
# Detach so the app isn't killed when this script exits
disown "$APP_PID" 2>/dev/null || true

echo "Opening Simulator..."
system_and_log "open -a Simulator"

# Give the app a moment to start and log initial messages
sleep 2

echo "Done!"
echo "Logs are being written to: $LOG_FILE"
echo "Follow logs in real-time with: tail -f $LOG_FILE"
