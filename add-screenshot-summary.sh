#!/bin/bash

# Add screenshot to GitHub Actions job summary

SCREENSHOT_PATH="${1:-/tmp/simulator-screenshot.png}"

if [ ! -f "$SCREENSHOT_PATH" ]; then
    echo "Screenshot not found: $SCREENSHOT_PATH"
    exit 1
fi

if [ -z "$GITHUB_STEP_SUMMARY" ]; then
    echo "Not running in GitHub Actions"
    exit 0
fi

echo "## Simulator Screenshot" >> "$GITHUB_STEP_SUMMARY"
echo "" >> "$GITHUB_STEP_SUMMARY"
echo "<details><summary>Screenshot</summary>" >> "$GITHUB_STEP_SUMMARY"
echo "" >> "$GITHUB_STEP_SUMMARY"
echo "![Screenshot](data:image/png;base64,$(base64 -i "$SCREENSHOT_PATH"))" >> "$GITHUB_STEP_SUMMARY"
echo "" >> "$GITHUB_STEP_SUMMARY"
echo "</details>" >> "$GITHUB_STEP_SUMMARY"
