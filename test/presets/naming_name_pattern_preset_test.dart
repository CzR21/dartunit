import 'package:test/test.dart';
import 'package:yaml/yaml.dart';
import 'package:dartunit/dartunit.dart';
import 'package:dartunit/presets/naming_name_pattern_preset.dart';

YamlMap _cfg(String yaml) => loadYaml(yaml) as YamlMap;

AnalysisContext _ctx() => AnalysisContext(
    classes: [], files: [], dependencyGraph: DependencyGraph(), projectRoot: '/p');

void main() {
  final preset = NamingNamePatternPreset();

  group('NamingNamePatternPreset — contract', () {
    test('presetId is correct', () {
      expect(preset.presetId, equals('naming/name-pattern'));
    });

    test('generates one rule per folder', () {
      final rules = preset.expand(_cfg('''
pattern: ".*Bloc\$"
folders:
  - lib/bloc
  - lib/presentation/bloc
'''));
      expect(rules, hasLength(2));
    });

    test('generates zero rules when folders list is empty', () {
      final rules = preset.expand(_cfg("pattern: '.*Bloc\$'\nfolders: []"));
      expect(rules, isEmpty);
    });
  });

  group('NamingNamePatternPreset — rule properties', () {
    test('rule description contains folder and pattern', () {
      final rules = preset.expand(_cfg("pattern: '.*Bloc\$'\nfolders:\n  - lib/bloc"));
      expect(rules.first.description, contains('lib/bloc'));
      expect(rules.first.description, contains(r'.*Bloc$'));
    });

    test('rule selector is scoped to the folder', () {
      final rules = preset.expand(_cfg("pattern: '.*Service\$'\nfolders:\n  - lib/service"));
      final sel = rules.first.selector as ClassSelector;
      expect(sel.folder, equals('lib/service'));
    });

    test('severity defaults to error', () {
      final rules = preset.expand(_cfg("pattern: '.*Bloc\$'\nfolders:\n  - lib/bloc"));
      expect(rules.first.severity, equals(RuleSeverity.error));
    });
  });

  group('NamingNamePatternPreset — predicate evaluation', () {
    test('generated rule passes for matching class name', () {
      final rules = preset.expand(_cfg("pattern: '.*Bloc\$'\nfolders:\n  - lib/bloc"));
      final cls = AnalyzedClass(
          name: 'CartBloc',
          filePath: '/p/lib/bloc/cart_bloc.dart',
          packagePath: 'pkg:app/cart_bloc.dart');
      final s = Subject(name: cls.name, filePath: cls.filePath, element: cls);
      expect(rules.first.predicate.evaluate(s, _ctx()).passed, isTrue);
    });

    test('generated rule fails for non-matching class name', () {
      final rules = preset.expand(_cfg("pattern: '.*Bloc\$'\nfolders:\n  - lib/bloc"));
      final cls = AnalyzedClass(
          name: 'CartPage',
          filePath: '/p/lib/bloc/cart_page.dart',
          packagePath: 'pkg:app/cart_page.dart');
      final s = Subject(name: cls.name, filePath: cls.filePath, element: cls);
      expect(rules.first.predicate.evaluate(s, _ctx()).passed, isFalse);
    });

    test('exceptions are excluded from selector', () {
      final rules = preset.expand(_cfg(
          "pattern: '.*Bloc\$'\nfolders:\n  - lib/bloc\nexceptions:\n  - LegacyBloc"));
      final sel = rules.first.selector as ClassSelector;
      expect(sel.excludeNames, contains('LegacyBloc'));
    });
  });
}
