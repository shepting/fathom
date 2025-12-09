#!/bin/bash

# Build and run Fathom in the iOS Simulator

set -e

SCHEME="Fathom"
PROJECT="Fathom.xcodeproj"
SIMULATOR="iPhone 16"
BUNDLE_ID="com.hepting.Fathom"
# Use /tmp for build output to avoid iCloud extended attributes issues
BUILD_DIR="/tmp/fathom-build"
LOG_FILE="$(dirname "$0")/simulator.log"

echo "Cleaning extended attributes (iCloud workaround)..."
xattr -cr . 2>/dev/null || true

echo "Building $SCHEME..."
xcodebuild -project "$PROJECT" \
    -scheme "$SCHEME" \
    -sdk iphonesimulator \
    -destination "platform=iOS Simulator,name=$SIMULATOR" \
    -derivedDataPath "$BUILD_DIR" \
    build

echo "Booting simulator..."
xcrun simctl boot "$SIMULATOR" 2>/dev/null || true

echo "Installing app..."
APP_PATH=$(find "$BUILD_DIR" -name "*.app" -type d | head -1)
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
