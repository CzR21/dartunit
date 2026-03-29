import 'package:dartunit/core/entities/subject.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';
import 'package:dartunit/dartunit.dart';
import 'package:dartunit/presets/no_circular_dependencies_preset.dart';

YamlMap _cfg(String yaml) => loadYaml(yaml) as YamlMap;

void main() {
  final preset = NoCircularDependenciesPreset();

  group('NoCircularDependenciesPreset — contract', () {
    test('presetId is correct', () {
      expect(preset.presetId, equals('structure/no-circular-dependencies'));
    });

    test('generates exactly one rule', () {
      expect(preset.expand(_cfg('{}')), hasLength(1));
    });

    test('rule description is fixed', () {
      expect(preset.expand(_cfg('{}')).first.description,
          equals('No circular dependencies allowed'));
    });
  });

  group('NoCircularDependenciesPreset — rule properties', () {
    test('selector has no folder restriction (applies to all classes)', () {
      final sel = preset.expand(_cfg('{}')).first.selector as ClassSelector;
      expect(sel.folder, isNull);
    });

    test('severity defaults to error', () {
      expect(preset.expand(_cfg('{}')).first.severity,
          equals(RuleSeverity.error));
    });

    test('severity can be overridden to warning', () {
      expect(preset.expand(_cfg('severity: warning')).first.severity,
          equals(RuleSeverity.warning));
    });
  });

  group('NoCircularDependenciesPreset — predicate evaluation', () {
    // HasCircularDependencyPredicate semantics:
    //   PASSES → file has NO cycles (clean — no violation)
    //   FAILS  → file IS in a cycle (violation detected)
    // The preset uses it directly (no NotPredicate wrapper).

    test('rule passes (no violation) when file has no circular dependency', () {
      final rule = preset.expand(_cfg('{}')).first;
      final ctx = AnalysisContext(
          classes: [],
          files: [],
          dependencyGraph: DependencyGraph(),
          projectRoot: '/p');
      final cls = AnalyzedClass(
          name: 'CleanClass',
          filePath: '/p/lib/clean.dart',
          packagePath: 'pkg:app/clean.dart');
      final s = Subject(name: cls.name, filePath: cls.filePath, element: cls);
      expect(rule.predicate.analyze(s, ctx).passed, isTrue);
    });

    test('rule fails (violation) when file is in a cycle', () {
      final rule = preset.expand(_cfg('{}')).first;
      final graph = DependencyGraph()
        ..addEdge('/p/a.dart', '/p/b.dart')
        ..addEdge('/p/b.dart', '/p/a.dart');
      final ctx = AnalysisContext(
          classes: [], files: [], dependencyGraph: graph, projectRoot: '/p');
      final cls = AnalyzedClass(
          name: 'CycleA',
          filePath: '/p/a.dart',
          packagePath: 'pkg:app/a.dart');
      final s = Subject(name: cls.name, filePath: cls.filePath, element: cls);
      expect(rule.predicate.analyze(s, ctx).passed, isFalse);
    });

    test('fail message describes the cycle path', () {
      final rule = preset.expand(_cfg('{}')).first;
      final graph = DependencyGraph()
        ..addEdge('/p/x.dart', '/p/y.dart')
        ..addEdge('/p/y.dart', '/p/x.dart');
      final ctx = AnalysisContext(
          classes: [], files: [], dependencyGraph: graph, projectRoot: '/p');
      final cls = AnalyzedClass(
          name: 'X', filePath: '/p/x.dart', packagePath: 'pkg:app/x.dart');
      final s = Subject(name: cls.name, filePath: cls.filePath, element: cls);
      final result = rule.predicate.analyze(s, ctx);
      expect(result.passed, isFalse);
      expect(result.message, contains('/p/x.dart'));
    });
  });
}
