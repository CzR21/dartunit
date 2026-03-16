import 'package:test/test.dart';
import 'package:yaml/yaml.dart';
import 'package:dartunit/dartunit.dart';
import 'package:dartunit/presets/layer_layered_architecture_preset.dart';

YamlMap _cfg(String yaml) => loadYaml(yaml) as YamlMap;

const _threeLayerYaml = '''
layers:
  - name: ui
    folder: lib/ui
    can_access: [lib/bloc, lib/domain]
  - name: bloc
    folder: lib/bloc
    can_access: [lib/domain]
  - name: domain
    folder: lib/domain
    can_access: []
''';

void main() {
  final preset = LayerLayeredArchitecturePreset();

  group('LayerLayeredArchitecturePreset — contract', () {
    test('presetId is correct', () {
      expect(preset.presetId, equals('layer/layered-architecture'));
    });

    test('generates forbidden-pair rules for all inaccessible combinations', () {
      // 3 layers: 6 ordered pairs, minus 3 self-pairs = 3 allowed access,
      // leaving 3 forbidden pairs → 3 rules
      final rules = preset.expand(_cfg(_threeLayerYaml));
      // ui can't access nothing (allowed: bloc, domain)
      // bloc can't access: ui (1 rule)
      // domain can't access: ui, bloc (2 rules)
      expect(rules, hasLength(3));
    });

    test('does not generate a rule forbidding ui accessing bloc (allowed pair)', () {
      final rules = preset.expand(_cfg(_threeLayerYaml));
      // ui can_access bloc → no rule with id pattern "lib_ui_no_lib_bloc"
      // Rule ID format: PRESET_layered_{from}_no_{to}
      final ids = rules.map((r) => r.id).toList();
      expect(ids.where((id) => id.contains('lib_ui_no_lib_bloc')), isEmpty);
    });

    test('generates zero rules when all pairs are allowed', () {
      final rules = preset.expand(_cfg('''
layers:
  - name: a
    folder: lib/a
    can_access: [lib/b]
  - name: b
    folder: lib/b
    can_access: [lib/a]
'''));
      // a→b allowed, b→a allowed → no forbidden rules
      expect(rules, isEmpty);
    });
  });

  group('LayerLayeredArchitecturePreset — rule properties', () {
    test('each rule selector is scoped to the from-layer folder', () {
      final rules = preset.expand(_cfg(_threeLayerYaml));
      // domain cannot access ui or bloc
      final domainRules =
          rules.where((r) => (r.selector as ClassSelector).folder == 'lib/domain').toList();
      expect(domainRules, hasLength(2));
    });

    test('severity defaults to error', () {
      final rules = preset.expand(_cfg(_threeLayerYaml));
      for (final r in rules) {
        expect(r.severity, equals(RuleSeverity.error));
      }
    });

    test('severity can be overridden globally', () {
      final rules =
          preset.expand(_cfg('severity: warning\n$_threeLayerYaml'));
      for (final r in rules) {
        expect(r.severity, equals(RuleSeverity.warning));
      }
    });
  });

  group('LayerLayeredArchitecturePreset — predicate evaluation', () {
    final ctx = AnalysisContext(
        classes: [], files: [], dependencyGraph: DependencyGraph(), projectRoot: '/p');

    test('domain class passes when it imports nothing from ui', () {
      final rules = preset.expand(_cfg(_threeLayerYaml));
      final domainRule = rules.firstWhere(
          (r) => r.id.contains('domain') && r.id.contains('ui'));
      final cls = AnalyzedClass(
          name: 'PureEntity',
          filePath: '/p/lib/domain/entity.dart',
          packagePath: 'pkg:app/entity.dart',
          imports: []);
      final s = Subject(name: cls.name, filePath: cls.filePath, element: cls);
      expect(domainRule.predicate.evaluate(s, ctx).passed, isTrue);
    });

    test('domain class fails when it imports from ui layer', () {
      final rules = preset.expand(_cfg(_threeLayerYaml));
      final domainRule = rules.firstWhere(
          (r) => r.id.contains('domain') && r.id.contains('ui'));
      final cls = AnalyzedClass(
          name: 'BadEntity',
          filePath: '/p/lib/domain/entity.dart',
          packagePath: 'pkg:app/entity.dart',
          imports: ['/p/lib/ui/page.dart']);
      final s = Subject(name: cls.name, filePath: cls.filePath, element: cls);
      expect(domainRule.predicate.evaluate(s, ctx).passed, isFalse);
    });

    test('exceptions are excluded via selector excludeNames', () {
      final rules = preset.expand(_cfg('exceptions: [LegacyGod]\n$_threeLayerYaml'));
      for (final r in rules) {
        expect((r.selector as ClassSelector).excludeNames,
            contains('LegacyGod'));
      }
    });
  });
}
