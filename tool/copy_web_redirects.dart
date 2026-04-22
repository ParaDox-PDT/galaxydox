import 'dart:io';

/// Copies static web assets that Flutter's build system does not include
/// automatically into build/web. Run this after `flutter build web`:
///
///   dart tool/copy_web_redirects.dart
void main() {
  var hasError = false;

  // Remove .well-known dotfolder if it exists — Netlify manual deploy ignores
  // dotfolders so they must never be in the deploy output. The redirect rule
  // /.well-known/* → /well-known/:splat handles public URL mapping instead.
  final dotWellKnown = Directory('build/web/.well-known');
  if (dotWellKnown.existsSync()) {
    dotWellKnown.deleteSync(recursive: true);
    stdout.writeln('Removed build/web/.well-known (dotfolder not served by Netlify)');
  }

  // Single files sourced from web/
  final singleFiles = <String>[
    '_redirects',
    '_headers',
    'apple-app-site-association',
  ];

  for (final relativePath in singleFiles) {
    final source = File('web/$relativePath');
    final target = File('build/web/$relativePath');
    hasError = !_copyFile(source, target) || hasError;
  }

  // Recursive folders sourced from web/
  final folders = <String>[
    'well-known',
  ];

  for (final folder in folders) {
    final sourceDir = Directory('web/$folder');
    final targetDir = Directory('build/web/$folder');
    hasError = !_copyDirectory(sourceDir, targetDir) || hasError;
  }

  // netlify.toml lives at repo root, not inside web/
  hasError =
      !_copyFile(File('netlify.toml'), File('build/web/netlify.toml')) ||
      hasError;

  if (hasError) {
    exitCode = 1;
  }
}

bool _copyFile(File source, File target) {
  if (!source.existsSync()) {
    stderr.writeln('ERROR: missing source file: ${source.path}');
    return false;
  }
  target.parent.createSync(recursive: true);
  source.copySync(target.path);
  stdout.writeln('Copied ${source.path} -> ${target.path}');
  return true;
}

bool _copyDirectory(Directory source, Directory target) {
  if (!source.existsSync()) {
    stderr.writeln('ERROR: missing source directory: ${source.path}');
    return false;
  }
  var ok = true;
  for (final entity in source.listSync(recursive: true)) {
    if (entity is File) {
      final relative = entity.path.substring(source.path.length);
      final dest = File('${target.path}$relative');
      ok = _copyFile(entity, dest) && ok;
    }
  }
  return ok;
}
