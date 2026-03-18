import 'package:dartunit/core/entities/subject.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';
import 'package:dartunit/dartunit.dart';
import 'package:dartunit/presets/class_size_limit_preset.dart';

YamlMap _cfg(String yaml) => loadYaml(yaml) as YamlMap;

AnalysisContext _ctx() => AnalysisContext(
    classes: [], files: [], dependencyGraph: DependencyGraph(), projectRoot: '/p');

void main() {
  final preset = ClassSizeLimitPreset();

  group('ClassSizeLimitPreset — contract', () {
    test('presetId is correct', () {
      expect(preset.presetId, equals('metrics/class-size-limit'));
    });

    test('generates one rule when only max_methods is set', () {
      final rules =
          preset.expand(_cfg('max_methods: 10\nfolders:\n  - lib'));
      expect(rules, hasLength(1));
    });

    test('generates one rule when only max_fields is set', () {
      final rules = preset.expand(_cfg('max_fields: 5\nfolders:\n  - lib'));
      expect(rules, hasLength(1));
    });

    test('generates two rules when both max_methods and max_fields are set', () {
      final rules = preset.expand(
          _cfg('max_methods: 10\nmax_fields: 5\nfolders:\n  - lib'));
      expect(rules, hasLength(2));
    });

    test('generates two rules per folder (methods + fields)', () {
      final rules = preset.expand(
          _cfg('max_methods: 5\nmax_fields: 3\nfolders:\n  - lib/bloc\n  - lib/service'));
      expect(rules, hasLength(4)); // 2 folders × 2 metrics
    });
  });

  group('ClassSizeLimitPreset — applies globally when no folders', () {
    test('generates rules for all classes when folders list is empty', () {
      final rules =
          preset.expand(_cfg('max_methods: 10\nfolders: []'));
      expect(rules, hasLength(1));
      final sel = rules.first.selector as ClassSelector;
      expect(sel.folder, isNull);
    });
  });

  group('ClassSizeLimitPreset — predicate evaluation', () {
    test('method-limit rule passes when class has fewer methods than limit', () {
      final rules =
          preset.expand(_cfg('max_methods: 3\nfolders:\n  - lib/service'));
      final methodsRule = rules.first;
      final cls = AnalyzedClass(
          name: 'SmallService',
          filePath: '/p/lib/service/small.dart',
          packagePath: 'pkg:app/small.dart',
          methods: [
            const AnalyzedMethod(name: 'a', returnType: 'void'),
            const AnalyzedMethod(name: 'b', returnType: 'void'),
          ]);
      final s = Subject(name: cls.name, filePath: cls.filePath, element: cls);
      expect(methodsRule.predicate.evaluate(s, _ctx()).passed, isTrue);
    });

    test('method-limit rule fails when class exceeds limit', () {
      final rules =
          preset.expand(_cfg('max_methods: 1\nfolders:\n  - lib/service'));
      final cls = AnalyzedClass(
          name: 'BigService',
          filePath: '/p/lib/service/big.dart',
          packagePath: 'pkg:app/big.dart',
          methods: [
            const AnalyzedMethod(name: 'a', returnType: 'void'),
            const AnalyzedMethod(name: 'b', returnType: 'void'),
          ]);
      final s = Subject(name: cls.name, filePath: cls.filePath, element: cls);
      expect(rules.first.predicate.evaluate(s, _ctx()).passed, isFalse);
    });

    test('severity can be overridden', () {
      final rules = preset.expand(
          _cfg('max_methods: 5\nfolders:\n  - lib\nseverity: warning'));
      expect(rules.first.severity, equals(RuleSeverity.warning));
    });
  });
}
