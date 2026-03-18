import 'package:dartunit/core/entities/subject.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';
import 'package:dartunit/dartunit.dart';
import 'package:dartunit/presets/must_be_immutable_preset.dart';

YamlMap _cfg(String yaml) => loadYaml(yaml) as YamlMap;

AnalysisContext _ctx() => AnalysisContext(
    classes: [], files: [], dependencyGraph: DependencyGraph(), projectRoot: '/p');

void main() {
  final preset = MustBeImmutablePreset();

  group('MustBeImmutablePreset — contract', () {
    test('presetId is correct', () {
      expect(preset.presetId, equals('structure/must-be-immutable'));
    });

    test('generates one rule per folder', () {
      final rules =
          preset.expand(_cfg('folders:\n  - lib/domain\n  - lib/models'));
      expect(rules, hasLength(2));
    });

    test('generates zero rules when folders list is empty', () {
      expect(preset.expand(_cfg('folders: []')), isEmpty);
    });
  });

  group('MustBeImmutablePreset — rule properties', () {
    test('selector is scoped to the folder', () {
      final rules = preset.expand(_cfg('folders:\n  - lib/domain'));
      final sel = rules.first.selector as ClassSelector;
      expect(sel.folder, equals('lib/domain'));
    });

    test('severity defaults to error', () {
      final rules = preset.expand(_cfg('folders:\n  - lib/domain'));
      expect(rules.first.severity, equals(RuleSeverity.error));
    });

    test('severity can be overridden to warning', () {
      final rules = preset.expand(
          _cfg('severity: warning\nfolders:\n  - lib/domain'));
      expect(rules.first.severity, equals(RuleSeverity.warning));
    });
  });

  group('MustBeImmutablePreset — predicate evaluation', () {
    test('rule passes when all fields are final', () {
      final rules = preset.expand(_cfg('folders:\n  - lib/domain'));
      final cls = AnalyzedClass(
          name: 'UserEntity',
          filePath: '/p/lib/domain/user.dart',
          packagePath: 'pkg:app/user.dart',
          fields: [
            const AnalyzedField(name: 'id', type: 'String', isFinal: true),
            const AnalyzedField(name: 'name', type: 'String', isFinal: true),
          ]);
      final s = Subject(name: cls.name, filePath: cls.filePath, element: cls);
      expect(rules.first.predicate.evaluate(s, _ctx()).passed, isTrue);
    });

    test('rule fails when a mutable field is present', () {
      final rules = preset.expand(_cfg('folders:\n  - lib/domain'));
      final cls = AnalyzedClass(
          name: 'MutableEntity',
          filePath: '/p/lib/domain/mutable.dart',
          packagePath: 'pkg:app/mutable.dart',
          fields: [
            const AnalyzedField(name: 'count', type: 'int'),
          ]);
      final s = Subject(name: cls.name, filePath: cls.filePath, element: cls);
      expect(rules.first.predicate.evaluate(s, _ctx()).passed, isFalse);
    });

    test('fail message contains mutable field name', () {
      final rules = preset.expand(_cfg('folders:\n  - lib/domain'));
      final cls = AnalyzedClass(
          name: 'Cls',
          filePath: '/p/lib/domain/cls.dart',
          packagePath: 'pkg:app/cls.dart',
          fields: [const AnalyzedField(name: 'total', type: 'double')]);
      final s = Subject(name: cls.name, filePath: cls.filePath, element: cls);
      expect(rules.first.predicate.evaluate(s, _ctx()).message,
          contains('total'));
    });
  });
}
