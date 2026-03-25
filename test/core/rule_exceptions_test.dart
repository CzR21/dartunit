import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../helpers/test_helpers.dart';

void main() {
  // A predicate that always fails — no class name ends with this suffix.
  final alwaysFail = NameEndsWithPredicate('__NEVER_MATCH__');

  AnalysisContext ctxWithClasses(List<String> filePaths) => AnalysisContext(
        classes: filePaths
            .map((p) => AnalyzedClass(
                  name: 'Cls',
                  filePath: p,
                  packagePath: 'package:app/$p',
                ))
            .toList(),
        files: [],
        dependencyGraph: DependencyGraph(),
        projectRoot: '/project',
      );

  group('Rule — exceptions', () {
    test('no exceptions: all violations are returned', () {
      final rule = Rule(
        description: 'Test rule',
        selector: ClassSelector(folder: 'lib/'),
        predicate: alwaysFail,
      );
      final ctx = ctxWithClasses([
        'lib/domain/service.dart',
        'lib/data/repo.dart',
      ]);
      expect(rule.analyze(ctx), hasLength(2));
    });

    test('exception matching a full file path suppresses that violation', () {
      final rule = Rule(
        description: 'Test rule',
        selector: ClassSelector(folder: 'lib/'),
        predicate: alwaysFail,
        exceptions: ['lib/data/repo.dart'],
      );
      final ctx = ctxWithClasses([
        'lib/domain/service.dart',
        'lib/data/repo.dart',
      ]);
      final violations = rule.analyze(ctx);
      expect(violations, hasLength(1));
      expect(violations.first.filePath, equals('lib/domain/service.dart'));
    });

    test('exception matching a folder prefix suppresses all files in it', () {
      final rule = Rule(
        description: 'Test rule',
        selector: ClassSelector(folder: 'lib/'),
        predicate: alwaysFail,
        exceptions: ['lib/legacy/'],
      );
      final ctx = ctxWithClasses([
        'lib/domain/service.dart',
        'lib/legacy/old_service.dart',
        'lib/legacy/old_repo.dart',
      ]);
      final violations = rule.analyze(ctx);
      expect(violations, hasLength(1));
      expect(violations.first.filePath, equals('lib/domain/service.dart'));
    });

    test('multiple exceptions suppress each matched file', () {
      final rule = Rule(
        description: 'Test rule',
        selector: ClassSelector(folder: 'lib/'),
        predicate: alwaysFail,
        exceptions: ['lib/legacy/', 'lib/generated/models.dart'],
      );
      final ctx = ctxWithClasses([
        'lib/domain/service.dart',
        'lib/legacy/old.dart',
        'lib/generated/models.dart',
      ]);
      final violations = rule.analyze(ctx);
      expect(violations, hasLength(1));
      expect(violations.first.filePath, equals('lib/domain/service.dart'));
    });

    test('exceptions that match nothing leave all violations intact', () {
      final rule = Rule(
        description: 'Test rule',
        selector: ClassSelector(folder: 'lib/'),
        predicate: alwaysFail,
        exceptions: ['lib/nonexistent/'],
      );
      final ctx = ctxWithClasses(['lib/domain/service.dart']);
      expect(rule.analyze(ctx), hasLength(1));
    });

    test('empty exceptions list behaves the same as no exceptions', () {
      final rule = Rule(
        description: 'Test rule',
        selector: ClassSelector(folder: 'lib/'),
        predicate: alwaysFail,
        exceptions: [],
      );
      final ctx = ctxWithClasses(['lib/domain/service.dart']);
      expect(rule.analyze(ctx), hasLength(1));
    });
  });
}
