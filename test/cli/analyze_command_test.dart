import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:dartunit/cli/dartunit_cli.dart';

void _writeConfig(Directory dir, String yaml) {
  final du = Directory(p.join(dir.path, '.dartunit'))
    ..createSync(recursive: true);
  File(p.join(du.path, 'dartunit.yaml')).writeAsStringSync(yaml);
}

void _writeDartFile(Directory dir, String relPath, String content) {
  final file = File(p.join(dir.path, relPath));
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(content);
}

void main() {
  late Directory tempDir;

  setUp(() => tempDir = Directory.systemTemp.createTempSync('dartunit_cli_analyze_'));
  tearDown(() => tempDir.deleteSync(recursive: true));

  group('analyze — exit codes', () {
    test('returns 2 when config file does not exist', () async {
      final code = await DartunitCli().run(['analyze', '--path', tempDir.path]);
      expect(code, equals(2));
    });

    test('returns 0 when rules match no classes', () async {
      _writeConfig(tempDir, '''
rules:
  - id: R001
    description: Nothing to match
    severity: error
    selector:
      type: class
      where:
        folder: lib/nonexistent
    predicate:
      type: nameEndsWith
      value: Repository
''');
      final code = await DartunitCli().run(['analyze', '--path', tempDir.path]);
      expect(code, equals(0));
    });

    test('returns 1 when error-level violations are found', () async {
      _writeDartFile(tempDir, 'lib/domain/bad.dart', '''
import '../data/repo.dart';
class Bad {}
''');
      _writeConfig(tempDir, '''
rules:
  - id: R001
    description: Domain must not depend on Data
    severity: error
    selector:
      type: class
      where:
        folder: lib/domain
    predicate:
      not:
        type: dependOnFolder
        value: lib/data
''');
      final code = await DartunitCli().run(['analyze', '--path', tempDir.path]);
      expect(code, equals(1));
    });

    test('returns 0 when only warnings are found', () async {
      _writeDartFile(tempDir, 'lib/service/big.dart', '''
class BigClass {
  void a() {} void b() {}
}
''');
      _writeConfig(tempDir, '''
rules:
  - id: R001
    description: At most 0 methods
    severity: warning
    selector:
      type: class
      where:
        folder: lib/service
    predicate:
      type: maxMethods
      value: 0
''');
      final code = await DartunitCli().run(['analyze', '--path', tempDir.path]);
      expect(code, equals(0));
    });
  });

  group('analyze — flags and options', () {
    test('--no-color flag is accepted without error', () async {
      _writeConfig(tempDir, '''
rules:
  - id: R001
    description: Test
    severity: error
    selector:
      type: class
      where:
        folder: lib/nonexistent
    predicate:
      type: nameEndsWith
      value: Service
''');
      final code = await DartunitCli()
          .run(['analyze', '--path', tempDir.path, '--no-color']);
      expect(code, equals(0));
    });

    test('--config flag points to custom yaml path', () async {
      final custom = File(p.join(tempDir.path, 'custom_rules.yaml'))
        ..writeAsStringSync('''
rules:
  - id: R001
    description: Test
    severity: error
    selector:
      type: class
      where:
        folder: lib/nonexistent
    predicate:
      type: nameEndsWith
      value: Repository
''');
      final code = await DartunitCli().run([
        'analyze',
        '--path', tempDir.path,
        '--config', custom.path,
      ]);
      expect(code, equals(0));
    });

    test('returns 0 when only presets are configured and no violations', () async {
      _writeConfig(tempDir, '''
presets:
  - preset: structure/no-circular-dependencies
    severity: error
''');
      final code = await DartunitCli().run(['analyze', '--path', tempDir.path]);
      expect(code, equals(0));
    });
  });
}
