#!/bin/zsh
# shellcheck shell=bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$SCRIPT_DIR/common.sh"
cd "$REPO_ROOT"

log_info "Initializing rbenv (if available)..."
if command -v rbenv >/dev/null 2>&1; then
  eval "$(rbenv init -)"
fi

log_info "Fetching Fastlane app-specific password from keychain..."
KEYCHAIN_SERVICE="fastlane_app_specific_password"
KEYCHAIN_ACCOUNT="${PERSONAL_APPLE_ID:?PERSONAL_APPLE_ID environment variable is required}"
FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD=$(security find-generic-password \
  -w \
  -s "$KEYCHAIN_SERVICE" \
  -a "$KEYCHAIN_ACCOUNT")
export FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD

# Determine which lane to run (default: release for App Store)
LANE="${1:-release}"
shift 2>/dev/null || true

log_info "Running Fastlane $LANE lane..."
bundle exec fastlane "$LANE" "$@"
