import 'dart:convert';
import 'dart:io';

void main() {
  final failures = <String>[];
  final trackedFiles = _trackedFiles();

  _checkDeniedTrackedFiles(trackedFiles, failures);
  _checkHighRiskSecrets(trackedFiles, failures);
  _checkForbiddenPrivacyClaims(trackedFiles, failures);
  _checkAndroidManifest(failures);
  _checkFirestoreRules(failures);
  _checkPrivacyDocs(failures);

  if (failures.isEmpty) {
    stdout.writeln('Repository safety checks passed.');
    return;
  }

  stderr.writeln('Repository safety checks failed:');
  for (final failure in failures) {
    stderr.writeln('- $failure');
  }
  exitCode = 1;
}

List<String> _trackedFiles() {
  final result = Process.runSync(
    'git',
    ['ls-files', '-z'],
    stdoutEncoding: utf8,
    stderrEncoding: utf8,
  );

  if (result.exitCode != 0) {
    stderr.writeln(result.stderr);
    exit(result.exitCode);
  }

  return (result.stdout as String)
      .split('\u0000')
      .where((path) => path.trim().isNotEmpty)
      .toList(growable: false);
}

void _checkDeniedTrackedFiles(List<String> files, List<String> failures) {
  final deniedPatterns = <RegExp>[
    RegExp(r'(^|/)\.claude/settings\.local\.json$'),
    RegExp(r'(^|/)\.netlify/'),
    RegExp(r'^build/'),
    RegExp(r'^android/build/'),
    RegExp(r'(^|/)\.dart_tool/'),
    RegExp(r'(^|/)local\.properties$'),
    RegExp(r'(^|/)key\.properties$'),
    RegExp(r'(^|/)google-services\.json$'),
    RegExp(r'(^|/)GoogleService-Info\.plist$'),
    RegExp(r'(^|/)service-account.*\.json$', caseSensitive: false),
    RegExp(r'(^|/)firebase-admin.*\.json$', caseSensitive: false),
    RegExp(
      r'\.(jks|keystore|p12|pem|p8|cert|cer|der|mobileprovision|apk|aab|ipa)$',
      caseSensitive: false,
    ),
  ];

  for (final path in files) {
    final normalized = path.replaceAll('\\', '/');
    if (normalized == '.env.example') {
      continue;
    }
    if (RegExp(r'(^|/)\.env($|\.)').hasMatch(normalized)) {
      failures.add('Tracked environment file: $path');
      continue;
    }
    for (final pattern in deniedPatterns) {
      if (pattern.hasMatch(normalized)) {
        failures.add('Tracked sensitive/generated file: $path');
        break;
      }
    }
  }
}

void _checkHighRiskSecrets(List<String> files, List<String> failures) {
  final patterns = <_SecretPattern>[
    _SecretPattern(
      'private key block',
      RegExp(r'-----BEGIN [A-Z ]*PRIVATE KEY-----'),
    ),
    _SecretPattern('GitHub token', RegExp(r'(ghp_|github_pat_)[A-Za-z0-9_]+')),
    _SecretPattern('Stripe live key', RegExp(r'sk_live_[A-Za-z0-9_]+')),
    _SecretPattern('Slack token', RegExp(r'xox[baprs]-[A-Za-z0-9-]+')),
    _SecretPattern(
      'bearer token',
      RegExp(r'Authorization:\s*Bearer\s+[A-Za-z0-9._-]{20,}'),
    ),
    _SecretPattern(
      'client secret',
      RegExp(r'''client_secret\s*[:=]\s*["']?[A-Za-z0-9_.-]{16,}'''),
    ),
    _SecretPattern(
      'NASA API key assignment',
      RegExp(
        r'NASA_API_KEY\s*=\s*(?!replace_with|your_|example|DEMO_KEY)[^\s]+',
      ),
    ),
  ];

  for (final path in files.where(_isTextFile)) {
    if (path == 'tool/check_repo_safety.dart') {
      continue;
    }

    final file = File(path);
    if (!file.existsSync() || file.lengthSync() > 2 * 1024 * 1024) {
      continue;
    }

    final content = file.readAsStringSync();
    for (final pattern in patterns) {
      if (pattern.regex.hasMatch(content)) {
        failures.add('${pattern.label} found in $path');
      }
    }
  }
}

