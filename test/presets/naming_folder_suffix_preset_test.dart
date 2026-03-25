import 'package:dartunit/core/entities/subject.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';
import 'package:dartunit/dartunit.dart';
import 'package:dartunit/presets/naming_folder_suffix_preset.dart';

YamlMap _cfg(String yaml) => loadYaml(yaml) as YamlMap;

void main() {
  final preset = NamingFolderSuffixPreset();

  group('NamingFolderSuffixPreset — contract', () {
    test('presetId is correct', () {
      expect(preset.presetId, equals('naming/folder-name-suffix'));
    });

    test('generates one rule per folder', () {
      final rules = preset.expand(_cfg('folders:\n  - lib/service\n  - lib/repository'));
      expect(rules, hasLength(2));
    });

    test('generates zero rules when folders list is empty', () {
      final rules = preset.expand(_cfg('folders: []'));
      expect(rules, isEmpty);
    });
  });

  group('NamingFolderSuffixPreset — rule properties', () {
    test('rule description contains folder and capitalised suffix', () {
      final rules = preset.expand(_cfg('folders:\n  - lib/service'));
      expect(rules.first.description, contains('lib/service'));
      expect(rules.first.description, contains('Service'));
    });

    test('rule selector is scoped to the folder', () {
      final rules = preset.expand(_cfg('folders:\n  - lib/bloc'));
      final sel = rules.first.selector as ClassSelector;
      expect(sel.folder, equals('lib/bloc'));
    });

    test('severity defaults to error', () {
      final rules = preset.expand(_cfg('folders:\n  - lib/service'));
      expect(rules.first.severity, equals(RuleSeverity.error));
    });

    test('severity can be overridden to warning', () {
      final rules = preset.expand(
          _cfg('severity: warning\nfolders:\n  - lib/service'));
      expect(rules.first.severity, equals(RuleSeverity.warning));
    });

    test('exceptions are forwarded to selector excludeNames', () {
      final rules = preset.expand(_cfg(
          'folders:\n  - lib/service\nexceptions:\n  - BaseService'));
      final sel = rules.first.selector as ClassSelector;
      expect(sel.excludeNames, contains('BaseService'));
    });
  });

  group('NamingFolderSuffixPreset — predicate evaluation', () {
    test('generated rule passes for class matching folder suffix', () {
      final rules = preset.expand(_cfg('folders:\n  - lib/service'));
      final cls = AnalyzedClass(
        name: 'UserService',
        filePath: '/project/lib/service/user_service.dart',
        packagePath: 'package:app/lib/service/user_service.dart',
      );
      final subject = Subject(name: cls.name, filePath: cls.filePath, element: cls);
      final ctx = AnalysisContext(
          classes: [], files: [], dependencyGraph: DependencyGraph(), projectRoot: '/project');
      final result = rules.first.predicate.analyze(subject, ctx);
      expect(result.passed, isTrue);
    });

    test('generated rule fails for class not matching folder suffix', () {
      final rules = preset.expand(_cfg('folders:\n  - lib/service'));
      final cls = AnalyzedClass(
        name: 'UserHelper',
        filePath: '/project/lib/service/user_helper.dart',
        packagePath: 'package:app/lib/service/user_helper.dart',
      );
      final subject = Subject(name: cls.name, filePath: cls.filePath, element: cls);
      final ctx = AnalysisContext(
          classes: [], files: [], dependencyGraph: DependencyGraph(), projectRoot: '/project');
      final result = rules.first.predicate.analyze(subject, ctx);
      expect(result.passed, isFalse);
    });

    test('capitalises multi-segment folder basename correctly', () {
      final rules = preset.expand(_cfg('folders:\n  - lib/domain/repository'));
      expect(rules.first.description, contains('Repository'));
    });
  });
}
