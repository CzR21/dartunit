import 'package:dartunit/core/entities/subject.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';
import 'package:dartunit/dartunit.dart';
import 'package:dartunit/presets/layer_can_only_depend_on_preset.dart';

YamlMap _cfg(String yaml) => loadYaml(yaml) as YamlMap;

AnalysisContext _ctx() => AnalysisContext(
    classes: [], files: [], dependencyGraph: DependencyGraph(), projectRoot: '/p');

void main() {
  final preset = LayerCanOnlyDependOnPreset();

  group('LayerCanOnlyDependOnPreset — contract', () {
    test('presetId is correct', () {
      expect(preset.presetId, equals('layer/can-only-depend-on'));
    });

    test('generates exactly one rule', () {
      final rules = preset.expand(
          _cfg('layer: lib/domain\nallowed: [lib/domain, lib/shared]'));
      expect(rules, hasLength(1));
    });

    test('rule description contains the layer name', () {
      final rules = preset.expand(
          _cfg('layer: lib/domain\nallowed: [lib/domain]'));
      expect(rules.first.description, contains('domain'));
    });
  });

  group('LayerCanOnlyDependOnPreset — rule properties', () {
    test('selector is scoped to the layer folder', () {
      final rules = preset.expand(
          _cfg('layer: lib/domain\nallowed: [lib/domain]'));
      final sel = rules.first.selector as ClassSelector;
      expect(sel.folder, equals('lib/domain'));
    });

    test('severity defaults to error', () {
      final rules = preset.expand(
          _cfg('layer: lib/domain\nallowed: [lib/domain]'));
      expect(rules.first.severity, equals(RuleSeverity.error));
    });

    test('severity can be overridden', () {
      final rules = preset.expand(
          _cfg('layer: lib/domain\nallowed: [lib/domain]\nseverity: warning'));
      expect(rules.first.severity, equals(RuleSeverity.warning));
    });
  });

  group('LayerCanOnlyDependOnPreset — predicate evaluation', () {
    test('rule passes when all imports are from allowed folders', () {
      final rules = preset.expand(
          _cfg('layer: lib/domain\nallowed:\n  - lib/domain\n  - lib/shared'));
      final cls = AnalyzedClass(
          name: 'GetUser',
          filePath: '/p/lib/domain/use_case.dart',
          packagePath: 'pkg:app/use_case.dart',
          imports: ['/p/lib/domain/user.dart', '/p/lib/shared/utils.dart']);
      final s = Subject(name: cls.name, filePath: cls.filePath, element: cls);
      expect(rules.first.predicate.analyze(s, _ctx()).passed, isTrue);
    });

    test('rule fails when an import is from a forbidden folder', () {
      final rules = preset.expand(
          _cfg('layer: lib/domain\nallowed:\n  - lib/domain'));
      final cls = AnalyzedClass(
          name: 'DirtyUseCase',
          filePath: '/p/lib/domain/use_case.dart',
          packagePath: 'pkg:app/use_case.dart',
          imports: ['/p/lib/data/repo.dart']);
      final s = Subject(name: cls.name, filePath: cls.filePath, element: cls);
      expect(rules.first.predicate.analyze(s, _ctx()).passed, isFalse);
    });

    test('fail message names the forbidden import path', () {
      final rules = preset.expand(
          _cfg('layer: lib/domain\nallowed:\n  - lib/domain'));
      final cls = AnalyzedClass(
          name: 'DirtyClass',
          filePath: '/p/lib/domain/cls.dart',
          packagePath: 'pkg:app/cls.dart',
          imports: ['/p/lib/ui/page.dart']);
      final s = Subject(name: cls.name, filePath: cls.filePath, element: cls);
      expect(rules.first.predicate.analyze(s, _ctx()).message,
          contains('lib/ui/page.dart'));
    });
  });
}
