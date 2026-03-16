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

    test('creates .dartunit/dartunit.yaml', () async {
      await DartunitCli().run(['init', '--path', tempDir.path]);
      expect(
        File(p.join(tempDir.path, '.dartunit', 'dartunit.yaml')).existsSync(),
        isTrue,
      );
    });

    test('creates .dartunit/README.md', () async {
      await DartunitCli().run(['init', '--path', tempDir.path]);
      expect(
        File(p.join(tempDir.path, '.dartunit', 'README.md')).existsSync(),
        isTrue,
      );
    });

    test('creates .dartunit/custom_rules/ directory', () async {
      await DartunitCli().run(['init', '--path', tempDir.path]);
      expect(
        Directory(p.join(tempDir.path, '.dartunit', 'custom_rules')).existsSync(),
        isTrue,
      );
    });

    test('creates example_rule.dart inside custom_rules/', () async {
      await DartunitCli().run(['init', '--path', tempDir.path]);
      expect(
        File(p.join(
                tempDir.path, '.dartunit', 'custom_rules', 'example_rule.dart'))
            .existsSync(),
        isTrue,
      );
    });
  });

  group('init — idempotency', () {
    test('returns 0 when .dartunit already exists', () async {
      // run twice
      await DartunitCli().run(['init', '--path', tempDir.path]);
      final code = await DartunitCli().run(['init', '--path', tempDir.path]);
      expect(code, equals(0));
    });

    test('does not overwrite existing dartunit.yaml on second run', () async {
      await DartunitCli().run(['init', '--path', tempDir.path]);
      final yamlFile =
          File(p.join(tempDir.path, '.dartunit', 'dartunit.yaml'));
      yamlFile.writeAsStringSync('# custom content');

      await DartunitCli().run(['init', '--path', tempDir.path]);
      // Second run detects existing .dartunit → does not overwrite
      expect(yamlFile.readAsStringSync(), equals('# custom content'));
    });
  });
}
