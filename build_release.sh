#!/usr/bin/env bash
set -euo pipefail

# Ensure rbenv shims (Ruby 3.4.4 + bundler) are available if rbenv is installed.
if command -v rbenv >/dev/null 2>&1; then
  eval "$(rbenv init -)"
fi

# Fetch the Fastlane app-specific password from the login keychain.
KEYCHAIN_SERVICE="fastlane_app_specific_password"
KEYCHAIN_ACCOUNT="shepting@gmail.com"
FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD=$(security find-generic-password \
  -w \
  -s "$KEYCHAIN_SERVICE" \
  -a "$KEYCHAIN_ACCOUNT")
export FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD

# Run the standard TestFlight upload lane (build + upload).
bundle exec fastlane beta "$@"
