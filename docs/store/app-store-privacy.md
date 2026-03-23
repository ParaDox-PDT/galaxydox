# App Store Privacy Guidance

Last reviewed: 2026-03-23

This recommendation is based on the current codebase and should be verified in App Store Connect before submission.

## Current Code Signals

- local bookmarks only
- no sign-in
- no ads SDK
- no analytics SDK
- no tracking framework
- NASA search requests go directly to NASA services

## Conservative Review Points

Consider whether free-form NASA search queries should be disclosed as user content sent off device to a third party service provider or partner. The code does not show developer-side retention, but App Store disclosures should still reflect your actual operational setup and privacy policy.

## Suggested In-App Position

- data stored on device: bookmarks only
- data sent to deliver core function: NASA search and content requests
- no tracking across apps or websites
- no developer-controlled profile, contact, or financial data collection

## Submission Reminder

You still need:

- a public privacy policy URL
- support URL
- App Privacy answers in App Store Connect
