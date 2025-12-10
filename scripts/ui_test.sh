#!/bin/zsh
# shellcheck shell=bash

# Run Fathom UI tests in the iOS Simulator

set -euo pipefail  # Fail on errors

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$SCRIPT_DIR/common.sh"

SCHEME="Fathom"
PROJECT="Fathom.xcodeproj"
SIMULATOR="iPhone 16"
BUILD_LOG="$REPO_ROOT/xcodebuild.log"

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
