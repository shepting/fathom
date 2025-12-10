# Fathom 🔗

[![CI](https://github.com/shepting/fathom/actions/workflows/ci.yml/badge.svg)](https://github.com/shepting/fathom/actions/workflows/ci.yml)
![GitHub release](https://img.shields.io/github/release/shepting/fathom.svg)
![GitHub top language](https://img.shields.io/github/languages/top/shepting/fathom.svg)
![](https://img.shields.io/badge/Platform-iOS%2015.6%2B-lightgrey.svg)
[![License](https://img.shields.io/github/license/shepting/fathom.svg)](https://github.com/shepting/fathom/blob/master/LICENSE)
[![Twitter](https://img.shields.io/badge/Twitter-%40stevenhepting-blue.svg)](https://twitter.com/stevenhepting)

[![](Resources/App_Store_Badge.svg)](https://itunes.apple.com/us/app/fathom-universal-link-testing/id1195310358?l=zh&ls=1&mt=8&ct=README)

Fathom made Universal Links testing easier. It fetches and parses apple-app-site-association file for you to quickly check whether Universal Links are working.

## Demo

Add websites, download related apps, test Universal Links, and customize test links.

![Demo of user add IMDb to Fathom and test its Universal Links.](Resources/demo.gif)

## Features

| | Features |
| --- | --- |
| 😇 | Open source iOS project written in Swift 5 |
| 📲 | Fetch and parse apple-app-site-association(AASA) files |
| 💡 | App Store links and metadata |
| 🚀 | List all Universal Link paths. One-tap to test! |
| 🛠️ | Customize test links |
| 🤝 | Link to other validation tools like Branch.io's [AASA Validator](https://branch.io/resources/aasa-validator/) or Apple's [App Search API Validation Tool](https://search.developer.apple.com/appsearch-validation-tool/) | 
| 🆓 | Free without ads |
| 🚫 | No third-party tracking or analytics |

## AASA Format Support

Fathom supports both legacy and modern AASA (apple-app-site-association) formats:

### Legacy Format (Pre-iOS 13)
```json
{
  "applinks": {
    "apps": [],
    "details": [{
      "appID": "TEAMID.BUNDLEID",
      "paths": ["/path/*", "NOT /excluded/*"]
    }]
  }
}
```

### Modern Format (iOS 13+)
Introduced at WWDC 2019 ([What's New in Universal Links](https://developer.apple.com/videos/play/wwdc2019/717/)) with enhanced URL component matching:
```json
{
  "applinks": {
    "details": [{
      "appIDs": ["TEAMID.BUNDLEID"],
      "components": [{
        "/": "/path/*",
        "?": {"param": "value*"},
        "#": "fragment"
      }]
    }]
  }
}
```

Key differences in the modern format:
- `apps` array no longer required
- `appIDs` (plural) supports multiple apps per rule
- `components` replaces `paths` with granular matching for path (`/`), query (`?`), and fragment (`#`)
- `exclude` key for explicit exclusion rules

## Naming
```
"fathom" == "link".reversed()
```

## Install

[![](Resources/App_Store_Badge.svg)](https://itunes.apple.com/us/app/fathom-universal-link-testing/id1195310358?l=zh&ls=1&mt=8&ct=README)

Download the official release version from [App Store](https://itunes.apple.com/us/app/fathom-universal-link-testing/id1195310358?l=zh&ls=1&mt=8&ct=README).

Or, you can install this open source app with the following steps:

1. Clone the repo on [GitHub](https://github.com/shepting/fathom)
2. Open the project with Xcode 16 or above
3. Change bundle ID to something like `com.yourcompany.Fathom`
4. Build and run on your iOS devices

## Contribution

- Feedback and [issues](https://github.com/shepting/fathom/issues/new) are welcome.
