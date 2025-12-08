#!/bin/bash

# Build and run Fathom in the iOS Simulator

set -e

SCHEME="Fathom"
PROJECT="Fathom.xcodeproj"
SIMULATOR="iPhone 16"
BUNDLE_ID="com.hepting.Fathom"
# Use /tmp for build output to avoid iCloud extended attributes issues
BUILD_DIR="/tmp/fathom-build"

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

echo "Launching app..."
xcrun simctl launch "$SIMULATOR" "$BUNDLE_ID"

echo "Opening Simulator..."
open -a Simulator

echo "Done!"
