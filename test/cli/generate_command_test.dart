import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:dartunit/cli/dartunit_cli.dart';

void _initProject(Directory dir) {
  Directory(p.join(dir.path, 'arch_test')).createSync(recursive: true);
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

    test('creates the rule dart file in arch_test/', () async {
      await DartunitCli()
          .run(['generate', 'no_ui_in_domain', '--path', tempDir.path]);
      expect(
        File(p.join(tempDir.path, 'arch_test', 'no_ui_in_domain_arch_test.dart'))
            .existsSync(),
        isTrue,
      );
    });

    test('generated file contains archTest and ArchitectureRule', () async {
      await DartunitCli()
          .run(['generate', 'my_rule', '--path', tempDir.path]);
      final content =
          File(p.join(tempDir.path, 'arch_test', 'my_rule_arch_test.dart'))
              .readAsStringSync();
      expect(content, contains('testArch'));
      expect(content, contains('ArchitectureRule'));
      expect(content, contains('My Rule'));
    });
  });

  group('generate — error cases', () {
    test('returns 2 when no rule name is provided', () async {
      final code = await DartunitCli()
          .run(['generate', '--path', tempDir.path]);
      expect(code, equals(2));
    });

    test('returns 2 when arch_test/ directory does not exist', () async {
      final emptyDir =
          Directory.systemTemp.createTempSync('dartunit_generate_nodir_');
      addTearDown(() => emptyDir.deleteSync(recursive: true));
      final code = await DartunitCli()
          .run(['generate', 'some_rule', '--path', emptyDir.path]);
      expect(code, equals(2));
    });
  });
}
