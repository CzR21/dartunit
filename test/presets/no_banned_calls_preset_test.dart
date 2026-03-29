import 'package:dartunit/core/entities/subject.dart';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';
import 'package:dartunit/dartunit.dart';
import 'package:dartunit/presets/no_banned_calls_preset.dart';

YamlMap _cfg(String yaml) => loadYaml(yaml) as YamlMap;

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('dartunit_banned_test_');
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  final preset = NoBannedCallsPreset();

  group('NoBannedCallsPreset — contract', () {
    test('presetId is correct', () {
      expect(preset.presetId, equals('quality/no-banned-calls'));
    });

    test('generates one rule per pattern', () {
      final rules = preset.expand(_cfg('''
patterns:
  - TODO
  - FIXME
'''));
      expect(rules, hasLength(2));
    });

    test('generates zero rules when patterns list is empty', () {
      expect(preset.expand(_cfg('patterns: []')), isEmpty);
    });
  });

  group('NoBannedCallsPreset — rule properties', () {
    test('rule description includes the pattern', () {
      final rules = preset.expand(_cfg('patterns:\n  - TODO'));
      expect(rules.first.description, isNotEmpty);
    });

    test('severity defaults to error', () {
      final rules = preset.expand(_cfg('patterns:\n  - TODO'));
      expect(rules.first.severity, equals(RuleSeverity.error));
    });

    test('severity can be overridden', () {
      final rules =
          preset.expand(_cfg('severity: warning\npatterns:\n  - TODO'));
      expect(rules.first.severity, equals(RuleSeverity.warning));
    });
  });

  group('NoBannedCallsPreset — predicate evaluation', () {
    test('rule passes when file does not contain banned pattern', () {
      final file = File(p.join(tempDir.path, 'clean.dart'))
        ..writeAsStringSync('void compute() { return; }');
      final rules = preset.expand(_cfg('patterns:\n  - TODO'));
      final af = AnalyzedFile(
          filePath: file.path, packagePath: 'pkg:app/clean.dart', imports: []);
      final ctx = AnalysisContext(
          classes: [], files: [], dependencyGraph: DependencyGraph(), projectRoot: '/p');
      final s = Subject(name: 'clean.dart', filePath: file.path, element: af);
      expect(rules.first.predicate.analyze(s, ctx).passed, isTrue);
    });

    test('rule fails when file contains banned pattern', () {
      final file = File(p.join(tempDir.path, 'dirty.dart'))
        ..writeAsStringSync('// TODO: fix this later');
      final rules = preset.expand(_cfg('patterns:\n  - TODO'));
      final af = AnalyzedFile(
          filePath: file.path, packagePath: 'pkg:app/dirty.dart', imports: []);
      final ctx = AnalysisContext(
          classes: [], files: [], dependencyGraph: DependencyGraph(), projectRoot: '/p');
      final s = Subject(name: 'dirty.dart', filePath: file.path, element: af);
      expect(rules.first.predicate.analyze(s, ctx).passed, isFalse);
    });

    test('each pattern gets its own rule with a unique id', () {
      final rules = preset.expand(_cfg('''
patterns:
  - TODO
  - FIXME
'''));
      expect(rules[0].description, isNot(equals(rules[1].description)));
    });
  });
}
