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

    test('creates arch_test/ directory', () async {
      await DartunitCli().run(['init', '--path', tempDir.path]);
      expect(
        Directory(p.join(tempDir.path, 'arch_test')).existsSync(),
        isTrue,
      );
    });

    test('creates arch_test/example_arch_test.dart', () async {
      await DartunitCli().run(['init', '--path', tempDir.path]);
      expect(
        File(p.join(tempDir.path, 'arch_test', 'example_arch_test.dart')).existsSync(),
        isTrue,
      );
    });

    test('example_arch_test.dart contains archTest call', () async {
      await DartunitCli().run(['init', '--path', tempDir.path]);
      final content =
          File(p.join(tempDir.path, 'arch_test', 'example_arch_test.dart'))
              .readAsStringSync();
      expect(content, contains('archTest'));
      expect(content, contains('ArchitectureRule'));
    });
  });

  group('init — template', () {
    test('--template bloc creates all bloc rule files', () async {
      await DartunitCli()
          .run(['init', '--path', tempDir.path, '--template', 'bloc']);
      final archTestDir = p.join(tempDir.path, 'arch_test');
      expect(File(p.join(archTestDir, 'blocs_no_direct_data_access_arch_test.dart')).existsSync(), isTrue);
      expect(File(p.join(archTestDir, 'cubits_no_direct_data_access_arch_test.dart')).existsSync(), isTrue);
      expect(File(p.join(archTestDir, 'repositories_in_data_layer_arch_test.dart')).existsSync(), isTrue);
      expect(File(p.join(archTestDir, 'datasources_in_data_layer_arch_test.dart')).existsSync(), isTrue);
      expect(File(p.join(archTestDir, 'use_cases_in_domain_layer_arch_test.dart')).existsSync(), isTrue);
      expect(File(p.join(archTestDir, 'domain_no_presentation_dependency_arch_test.dart')).existsSync(), isTrue);
    });

    test('--template clean does not create example_arch_test.dart', () async {
      await DartunitCli()
          .run(['init', '--path', tempDir.path, '--template', 'clean']);
      expect(
        File(p.join(tempDir.path, 'arch_test', 'example_arch_test.dart'))
            .existsSync(),
        isFalse,
      );
    });

    test('template rule files contain archTest', () async {
      await DartunitCli()
          .run(['init', '--path', tempDir.path, '--template', 'mvvm']);
      final content = File(p.join(tempDir.path, 'arch_test',
              'viewmodels_no_view_dependency_arch_test.dart'))
          .readAsStringSync();
      expect(content, contains('archTest'));
      expect(content, contains('MVVM'));
    });

    test('returns 2 for invalid template value', () async {
      final code = await DartunitCli()
          .run(['init', '--path', tempDir.path, '--template', 'invalid']);
      expect(code, equals(2));
    });
  });

  group('init — idempotency', () {
    test('returns 0 when arch_test/ already exists', () async {
      await DartunitCli().run(['init', '--path', tempDir.path]);
      final code = await DartunitCli().run(['init', '--path', tempDir.path]);
      expect(code, equals(0));
    });

    test('does not overwrite existing example_arch_test.dart on second run', () async {
      await DartunitCli().run(['init', '--path', tempDir.path]);
      final ruleFile =
          File(p.join(tempDir.path, 'arch_test', 'example_arch_test.dart'));
      ruleFile.writeAsStringSync('// custom content');

      await DartunitCli().run(['init', '--path', tempDir.path]);
      // Second run detects existing arch_test/ — does not overwrite
      expect(ruleFile.readAsStringSync(), equals('// custom content'));
    });
  });
}
