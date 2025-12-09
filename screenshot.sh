#!/bin/bash

# Take a screenshot of the iOS Simulator

SIMULATOR="iPhone 16"
OUTPUT_PATH="/tmp/simulator-screenshot.png"

# Wait a moment for the app to render
sleep 2

echo "Taking screenshot..."
xcrun simctl io "$SIMULATOR" screenshot "$OUTPUT_PATH"

echo "Screenshot saved to $OUTPUT_PATH"
