# Google Play Data Safety Guidance

Last reviewed: 2026-03-23

This document is a conservative recommendation based on the current codebase.

## Developer-Collected Data

Current code suggests:

- no account data collection
- no advertising ID usage
- no analytics SDK
- no crash reporting SDK
- no developer-controlled backend

## Data Sent Off Device To Deliver Core Features

The app does send requests to NASA-operated services for content loading.

Conservative items to review in Play Console:

- Search queries: user-provided text used to search NASA media
- App activity or in-app interactions: only if you decide NASA search terms should be disclosed this way
- Device or other identifiers: only if your legal/privacy review determines NASA-hosted request logs should be treated as shared data for your disclosure

## Recommended Position To Verify With Legal/Product Owner

- Data is not collected by the developer for sale or analytics.
- Data is transmitted to NASA only to fulfill user-requested content loading.
- Bookmarks stay on-device and are not shared with the developer.

## Store Requirement Reminder

Google Play also requires a valid privacy policy link for apps that handle user data or request sensitive permissions. Publish a real URL before release.
