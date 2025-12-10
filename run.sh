#!/bin/bash

# Build and run Fathom in the iOS Simulator

set -e

SCHEME="Fathom"
PROJECT="Fathom.xcodeproj"
BUNDLE_ID="com.hepting.Fathom"
DEFAULT_SIMULATOR="iPhone 17"

if [ -n "$1" ]; then
    SIMULATOR="$1"
else
    SIMULATOR="${SIMULATOR:-$DEFAULT_SIMULATOR}"
fi
SCRIPT_DIR="$(dirname "$0")"
BUILD_LOG="$SCRIPT_DIR/xcodebuild.log"
BUILD_DIR="${DERIVED_DATA_PATH:-$HOME/Library/Developer/Xcode/DerivedData/Fathom-CLI}"
LOG_FILE="$SCRIPT_DIR/simulator.log"

echo "Using simulator: $SIMULATOR"

if ! command -v xcbeautify &> /dev/null; then
    echo "Installing xcbeautify..."
    brew install xcbeautify
fi

echo "Building $SCHEME..."
echo "Build log: $BUILD_LOG"
mkdir -p "$BUILD_DIR"

xcodebuild -project "$PROJECT" \
    -scheme "$SCHEME" \
    -sdk iphonesimulator \
    -destination "platform=iOS Simulator,name=$SIMULATOR" \
    -derivedDataPath "$BUILD_DIR" \
    build 2>&1 | tee "$BUILD_LOG" | xcbeautify

echo "Booting simulator..."
xcrun simctl boot "$SIMULATOR" 2>/dev/null || true

echo "Installing app..."
APP_PATH=$(find "$BUILD_DIR/Build/Products" -name "*.app" -type d | head -1)
xcrun simctl install "$SIMULATOR" "$APP_PATH"

# Kill any existing app or log process
pkill -f "simctl launch.*console" 2>/dev/null || true

# Clear previous logs
> "$LOG_FILE"

echo "Launching app with console output (writing to $LOG_FILE)..."
xcrun simctl launch --console-pty "$SIMULATOR" "$BUNDLE_ID" >> "$LOG_FILE" 2>&1 &
APP_PID=$!

echo "Opening Simulator..."
open -a Simulator

# Give the app a moment to start and log initial messages
sleep 2

echo "Done!"
echo "Logs are being written to: $LOG_FILE"
echo "Follow logs in real-time with: tail -f $LOG_FILE"