void _checkForbiddenPrivacyClaims(List<String> files, List<String> failures) {
  final forbiddenClaims = <String>[
    'no analytics sdk',
    'no analytics sdks',
    'no crash reporting sdk',
    'no crash reporting sdks',
  ];

  for (final path in files.where(_isTextFile)) {
    if (path == 'tool/check_repo_safety.dart') {
      continue;
    }

    final file = File(path);
    if (!file.existsSync() || file.lengthSync() > 2 * 1024 * 1024) {
      continue;
    }

    final content = file.readAsStringSync().toLowerCase();
    for (final claim in forbiddenClaims) {
      if (content.contains(claim)) {
        failures.add('$path contains outdated privacy claim: "$claim".');
      }
    }
  }
}

void _checkAndroidManifest(List<String> failures) {
  final manifest = File('android/app/src/main/AndroidManifest.xml');
  if (!manifest.existsSync()) {
    failures.add('Missing Android manifest.');
    return;
  }

  final content = manifest.readAsStringSync();
  final removePermissions = <String>[
    'com.google.android.gms.permission.AD_ID',
    'android.permission.ACCESS_ADSERVICES_AD_ID',
    'android.permission.ACCESS_ADSERVICES_ATTRIBUTION',
    'com.google.android.finsky.permission.BIND_GET_INSTALL_REFERRER_SERVICE',
  ];

  for (final permission in removePermissions) {
    final permissionIndex = content.indexOf(permission);
    if (permissionIndex == -1) {
      failures.add('Missing manifest removal for $permission.');
      continue;
    }

    final endIndex = content.indexOf('/>', permissionIndex);
    final declaration = content.substring(
      permissionIndex,
      endIndex == -1 ? permissionIndex : endIndex,
    );
    if (!declaration.contains('tools:node="remove"')) {
      failures.add('$permission must use tools:node="remove".');
    }
  }

  if (!content.contains('android:usesCleartextTraffic="false"')) {
    failures.add('Android app must keep global cleartext traffic disabled.');
  }
}

void _checkFirestoreRules(List<String> failures) {
  final rules = File('firestore.rules');
  if (!rules.existsSync()) {
    failures.add('Missing firestore.rules.');
    return;
  }

  final content = rules.readAsStringSync();
  if (!content.contains('match /{document=**}') ||
      !content.contains('allow read, write: if false;')) {
    failures.add('Firestore rules must keep a deny-all fallback.');
  }
}

void _checkPrivacyDocs(List<String> failures) {
  final privacyFiles = [
    'docs/privacy-policy.md',
    'docs/store/play-data-safety.md',
    'docs/store/app-store-privacy.md',
  ];

  for (final path in privacyFiles) {
    final file = File(path);
    if (!file.existsSync()) {
      failures.add('Missing privacy document: $path');
      continue;
    }

    final content = file.readAsStringSync().toLowerCase();
    if (content.contains('no analytics sdk')) {
      failures.add('$path still claims that analytics SDKs are absent.');
    }
    if (!content.contains('firebase')) {
      failures.add('$path must disclose Firebase usage.');
    }
  }
}

bool _isTextFile(String path) {
  final normalized = path.toLowerCase().replaceAll('\\', '/');
  final textExtensions = <String>{
    '.dart',
    '.kt',
    '.kts',
    '.gradle',
    '.xml',
    '.json',
    '.yaml',
    '.yml',
    '.toml',
    '.properties',
    '.md',
    '.txt',
    '.html',
    '.plist',
    '.swift',
    '.java',
    '.ps1',
    '.bat',
  };

  return textExtensions.any(normalized.endsWith);
}

class _SecretPattern {
  const _SecretPattern(this.label, this.regex);

  final String label;
  final RegExp regex;
}
