import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Phase 0 secret-scan gate for cloud OAuth configuration.
///
/// Purpose: Fail if client secrets, private keys, or portal credential JSON
/// land under `lib/` or committed legal/oauth docs.
void main() {
  final forbiddenPatterns = <RegExp>[
    RegExp(r'client[_-]?secret\s*[:=]\s*[''"][^''"]+[''"]', caseSensitive: false),
    RegExp(r'BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY'),
    RegExp(r'"client_secret"\s*:\s*"[^"]+"'),
    RegExp(r'refresh_token\s*[:=]\s*[''"][^''"]+[''"]', caseSensitive: false),
  ];

  final roots = <String>[
    'lib',
    'docs/legal',
    'docs/adr',
    'docs/research',
  ];

  final skipNames = <String>{
    // Example templates may mention placeholder password keys, not values.
    'key.properties.example',
  };

  test('no client secrets or private keys in committed cloud/oauth docs and lib', () {
    final offenders = <String>[];
    for (final root in roots) {
      final dir = Directory(root);
      if (!dir.existsSync()) continue;
      for (final entity in dir.listSync(recursive: true)) {
        if (entity is! File) continue;
        final name = entity.uri.pathSegments.last;
        if (skipNames.contains(name)) continue;
        final lower = name.toLowerCase();
        if (!(lower.endsWith('.dart') ||
            lower.endsWith('.md') ||
            lower.endsWith('.json') ||
            lower.endsWith('.xml') ||
            lower.endsWith('.properties') ||
            lower.endsWith('.yml') ||
            lower.endsWith('.yaml'))) {
          continue;
        }
        final text = entity.readAsStringSync();
        for (final pattern in forbiddenPatterns) {
          if (pattern.hasMatch(text)) {
            offenders.add('${entity.path} matches ${pattern.pattern}');
          }
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'Forbidden secret-like content:\n${offenders.join('\n')}',
    );
  });

  test('gitignored release signing files are not tracked', () {
    final tracked = Process.runSync('git', [
      'ls-files',
      'android/key.properties',
      'android/tinytunes-release.jks',
    ]);
    expect(tracked.exitCode, 0);
    expect((tracked.stdout as String).trim(), isEmpty);
  });
}
