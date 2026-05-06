# App Store Privacy Guidance

Last reviewed: 2026-05-06

This recommendation is based on the current codebase and should be verified in App Store Connect before submission.

## Current Code Signals

- local bookmarks only
- no sign-in
- no ads SDK
- no tracking framework
- NASA search requests go directly to NASA services
- Firebase Analytics is used for screen views and interaction events
- Firebase Crashlytics is used for crash diagnostics on non-web builds
- Firebase Remote Config and Cloud Firestore are used for app configuration and public content
- Firebase Cloud Messaging is used for optional notifications

## Conservative Review Points

Consider whether free-form NASA search queries should be disclosed as user content sent off device to a third party service provider or partner. The code does not send raw NASA search text to Firebase Analytics, but NASA receives the query to return search results.

Also review Firebase Analytics, Crashlytics, Messaging, Remote Config, and Firestore disclosures against the exact Firebase collection settings enabled in production.

## Suggested In-App Position

- data stored on device: bookmarks only
- data sent to deliver core function: NASA search and content requests
- data sent for operations: Firebase analytics events, crash diagnostics, optional messaging, remote config, and public app content reads
- no tracking across apps or websites for advertising
- no developer-controlled profile, contact, or financial data collection

## Submission Reminder

You still need:

- a public privacy policy URL
- support URL
- App Privacy answers in App Store Connect
