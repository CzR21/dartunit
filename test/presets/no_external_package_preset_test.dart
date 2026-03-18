import 'package:dartunit/core/entities/subject.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';
import 'package:dartunit/dartunit.dart';
import 'package:dartunit/presets/no_external_package_preset.dart';

YamlMap _cfg(String yaml) => loadYaml(yaml) as YamlMap;

AnalysisContext _ctx() => AnalysisContext(
    classes: [], files: [], dependencyGraph: DependencyGraph(), projectRoot: '/p');

void main() {
  final preset = NoExternalPackagePreset();

  group('NoExternalPackagePreset — contract', () {
    test('presetId is correct', () {
      expect(preset.presetId, equals('dependency/no-external-package'));
    });

    test('generates one rule per (folder, package) combination', () {
      final rules = preset.expand(_cfg('''
packages:
  - http
  - dio
folders:
  - lib/domain
  - lib/bloc
'''));
      expect(rules, hasLength(4)); // 2 folders × 2 packages
    });

    test('generates one rule for single folder + package', () {
      final rules = preset.expand(_cfg(
          'packages:\n  - http\nfolders:\n  - lib/domain'));
      expect(rules, hasLength(1));
    });

    test('generates zero rules when packages list is empty', () {
      final rules = preset.expand(
          _cfg('packages: []\nfolders:\n  - lib/domain'));
      expect(rules, isEmpty);
    });
  });

  group('NoExternalPackagePreset — rule properties', () {
    test('rule description contains forbidden package and folder', () {
      final rules = preset.expand(
          _cfg('packages:\n  - http\nfolders:\n  - lib/domain'));
      expect(rules.first.description, contains('http'));
      expect(rules.first.description, contains('lib/domain'));
    });

    test('severity defaults to error', () {
      final rules = preset.expand(
          _cfg('packages:\n  - http\nfolders:\n  - lib/domain'));
      expect(rules.first.severity, equals(RuleSeverity.error));
    });

    test('severity can be overridden', () {
      final rules = preset.expand(
          _cfg('packages:\n  - http\nfolders:\n  - lib/domain\nseverity: warning'));
      expect(rules.first.severity, equals(RuleSeverity.warning));
    });
  });

  group('NoExternalPackagePreset — predicate evaluation', () {
    test('rule passes when domain class does not import forbidden package', () {
      final rules = preset.expand(
          _cfg('packages:\n  - http\nfolders:\n  - lib/domain'));
      final cls = AnalyzedClass(
          name: 'PureEntity',
          filePath: '/p/lib/domain/entity.dart',
          packagePath: 'pkg:app/entity.dart',
          imports: ['package:equatable/equatable.dart']);
      final s = Subject(name: cls.name, filePath: cls.filePath, element: cls);
      expect(rules.first.predicate.evaluate(s, _ctx()).passed, isTrue);
    });

    test('rule fails when domain class imports forbidden package', () {
      final rules = preset.expand(
          _cfg('packages:\n  - http\nfolders:\n  - lib/domain'));
      final cls = AnalyzedClass(
          name: 'DirtyEntity',
          filePath: '/p/lib/domain/entity.dart',
          packagePath: 'pkg:app/entity.dart',
          imports: ['package:http/http.dart']);
      final s = Subject(name: cls.name, filePath: cls.filePath, element: cls);
      expect(rules.first.predicate.evaluate(s, _ctx()).passed, isFalse);
    });

    test('fail message contains the forbidden package name', () {
      final rules = preset.expand(
          _cfg('packages:\n  - dio\nfolders:\n  - lib/domain'));
      final cls = AnalyzedClass(
          name: 'BadEntity',
          filePath: '/p/lib/domain/entity.dart',
          packagePath: 'pkg:app/entity.dart',
          imports: ['package:dio/dio.dart']);
      final s = Subject(name: cls.name, filePath: cls.filePath, element: cls);
      expect(rules.first.predicate.evaluate(s, _ctx()).message,
          contains('dio'));
    });
  });
}
