# GalaxyDox Privacy Policy

Last updated: 2026-05-06

## Summary

GalaxyDox is a Flutter application for browsing NASA imagery, stories, and mission data.

The app is designed to minimize data collection where possible:

- no account creation
- no advertising SDKs
- no social login
- no location tracking
- bookmarks stored locally on-device
- Firebase is used for analytics, crash reporting, remote configuration, Firestore-hosted public content, and optional push notifications

## Data The App Uses

### NASA content requests

When you open APOD, Mars Rover, Near-Earth Object, EPIC Earth, or NASA media search screens, the app sends requests directly to NASA-operated endpoints so content can load.

This may include:

- your search query text when you use NASA search
- standard network information required to complete requests, such as IP address and device/network metadata processed by NASA or hosting infrastructure

GalaxyDox does not proxy these requests through developer-controlled servers.

### Firebase services

GalaxyDox uses Firebase to operate and improve the app:

- Firebase Analytics for screen views and app interaction events
- Firebase Crashlytics for crash diagnostics on non-web builds
- Firebase Cloud Messaging for optional notifications after permission is granted
- Firebase Remote Config for feature/configuration values
- Cloud Firestore for public read-only app content such as planets, wallpapers, and notifications

GalaxyDox does not send free-form NASA search text to Firebase Analytics. Crash reports may include app version, device/OS details, diagnostic logs, and stack traces needed to investigate failures. Push notification delivery may involve a Firebase installation or messaging token; the current app code uses it for topic subscription and does not store it in a developer-controlled user profile.

### Local bookmarks

If you bookmark content, the bookmark identifiers are stored on your device using local app storage. These bookmarks are not tied to an account and are not uploaded to developer-controlled servers.

## Data The App Does Not Intentionally Collect

GalaxyDox does not intentionally collect or sell:

- name
- email address
- precise location
- contacts
- payment information
- health data
- photos from your device
- microphone recordings

## Third-Party Services

GalaxyDox depends on NASA-operated APIs and media hosts to display content, and on Firebase services to provide analytics, diagnostics, messaging, remote configuration, and public app content. These providers may process request logs, diagnostics, device identifiers, or service tokens under their own policies and service terms.

## Contact

Use the official support and privacy links published in the GalaxyDox store listing.
