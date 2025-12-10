#!/bin/zsh

# Run Fathom UI tests in the iOS Simulator

set -e

SCHEME="Fathom"
PROJECT="Fathom.xcodeproj"
SIMULATOR="iPhone 16"
SCRIPT_DIR="$(dirname "$0")"
BUILD_LOG="$SCRIPT_DIR/xcodebuild.log"

echo "Using simulator: $SIMULATOR"

if ! command -v xcbeautify &> /dev/null; then
    echo "Installing xcbeautify..."
    brew install xcbeautify
fi

echo "Booting simulator..."
xcrun simctl boot "$SIMULATOR" 2>/dev/null || true

echo "Running UI tests..."
echo "Build log: $BUILD_LOG"
xcodebuild \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -sdk iphonesimulator \
    -destination "platform=iOS Simulator,name=$SIMULATOR" \
    -only-testing:FathomUITests \
    test 2>&1 | tee "$BUILD_LOG" | xcbeautify

echo "Done!"
