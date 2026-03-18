import 'package:dartunit/core/entities/subject.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';
import 'package:dartunit/dartunit.dart';
import 'package:dartunit/presets/annotation_must_have_preset.dart';

YamlMap _cfg(String yaml) => loadYaml(yaml) as YamlMap;

AnalysisContext _ctx() => AnalysisContext(
    classes: [], files: [], dependencyGraph: DependencyGraph(), projectRoot: '/p');

void main() {
  final preset = AnnotationMustHavePreset();

  group('AnnotationMustHavePreset — contract', () {
    test('presetId is correct', () {
      expect(preset.presetId, equals('annotation/must-have'));
    });

    test('generates one rule per folder', () {
      final rules = preset.expand(_cfg(
          'annotation: injectable\nfolders:\n  - lib/data\n  - lib/service'));
      expect(rules, hasLength(2));
    });

    test('generates zero rules when folders list is empty', () {
      expect(preset.expand(_cfg('annotation: injectable\nfolders: []')), isEmpty);
    });
  });

  group('AnnotationMustHavePreset — rule properties', () {
    test('rule description includes annotation and folder', () {
      final rules =
          preset.expand(_cfg('annotation: injectable\nfolders:\n  - lib/data'));
      expect(rules.first.description, contains('injectable'));
      expect(rules.first.description, contains('lib/data'));
    });

    test('severity defaults to error', () {
      final rules =
          preset.expand(_cfg('annotation: injectable\nfolders:\n  - lib/data'));
      expect(rules.first.severity, equals(RuleSeverity.error));
    });

    test('severity can be overridden', () {
      final rules = preset.expand(
          _cfg('annotation: injectable\nfolders:\n  - lib/data\nseverity: warning'));
      expect(rules.first.severity, equals(RuleSeverity.warning));
    });
  });

  group('AnnotationMustHavePreset — predicate evaluation', () {
    test('rule passes when class carries required annotation', () {
      final rules =
          preset.expand(_cfg('annotation: injectable\nfolders:\n  - lib/data'));
      final cls = AnalyzedClass(
          name: 'UserRepo',
          filePath: '/p/lib/data/user_repo.dart',
          packagePath: 'pkg:app/user_repo.dart',
          annotations: ['injectable']);
      final s = Subject(name: cls.name, filePath: cls.filePath, element: cls);
      expect(rules.first.predicate.evaluate(s, _ctx()).passed, isTrue);
    });

    test('rule fails when class lacks required annotation', () {
      final rules =
          preset.expand(_cfg('annotation: injectable\nfolders:\n  - lib/data'));
      final cls = AnalyzedClass(
          name: 'UserRepo',
          filePath: '/p/lib/data/user_repo.dart',
          packagePath: 'pkg:app/user_repo.dart',
          annotations: []);
      final s = Subject(name: cls.name, filePath: cls.filePath, element: cls);
      expect(rules.first.predicate.evaluate(s, _ctx()).passed, isFalse);
    });

    test('fail message contains annotation name', () {
      final rules =
          preset.expand(_cfg('annotation: singleton\nfolders:\n  - lib/service'));
      final cls = AnalyzedClass(
          name: 'MissingAnnotationClass',
          filePath: '/p/lib/service/cls.dart',
          packagePath: 'pkg:app/cls.dart');
      final s = Subject(name: cls.name, filePath: cls.filePath, element: cls);
      expect(rules.first.predicate.evaluate(s, _ctx()).message,
          contains('@singleton'));
    });
  });
}
