import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:dartunit/cli/dartunit_cli.dart';

/// Writes a rule file to arch_test/ that outputs the given violations as JSON.
///
/// Rule files in tests use only dart:io and dart:convert so they run without
/// needing a pubspec.yaml / package_config.json in the temp directory.
void _writeRuleFile(Directory dir, String fileName, List<Map<String, dynamic>> violations) {
  final archTestDir = Directory(p.join(dir.path, 'arch_test'))
    ..createSync(recursive: true);
  final violationsJson = violations
      .map((v) => '      ${_encodeMap(v)}')
      .join(',\n');
  File(p.join(archTestDir.path, fileName)).writeAsStringSync('''
import 'dart:convert';
import 'dart:io';
void main(List<String> args) {
  final data = {
    'ruleDescription': 'Test rule',
    'severity': 'error',
    'violations': [
$violationsJson
    ],
  };
  stdout.writeln('DARTUNIT_RESULT:\${jsonEncode(data)}');
}
''');
}

String _encodeMap(Map<String, dynamic> m) {
  final entries = m.entries
      .map((e) => "'${e.key}': '${e.value}'")
      .join(', ');
  return '{$entries}';
}

void main() {
  late Directory tempDir;

  setUp(() => tempDir = Directory.systemTemp.createTempSync('dartunit_cli_analyze_'));
  tearDown(() => tempDir.deleteSync(recursive: true));

  group('analyze — exit codes', () {
    test('returns 2 when arch_test/ does not exist', () async {
      final code = await DartunitCli().run(['analyze', '--path', tempDir.path]);
      expect(code, equals(2));
    });

    test('returns 0 when arch_test/ is empty', () async {
      Directory(p.join(tempDir.path, 'arch_test')).createSync();
      final code = await DartunitCli().run(['analyze', '--path', tempDir.path]);
      expect(code, equals(0));
    });

    test('returns 0 when rule produces no violations', () async {
      _writeRuleFile(tempDir, 'no_violations_arch_test.dart', []);
      final code = await DartunitCli().run(['analyze', '--path', tempDir.path]);
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
      final code = await DartunitCli().run(['analyze', '--path', tempDir.path]);
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
      final code = await DartunitCli().run(['analyze', '--path', tempDir.path]);
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
      final code = await DartunitCli().run(['analyze', '--path', tempDir.path]);
      expect(code, equals(1));
    });
  });
}
