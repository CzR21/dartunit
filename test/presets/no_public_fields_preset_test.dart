import 'package:dartunit/core/entities/subject.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';
import 'package:dartunit/dartunit.dart';
import 'package:dartunit/presets/no_public_fields_preset.dart';

YamlMap _cfg(String yaml) => loadYaml(yaml) as YamlMap;

AnalysisContext _ctx() => AnalysisContext(
    classes: [], files: [], dependencyGraph: DependencyGraph(), projectRoot: '/p');

void main() {
  final preset = NoPublicFieldsPreset();

  group('NoPublicFieldsPreset — contract', () {
    test('presetId is correct', () {
      expect(preset.presetId, equals('structure/no-public-fields'));
    });

    test('generates one rule per folder', () {
      final rules =
          preset.expand(_cfg('folders:\n  - lib/service\n  - lib/bloc'));
      expect(rules, hasLength(2));
    });

    test('generates zero rules when folders list is empty', () {
      expect(preset.expand(_cfg('folders: []')), isEmpty);
    });
  });

  group('NoPublicFieldsPreset — rule properties', () {
    test('selector is scoped to folder', () {
      final rules = preset.expand(_cfg('folders:\n  - lib/service'));
      final sel = rules.first.selector as ClassSelector;
      expect(sel.folder, equals('lib/service'));
    });

    test('severity defaults to error', () {
      final rules = preset.expand(_cfg('folders:\n  - lib/service'));
      expect(rules.first.severity, equals(RuleSeverity.error));
    });

    test('severity can be overridden', () {
      final rules =
          preset.expand(_cfg('severity: warning\nfolders:\n  - lib/service'));
      expect(rules.first.severity, equals(RuleSeverity.warning));
    });
  });

  group('NoPublicFieldsPreset — predicate evaluation', () {
    test('rule passes when all instance fields are private', () {
      final rules = preset.expand(_cfg('folders:\n  - lib/service'));
      final cls = AnalyzedClass(
          name: 'UserService',
          filePath: '/p/lib/service/user_service.dart',
          packagePath: 'pkg:app/user_service.dart',
          fields: [
            const AnalyzedField(name: '_repo', type: 'UserRepository', isFinal: true),
          ]);
      final s = Subject(name: cls.name, filePath: cls.filePath, element: cls);
      expect(rules.first.predicate.evaluate(s, _ctx()).passed, isTrue);
    });

    test('rule fails when a public instance field is exposed', () {
      final rules = preset.expand(_cfg('folders:\n  - lib/service'));
      final cls = AnalyzedClass(
          name: 'LeakyService',
          filePath: '/p/lib/service/leaky.dart',
          packagePath: 'pkg:app/leaky.dart',
          fields: [
            const AnalyzedField(name: 'config', type: 'Config'),
          ]);
      final s = Subject(name: cls.name, filePath: cls.filePath, element: cls);
      expect(rules.first.predicate.evaluate(s, _ctx()).passed, isFalse);
    });

    test('fail message contains public field name', () {
      final rules = preset.expand(_cfg('folders:\n  - lib/service'));
      final cls = AnalyzedClass(
          name: 'Cls',
          filePath: '/p/lib/service/cls.dart',
          packagePath: 'pkg:app/cls.dart',
          fields: [const AnalyzedField(name: 'timeout', type: 'int')]);
      final s = Subject(name: cls.name, filePath: cls.filePath, element: cls);
      expect(rules.first.predicate.evaluate(s, _ctx()).message,
          contains('timeout'));
    });
  });
}
