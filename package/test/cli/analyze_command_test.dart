import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:dartunit/cli/dartunit_cli.dart';

/// A shared temp dir that has `dart pub get` run once.
/// Its `.dart_tool/package_config.json` is copied into each test's temp dir
/// so that `dart test --reporter json` can resolve `package:test` without
/// running `dart pub get` for every test.
late Directory _baseDir;

/// Copies the package resolution artifacts from [_baseDir] into [dest].
/// `dart test` requires both `pubspec.yaml` AND `.dart_tool/package_config.json`.
/// The package_config.json uses absolute pub-cache paths, so it is valid
/// in any directory.
void _copyPackageConfig(Directory dest) {
  // pubspec.yaml signals to `dart test` that this is a valid project root.
  File(p.join(dest.path, 'pubspec.yaml')).writeAsStringSync(
    File(p.join(_baseDir.path, 'pubspec.yaml')).readAsStringSync(),
  );
  final dartTool = Directory(p.join(dest.path, '.dart_tool'))..createSync();
  File(p.join(dartTool.path, 'package_config.json')).writeAsStringSync(
    File(p.join(_baseDir.path, '.dart_tool', 'package_config.json'))
        .readAsStringSync(),
  );
}

/// Writes a rule file to test_arch/ that outputs the given violations as JSON.
///
/// The file is a valid `package:test` test so it can be executed by
/// `dart test --reporter json` (which is what [AnalyzeCommand] now uses).
void _writeRuleFile(
    Directory dir, String fileName, List<Map<String, dynamic>> violations) {
  final archTestDir = Directory(p.join(dir.path, 'test_arch'))
    ..createSync(recursive: true);

  final violationsLiteral = violations
      .map((v) {
        final entries =
            v.entries.map((e) => "'${e.key}': '${e.value}'").join(', ');
        return '      {$entries}';
      })
      .join(',\n');

  File(p.join(archTestDir.path, fileName)).writeAsStringSync('''
import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';

void main() {
  test('Test rule', () {
    final violations = <Map<String, dynamic>>[
$violationsLiteral
    ];

    final data = <String, dynamic>{
      'ruleDescription': 'Test rule',
      'severity': 'error',
      'violations': violations,
    };
    // Parsed by AnalyzeCommand from stderr.
    stderr.writeln('DARTUNIT_RESULT:\${jsonEncode(data)}');

    final failures = violations
        .where((v) => v['severity'] == 'error' || v['severity'] == 'critical')
        .toList();
    expect(failures, isEmpty);
  });
}
''');
}

void main() {
  late Directory tempDir;

  setUpAll(() async {
    _baseDir =
        Directory.systemTemp.createTempSync('dartunit_analyze_base_');
    File(p.join(_baseDir.path, 'pubspec.yaml')).writeAsStringSync('''
name: test_base
version: 0.0.1
environment:
  sdk: ^3.0.0
dependencies:
  test: ^1.24.0
''');
    final result = await Process.run(
      'dart',
      ['pub', 'get'],
      workingDirectory: _baseDir.path,
    );
    if (result.exitCode != 0) {
      throw StateError('dart pub get failed: ${result.stderr}');
    }
  });

  tearDownAll(() => _baseDir.deleteSync(recursive: true));

  setUp(() {
    tempDir =
        Directory.systemTemp.createTempSync('dartunit_cli_analyze_');
    _copyPackageConfig(tempDir);
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  group('analyze — exit codes', () {
    test('returns 2 when test_arch/ does not exist', () async {
      final code =
          await DartunitCli().run(['analyze', '--path', tempDir.path]);
      expect(code, equals(2));
    });

    test('returns 0 when test_arch/ is empty', () async {
      Directory(p.join(tempDir.path, 'test_arch')).createSync();
      final code =
          await DartunitCli().run(['analyze', '--path', tempDir.path]);
      expect(code, equals(0));
    });

    test('returns 0 when rule produces no violations', () async {
      _writeRuleFile(tempDir, 'no_violations_arch_test.dart', []);
      final code =
          await DartunitCli().run(['analyze', '--path', tempDir.path]);
      expect(code, equals(0));
    });

    test('returns 1 when error-level violations are found', () async {
      _writeRuleFile(tempDir, 'has_violations_arch_test.dart', [
        {
          'ruleDescription': 'Domain must not depend on Data',
          'message': 'Bad depends on lib/data',
          'filePath': 'lib/domain/bad.dart',
          'severity': 'error',
        },
      ]);
      final code =
          await DartunitCli().run(['analyze', '--path', tempDir.path]);
      expect(code, equals(1));
    });

    test('returns 0 when only warnings are found', () async {
      _writeRuleFile(tempDir, 'warnings_arch_test.dart', [
        {
          'ruleDescription': 'God-class check',
          'message': 'BigClass has too many methods',
          'filePath': 'lib/service/big.dart',
          'severity': 'warning',
        },
      ]);
      final code =
          await DartunitCli().run(['analyze', '--path', tempDir.path]);
      expect(code, equals(0));
    });
  });

  group('analyze — flags', () {
    test('--no-color flag is accepted without error', () async {
      _writeRuleFile(tempDir, 'no_violations_arch_test.dart', []);
      final code = await DartunitCli()
          .run(['analyze', '--path', tempDir.path, '--no-color']);
      expect(code, equals(0));
    });
  });

  group('analyze — multiple rule files', () {
    test('collects violations from multiple rule files', () async {
      _writeRuleFile(tempDir, 'rule_a_arch_test.dart', [
        {
          'ruleDescription': 'Rule A',
          'message': 'Violation A',
          'filePath': 'lib/a.dart',
          'severity': 'error',
        },
      ]);
      _writeRuleFile(tempDir, 'rule_b_arch_test.dart', [
        {
          'ruleDescription': 'Rule B',
          'message': 'Violation B',
          'filePath': 'lib/b.dart',
          'severity': 'error',
        },
      ]);
      final code =
          await DartunitCli().run(['analyze', '--path', tempDir.path]);
      expect(code, equals(1));
    });
  });
}
