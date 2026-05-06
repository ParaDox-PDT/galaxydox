# Google Play Data Safety Guidance

Last reviewed: 2026-05-06

This document is a conservative recommendation based on the current codebase.

## Developer-Collected Data

Current code suggests:

- no account data collection
- no advertising ID usage
- Firebase Analytics is present for screen views and interaction events
- Firebase Crashlytics is present for crash diagnostics on non-web builds
- Firebase Cloud Messaging is present for optional notifications
- Firebase Remote Config and Cloud Firestore are used for app configuration and public read-only content
- local bookmarks and onboarding/notification preferences stay on-device

## Data Sent Off Device To Deliver Core Features

The app sends requests to NASA-operated services for content loading.

Conservative items to review in Play Console:

- Search queries: user-provided text used to search NASA media
- App activity: screen views and feature interaction events sent through Firebase Analytics
- App info and performance: crash diagnostics sent through Firebase Crashlytics
- Device or other identifiers: Firebase installation/messaging identifiers and provider-side request logs
- Messages/notifications: FCM topic subscription and notification delivery when the user grants notification permission

The current code no longer sends raw NASA search text to Firebase Analytics. NASA search text is still sent to NASA because it is required to perform the search.

## Recommended Position To Verify With Legal/Product Owner

- Data is not sold.
- Data is transmitted to NASA only to fulfill user-requested content loading.
- Firebase receives analytics, crash, messaging, remote config, and public content access data as described above.
- Bookmarks stay on-device and are not shared with the developer.

## Store Requirement Reminder

Google Play requires a valid privacy policy link for apps that handle user data or request sensitive permissions. Verify that the Play Console privacy policy URL matches the current policy before each release.
