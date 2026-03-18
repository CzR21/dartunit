import 'package:dartunit/core/entities/subject.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';
import 'package:dartunit/dartunit.dart';
import 'package:dartunit/presets/annotation_must_not_have_preset.dart';

YamlMap _cfg(String yaml) => loadYaml(yaml) as YamlMap;

AnalysisContext _ctx() => AnalysisContext(
    classes: [], files: [], dependencyGraph: DependencyGraph(), projectRoot: '/p');

void main() {
  final preset = AnnotationMustNotHavePreset();

  group('AnnotationMustNotHavePreset — contract', () {
    test('presetId is correct', () {
      expect(preset.presetId, equals('annotation/must-not-have'));
    });

    test('generates one rule per folder', () {
      final rules = preset.expand(_cfg(
          'annotation: deprecated\nfolders:\n  - lib/service\n  - lib/data'));
      expect(rules, hasLength(2));
    });

    test('generates zero rules for empty folder list', () {
      expect(preset.expand(_cfg('annotation: deprecated\nfolders: []')), isEmpty);
    });
  });

  group('AnnotationMustNotHavePreset — rule properties', () {
    test('rule description includes forbidden annotation and folder', () {
      final rules =
          preset.expand(_cfg('annotation: deprecated\nfolders:\n  - lib/service'));
      expect(rules.first.description, contains('deprecated'));
      expect(rules.first.description, contains('lib/service'));
    });

    test('severity defaults to error', () {
      final rules =
          preset.expand(_cfg('annotation: deprecated\nfolders:\n  - lib/service'));
      expect(rules.first.severity, equals(RuleSeverity.error));
    });

    test('exceptions are passed to the selector', () {
      final rules = preset.expand(_cfg(
          'annotation: deprecated\nfolders:\n  - lib/service\nexceptions: [LegacyService]'));
      final sel = rules.first.selector as ClassSelector;
      expect(sel.excludeNames, contains('LegacyService'));
    });
  });

  group('AnnotationMustNotHavePreset — predicate evaluation', () {
    test('rule passes when class does not carry forbidden annotation', () {
      final rules =
          preset.expand(_cfg('annotation: deprecated\nfolders:\n  - lib/service'));
      final cls = AnalyzedClass(
          name: 'ActiveService',
          filePath: '/p/lib/service/active.dart',
          packagePath: 'pkg:app/active.dart',
          annotations: ['injectable']);
      final s = Subject(name: cls.name, filePath: cls.filePath, element: cls);
      expect(rules.first.predicate.evaluate(s, _ctx()).passed, isTrue);
    });

    test('rule fails when class carries the forbidden annotation', () {
      final rules =
          preset.expand(_cfg('annotation: deprecated\nfolders:\n  - lib/service'));
      final cls = AnalyzedClass(
          name: 'OldService',
          filePath: '/p/lib/service/old.dart',
          packagePath: 'pkg:app/old.dart',
          annotations: ['deprecated']);
      final s = Subject(name: cls.name, filePath: cls.filePath, element: cls);
      expect(rules.first.predicate.evaluate(s, _ctx()).passed, isFalse);
    });

    test('fail message contains class name and annotation', () {
      final rules =
          preset.expand(_cfg('annotation: internal\nfolders:\n  - lib/service'));
      final cls = AnalyzedClass(
          name: 'InternalService',
          filePath: '/p/lib/service/internal.dart',
          packagePath: 'pkg:app/internal.dart',
          annotations: ['internal']);
      final s = Subject(name: cls.name, filePath: cls.filePath, element: cls);
      final message = rules.first.predicate.evaluate(s, _ctx()).message;
      expect(message, contains('InternalService'));
      expect(message, contains('internal'));
    });
  });
}
