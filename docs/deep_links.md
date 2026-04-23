# Deep Links

GalaxyDox now shares verified `https://galaxydox.uz/...` links for the current
shareable content flows:

- `https://galaxydox.uz/wallpapers/<id>`
- `https://galaxydox.uz/apod?date=YYYY-MM-DD`

## What was added

- Flutter web now uses path URL strategy, so clean URLs work without `/#/`.
- Android App Links intent filters were added for `wallpapers` and `apod`.
- Hosted association files live in `web/.well-known/`.
- The post-build script now copies `_redirects`, `_headers`, and `.well-known`
  files into `build/web/`.

## Deployment checklist

1. Build the web app:

```bash
flutter build web --release --dart-define-from-file=.env
dart tool/copy_web_redirects.dart
```

2. Deploy the generated `build/web` directory so these URLs are publicly
   reachable without redirects:

- `https://galaxydox.uz/.well-known/assetlinks.json`
- `https://galaxydox.uz/.well-known/apple-app-site-association`
- `https://galaxydox.uz/apple-app-site-association`

3. For Android Play-distributed builds, add the Play App Signing SHA-256
   fingerprint to `web/.well-known/assetlinks.json` if Google Play resigns the
   app.

4. Replace `APPLE_TEAM_ID` in both Apple association files with the real Apple
   Team ID / App ID Prefix for `com.galaxydox.app`.

## Quick verification

Android:

```bash
adb shell pm get-app-links com.galaxydox.app
adb shell am start -a android.intent.action.VIEW -d "https://galaxydox.uz/wallpapers/test-id" com.galaxydox.app
adb shell am start -a android.intent.action.VIEW -d "https://galaxydox.uz/apod?date=2026-04-22" com.galaxydox.app
```

Web:

- Open `https://galaxydox.uz/wallpapers/<id>`
- Open `https://galaxydox.uz/apod?date=2026-04-22`
