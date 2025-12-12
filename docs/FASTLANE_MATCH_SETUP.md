# Fastlane Match Setup Guide

This guide walks you through setting up `fastlane match` for code signing in CI/CD (GitHub Actions).

## Overview

Fastlane Match stores your certificates and provisioning profiles in a private Git repository, encrypted with a password. This allows CI/CD systems to access them securely.

## Prerequisites

- Apple Developer account
- Admin access to your Apple Developer team
- Private GitHub repository: `shepting/certificates`

## Step 1: Local Setup (One-time)

### 1.1 Generate Personal Access Token (PAT)

1. Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token (classic)"
3. Name: `Fastlane Match - Certificates Repo`
4. Select scopes:
   - ✅ `repo` (Full control of private repositories)
5. Click "Generate token"
6. **Save this token** - you'll need it for the next steps

### 1.2 Create Base64 Authorization Token

Match needs a base64-encoded token for Git authentication:

```bash
echo -n "your-github-username:YOUR_PERSONAL_ACCESS_TOKEN" | base64
```

**Save this output** - this is your `MATCH_GIT_BASIC_AUTHORIZATION` secret.

### 1.3 Choose a Match Password

Create a strong password to encrypt your certificates. This will be your `MATCH_PASSWORD` secret.

```bash
# Generate a random password
openssl rand -base64 32
```

**Save this password** - you'll need it every time match accesses the certificates.

### 1.4 Initialize Match (First Time Only)

From your Fathom project directory:

```bash
cd /path/to/fathom
bundle exec fastlane match init
```

This creates the `Matchfile` (already done in this setup).

### 1.5 Generate and Upload Certificates

```bash
# For App Store distribution
bundle exec fastlane match appstore

# When prompted:
# - Enter the MATCH_PASSWORD you created
# - Confirm your Apple ID: $PERSONAL_APPLE_ID
```

This will:
1. Connect to your Apple Developer account
2. Generate certificates and provisioning profiles (if needed)
3. Encrypt them with your password
4. Upload to the `shepting/certificates` repo

## Step 2: GitHub Secrets Configuration

Add these secrets to your GitHub repository settings:

Go to: `https://github.com/shepting/fathom/settings/secrets/actions`

### Required Secrets

| Secret Name | Value | Description |
|------------|-------|-------------|
| `PERSONAL_APPLE_ID` | your-apple-id@example.com | Your Apple ID |
| `PERSONAL_FASTLANE_ITC_TEAM_ID` | 123456789 | Your App Store Connect Team ID |
| `FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD` | abcd-efgh-ijkl-mnop | App-specific password from appleid.apple.com |
| `MATCH_PASSWORD` | (from Step 1.3) | Password to decrypt certificates |
| `MATCH_GIT_BASIC_AUTHORIZATION` | (from Step 1.2) | Base64 encoded GitHub PAT |
| `MATCH_KEYCHAIN_PASSWORD` | any-password | Temporary keychain password for CI |

### How to Find Your Team ID

```bash
# List your teams
bundle exec fastlane fastlane-credentials show
```

Or find it in App Store Connect:
1. Go to https://appstoreconnect.apple.com
2. Click your name → View Membership
3. Team ID is listed there

### How to Create App-Specific Password

1. Go to https://appleid.apple.com
2. Sign in → Security → App-Specific Passwords
3. Click "Generate Password"
4. Label: `Fastlane CI/CD`
5. Copy the generated password (format: `xxxx-xxxx-xxxx-xxxx`)

## Step 3: Verify Setup

### 3.1 Test Locally

```bash
# This should succeed without prompting for password
# (assuming you ran match appstore earlier)
bundle exec fastlane match appstore --readonly
```

### 3.2 Test in GitHub Actions

1. Go to Actions tab: https://github.com/shepting/fathom/actions/workflows/release.yml
2. Click "Run workflow"
3. Select `build` lane (just builds, doesn't upload)
4. Click "Run workflow"

If successful, the build should complete and upload `Fathom.ipa` as an artifact.

## Step 4: Update Certificates (When Needed)

### Renew Expired Certificates

```bash
bundle exec fastlane match appstore --force_for_new_devices
```

### Add New Devices

```bash
# Register device on Apple Developer Portal first, then:
bundle exec fastlane match appstore --force_for_new_devices
```

### Rotate Certificates

```bash
bundle exec fastlane match nuke appstore  # WARNING: Deletes all certificates!
bundle exec fastlane match appstore       # Creates new ones
```

## Troubleshooting

### "Could not decrypt the repo"

- ❌ Wrong `MATCH_PASSWORD`
- ✅ Double-check the password in GitHub Secrets

### "Authentication failed"

- ❌ Invalid or expired Personal Access Token
- ✅ Regenerate PAT and update `MATCH_GIT_BASIC_AUTHORIZATION`

### "No code signing identity found"

- ❌ Certificates not generated or expired
- ✅ Run `bundle exec fastlane match appstore` locally

### "Provisioning profile doesn't match"

- ❌ Bundle ID mismatch or profile expired
- ✅ Check Matchfile has correct `app_identifier`
- ✅ Run `bundle exec fastlane match appstore --force`

## Security Best Practices

1. ✅ **Use a strong MATCH_PASSWORD** - 32+ characters, randomly generated
2. ✅ **Rotate PATs periodically** - Set expiration on GitHub tokens
3. ✅ **Limit PAT scope** - Only grant `repo` access, nothing else
4. ✅ **Keep certificates repo private** - Never make it public
5. ✅ **Audit access** - Regularly review who has access to certificates repo
6. ✅ **Use readonly mode in CI** - Prevents CI from modifying certificates

## Alternative: App Store Connect API Key

For better security, consider using an API key instead of password authentication:

1. Create API key in App Store Connect
2. Download `AuthKey_XXXXXX.p8` file
3. Add to repo as `fastlane/api_key.json`
4. Update Matchfile: uncomment `api_key_path` line

## References

- [Fastlane Match Documentation](https://docs.fastlane.tools/actions/match/)
- [Codesigning Guide](https://docs.fastlane.tools/codesigning/getting-started/)
- [GitHub Actions iOS Signing](https://docs.github.com/en/actions/deployment/deploying-xcode-applications/installing-an-apple-certificate-on-macos-runners-for-xcode-development)
