import 'package:test/test.dart';
import 'package:yaml/yaml.dart';
import 'package:dartunit/dartunit.dart';
import 'package:dartunit/presets/layer_cannot_depend_on_preset.dart';

YamlMap _cfg(String yaml) => loadYaml(yaml) as YamlMap;

AnalysisContext _ctx() => AnalysisContext(
    classes: [], files: [], dependencyGraph: DependencyGraph(), projectRoot: '/p');

void main() {
  final preset = LayerCannotDependOnPreset();

  group('LayerCannotDependOnPreset — contract', () {
    test('presetId is correct', () {
      expect(preset.presetId, equals('layer/cannot-depend-on'));
    });

    test('generates one rule per folder in to list', () {
      final rules = preset.expand(_cfg('from: lib/domain\nto: [lib/data, lib/ui]'));
      expect(rules, hasLength(2));
    });

    test('works when to is a single string', () {
      final rules = preset.expand(_cfg('from: lib/domain\nto: lib/data'));
      expect(rules, hasLength(1));
    });
  });

  group('LayerCannotDependOnPreset — rule properties', () {
    test('rule selector is scoped to the from folder', () {
      final rules = preset.expand(_cfg('from: lib/domain\nto: lib/data'));
      final sel = rules.first.selector as ClassSelector;
      expect(sel.folder, equals('lib/domain'));
    });

    test('rule id encodes from and to', () {
      final rules = preset.expand(_cfg('from: lib/domain\nto: lib/data'));
      expect(rules.first.id, contains('domain'));
      expect(rules.first.id, contains('data'));
    });

    test('severity defaults to error', () {
      final rules = preset.expand(_cfg('from: lib/domain\nto: lib/data'));
      expect(rules.first.severity, equals(RuleSeverity.error));
    });

    test('severity can be overridden', () {
      final rules = preset.expand(
          _cfg('from: lib/domain\nto: lib/data\nseverity: warning'));
      expect(rules.first.severity, equals(RuleSeverity.warning));
    });

    test('exceptions forwarded to selector excludeNames', () {
      final rules = preset.expand(_cfg(
          'from: lib/domain\nto: lib/data\nexceptions: [LegacyAdapter]'));
      final sel = rules.first.selector as ClassSelector;
      expect(sel.excludeNames, contains('LegacyAdapter'));
    });
  });

  group('LayerCannotDependOnPreset — predicate evaluation', () {
    test('rule passes when domain class does not import data layer', () {
      final rules = preset.expand(_cfg('from: lib/domain\nto: lib/data'));
      final cls = AnalyzedClass(
          name: 'PureEntity',
          filePath: '/p/lib/domain/entity.dart',
          packagePath: 'pkg:app/entity.dart',
          imports: ['/p/lib/domain/value_object.dart']);
      final s = Subject(name: cls.name, filePath: cls.filePath, element: cls);
      expect(rules.first.predicate.evaluate(s, _ctx()).passed, isTrue);
    });

    test('rule fails when domain class imports from data layer', () {
      final rules = preset.expand(_cfg('from: lib/domain\nto: lib/data'));
      final cls = AnalyzedClass(
          name: 'DirtyEntity',
          filePath: '/p/lib/domain/entity.dart',
          packagePath: 'pkg:app/entity.dart',
          imports: ['/p/lib/data/repo.dart']);
      final s = Subject(name: cls.name, filePath: cls.filePath, element: cls);
      expect(rules.first.predicate.evaluate(s, _ctx()).passed, isFalse);
    });

    test('fail message contains the forbidden folder', () {
      final rules = preset.expand(_cfg('from: lib/domain\nto: lib/data'));
      final cls = AnalyzedClass(
          name: 'BadEntity',
          filePath: '/p/lib/domain/entity.dart',
          packagePath: 'pkg:app/entity.dart',
          imports: ['/p/lib/data/source.dart']);
      final s = Subject(name: cls.name, filePath: cls.filePath, element: cls);
      expect(rules.first.predicate.evaluate(s, _ctx()).message,
          contains('lib/data'));
    });
  });
}
