import 'dart:io';

void main() {
  final source = File('web/_redirects');
  final target = File('build/web/_redirects');

  if (!source.existsSync()) {
    stderr.writeln('Missing source file: ${source.path}');
    exitCode = 1;
    return;
  }

  target.parent.createSync(recursive: true);
  source.copySync(target.path);
  stdout.writeln('Copied ${source.path} -> ${target.path}');
}
