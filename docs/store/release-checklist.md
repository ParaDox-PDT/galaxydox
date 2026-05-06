# Release Checklist

## Public Repo Safety

- Keep `android/key.properties`, keystores, API keys, and signing assets out of git.
- Publish a real privacy policy URL and support URL.
- Review `.gitignore` before each release branch cut.
- Re-run a secret scan against both the working tree and git history.
- Run `dart tool/check_repo_safety.dart` before pushing release changes.
- Keep GitHub Actions green for `flutter analyze` and `flutter test`.
- Review dependency updates weekly.

## Android / Google Play

- Build signed `appbundle` with `NASA_API_KEY`, `PRIVACY_POLICY_URL`, and `SUPPORT_URL`.
- Upload `build/app/outputs/native-debug-symbols/release/native-debug-symbols.zip`.
- Review Play Data safety answers.
- Verify Firebase Analytics, Crashlytics, Messaging, Remote Config, and Firestore disclosures.
- Verify Firebase API key restrictions, Firestore rules, and any public admin URLs before announcing the repo.
- Verify store listing title, short description, and full description against metadata policy.
- Upload screenshots, feature graphic, and privacy policy URL in Play Console.

## iOS / App Store

- Run `pod install` on macOS and build a signed archive.
- Confirm `ITSAppUsesNonExemptEncryption` remains correct.
- Fill App Privacy answers in App Store Connect.
- Add support URL, marketing URL, and privacy policy URL.
- Upload screenshots for every required device size.

## Final Verification

- Test release build on at least one physical Android device and one physical iPhone.
- Verify bookmarks persist and no placeholder actions remain.
- Verify only trusted external NASA or YouTube links open from the app.
- Re-check store metadata for keyword stuffing or unsupported claims.
