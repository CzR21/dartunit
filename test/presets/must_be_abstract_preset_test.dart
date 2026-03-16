import 'package:test/test.dart';
import 'package:yaml/yaml.dart';
import 'package:dartunit/dartunit.dart';
import 'package:dartunit/presets/must_be_abstract_preset.dart';

YamlMap _cfg(String yaml) => loadYaml(yaml) as YamlMap;

AnalysisContext _ctx() => AnalysisContext(
    classes: [], files: [], dependencyGraph: DependencyGraph(), projectRoot: '/p');

void main() {
  final preset = MustBeAbstractPreset();

  group('MustBeAbstractPreset — contract', () {
    test('presetId is correct', () {
      expect(preset.presetId, equals('structure/must-be-abstract'));
    });

    test('generates one rule per folder', () {
      final rules =
          preset.expand(_cfg('folders:\n  - lib/repository\n  - lib/service'));
      expect(rules, hasLength(2));
    });

    test('generates zero rules when folders list is empty', () {
      final rules = preset.expand(_cfg('folders: []'));
      expect(rules, isEmpty);
    });
  });

  group('MustBeAbstractPreset — rule properties', () {
    test('selector is scoped to the folder', () {
      final rules = preset.expand(_cfg('folders:\n  - lib/repository'));
      final sel = rules.first.selector as ClassSelector;
      expect(sel.folder, equals('lib/repository'));
    });

    test('severity defaults to error', () {
      final rules = preset.expand(_cfg('folders:\n  - lib/repository'));
      expect(rules.first.severity, equals(RuleSeverity.error));
    });

    test('severity can be overridden', () {
      final rules = preset.expand(
          _cfg('severity: warning\nfolders:\n  - lib/repository'));
      expect(rules.first.severity, equals(RuleSeverity.warning));
    });
  });

  group('MustBeAbstractPreset — predicate evaluation', () {
    test('rule passes for abstract class', () {
      final rules = preset.expand(_cfg('folders:\n  - lib/repository'));
      final cls = AnalyzedClass(
          name: 'UserRepository',
          filePath: '/p/lib/repository/user_repository.dart',
          packagePath: 'pkg:app/user_repository.dart',
          isAbstract: true);
      final s = Subject(name: cls.name, filePath: cls.filePath, element: cls);
      expect(rules.first.predicate.evaluate(s, _ctx()).passed, isTrue);
    });

    test('rule fails for concrete class', () {
      final rules = preset.expand(_cfg('folders:\n  - lib/repository'));
      final cls = AnalyzedClass(
          name: 'ConcreteRepo',
          filePath: '/p/lib/repository/concrete_repo.dart',
          packagePath: 'pkg:app/concrete_repo.dart',
          isAbstract: false);
      final s = Subject(name: cls.name, filePath: cls.filePath, element: cls);
      expect(rules.first.predicate.evaluate(s, _ctx()).passed, isFalse);
    });

    test('fail message contains "abstract"', () {
      final rules = preset.expand(_cfg('folders:\n  - lib/repository'));
      final cls = AnalyzedClass(
          name: 'ConcreteRepo',
          filePath: '/p/lib/repository/concrete_repo.dart',
          packagePath: 'pkg:app/concrete_repo.dart');
      final s = Subject(name: cls.name, filePath: cls.filePath, element: cls);
      expect(rules.first.predicate.evaluate(s, _ctx()).message,
          contains('abstract'));
    });
  });
}
