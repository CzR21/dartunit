import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:dartunit/cli/dartunit_cli.dart';

void main() {
  late Directory tempDir;

  setUp(() => tempDir = Directory.systemTemp.createTempSync('dartunit_cli_init_'));
  tearDown(() => tempDir.deleteSync(recursive: true));

  group('init — creates expected files', () {
    test('returns 0 on success', () async {
      final code = await DartunitCli().run(['init', '--path', tempDir.path]);
      expect(code, equals(0));
    });

    test('creates test_arch/ directory', () async {
      await DartunitCli().run(['init', '--path', tempDir.path]);
      expect(
        Directory(p.join(tempDir.path, 'test_arch')).existsSync(),
        isTrue,
      );
    });

    test('creates test_arch/example_test_arch.dart', () async {
      await DartunitCli().run(['init', '--path', tempDir.path]);
      expect(
        File(p.join(tempDir.path, 'test_arch', 'example_test_arch.dart')).existsSync(),
        isTrue,
      );
    });

    test('example_test_arch.dart uses testArch with arch tester', () async {
      await DartunitCli().run(['init', '--path', tempDir.path]);
      final content =
          File(p.join(tempDir.path, 'test_arch', 'example_test_arch.dart'))
              .readAsStringSync();
      expect(content, contains('testArch'));
      expect(content, contains('doesNotDependOn'));
    });
  });

  group('init — template', () {
    test('--template bloc creates bloc_test_arch.dart', () async {
      await DartunitCli()
          .run(['init', '--path', tempDir.path, '--template', 'bloc']);
      expect(
        File(p.join(tempDir.path, 'test_arch', 'bloc_test_arch.dart'))
            .existsSync(),
        isTrue,
      );
    });

    test('--template clean does not create example_test_arch.dart', () async {
      await DartunitCli()
          .run(['init', '--path', tempDir.path, '--template', 'clean']);
      expect(
        File(p.join(tempDir.path, 'test_arch', 'example_test_arch.dart'))
            .existsSync(),
        isFalse,
      );
    });

    test('template rule file contains inlined architecture rules', () async {
      await DartunitCli()
          .run(['init', '--path', tempDir.path, '--template', 'mvvm']);
      final content =
          File(p.join(tempDir.path, 'test_arch', 'mvvm_test_arch.dart'))
              .readAsStringSync();
      expect(content, contains('testArchGroup'));
      expect(content, contains('testArch'));
      expect(content, contains('RuleSeverity'));
    });

    test('returns 2 for invalid template value', () async {
      final code = await DartunitCli()
          .run(['init', '--path', tempDir.path, '--template', 'invalid']);
      expect(code, equals(2));
    });
  });

  group('init — idempotency', () {
    test('returns 0 when test_arch/ already exists', () async {
      await DartunitCli().run(['init', '--path', tempDir.path]);
      final code = await DartunitCli().run(['init', '--path', tempDir.path]);
      expect(code, equals(0));
    });

    test('does not overwrite existing example_test_arch.dart on second run', () async {
      await DartunitCli().run(['init', '--path', tempDir.path]);
      final ruleFile =
          File(p.join(tempDir.path, 'test_arch', 'example_test_arch.dart'));
      ruleFile.writeAsStringSync('// custom content');

      await DartunitCli().run(['init', '--path', tempDir.path]);
      // Second run detects existing test_arch/ — does not overwrite
      expect(ruleFile.readAsStringSync(), equals('// custom content'));
    });
  });
}
