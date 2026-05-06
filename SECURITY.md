# Security Policy

## Supported Branch

Security fixes should target the default production branch for this repository.

## Reporting A Vulnerability

Please do not open a public GitHub issue for security-sensitive findings.

Instead:

1. Prepare a short report with reproduction steps, impact, and affected versions.
2. Send it through your private maintainer contact channel or repository security advisory flow.
3. Wait for confirmation before disclosing details publicly.

## Repository Safety Notes

- Do not commit production API keys, signing files, or `key.properties`.
- Release builds should inject `NASA_API_KEY`, `PRIVACY_POLICY_URL`, and `SUPPORT_URL` through CI or local secure environment variables.
- Review store privacy answers whenever networking, storage, analytics, ads, or account features change.
- Run `dart tool/check_repo_safety.dart` before pushing release or security changes.
- Keep Firebase API keys restricted in the Firebase/Google Cloud console and keep Firestore rules deny-by-default.
- Keep Android advertising ID, AdServices, and install-referrer permissions removed unless a reviewed product requirement explicitly needs them.
