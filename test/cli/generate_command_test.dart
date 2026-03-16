import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:dartunit/cli/dartunit_cli.dart';

void _initProject(Directory dir) {
  Directory(p.join(dir.path, '.dartunit', 'custom_rules'))
      .createSync(recursive: true);
  File(p.join(dir.path, '.dartunit', 'dartunit.yaml'))
      .writeAsStringSync('rules:\n');
}

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('dartunit_cli_generate_');
    _initProject(tempDir);
  });
  tearDown(() => tempDir.deleteSync(recursive: true));

  group('generate — creates files', () {
    test('returns 0 on success', () async {
      final code = await DartunitCli()
          .run(['generate', 'no_ui_in_domain', '--path', tempDir.path]);
      expect(code, equals(0));
    });

    test('creates the rule dart file in custom_rules/', () async {
      await DartunitCli()
          .run(['generate', 'no_ui_in_domain', '--path', tempDir.path]);
      expect(
        File(p.join(tempDir.path, '.dartunit', 'custom_rules',
                'no_ui_in_domain_rule.dart'))
            .existsSync(),
        isTrue,
      );
    });

    test('appends an entry to dartunit.yaml', () async {
      await DartunitCli()
          .run(['generate', 'my_rule', '--path', tempDir.path]);
      final yaml =
          File(p.join(tempDir.path, '.dartunit', 'dartunit.yaml'))
              .readAsStringSync();
      expect(yaml, contains('MY_RULE'));
    });
  });

  group('generate — PascalCase conversion', () {
    test('converts snake_case to PascalCase class name', () async {
      await DartunitCli()
          .run(['generate', 'no_repo_in_ui', '--path', tempDir.path]);
      final content = File(p.join(tempDir.path, '.dartunit', 'custom_rules',
              'no_repo_in_ui_rule.dart'))
          .readAsStringSync();
      expect(content, contains('NoRepoInUiRule'));
    });

    test('single word is properly capitalised', () async {
      await DartunitCli()
          .run(['generate', 'myrule', '--path', tempDir.path]);
      final content = File(p.join(tempDir.path, '.dartunit', 'custom_rules',
              'myrule_rule.dart'))
          .readAsStringSync();
      expect(content, contains('MyruleRule'));
    });
  });

  group('generate — error cases', () {
    test('returns 2 when no rule name is provided', () async {
      final code = await DartunitCli()
          .run(['generate', '--path', tempDir.path]);
      expect(code, equals(2));
    });

    test('returns 2 when .dartunit directory does not exist', () async {
      final emptyDir = Directory.systemTemp
          .createTempSync('dartunit_generate_nodir_');
      addTearDown(() => emptyDir.deleteSync(recursive: true));
      final code = await DartunitCli()
          .run(['generate', 'some_rule', '--path', emptyDir.path]);
      expect(code, equals(2));
    });
  });
}
