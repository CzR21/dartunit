import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

AnalysisContext ctxWithGraph(Map<String, List<String>> edges) {
  final graph = DependencyGraph();
  for (final entry in edges.entries) {
    for (final dep in entry.value) {
      graph.addEdge(entry.key, dep);
    }
  }
  return AnalysisContext(
    classes: [],
    files: [],
    dependencyGraph: graph,
    projectRoot: '/project',
  );
}

void main() {
  group('DependOnFolderPredicate — valid cases', () {
    final ctx = emptyCtx();

    test('passes when import contains the folder path', () {
      final predicate = DependOnFolderPredicate('lib/data');
      final result = predicate.analyze(
        classSubject('UserRepo', imports: ['lib/data/user_dao.dart']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes when one of multiple imports matches the folder', () {
      final predicate = DependOnFolderPredicate('lib/data');
      final result = predicate.analyze(
        classSubject('UserRepo', imports: [
          'lib/domain/user.dart',
          'lib/data/user_dao.dart',
        ]),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes when import path contains folder as substring', () {
      final predicate = DependOnFolderPredicate('lib/data');
      final result = predicate.analyze(
        classSubject('Service', imports: ['lib/data/repositories/user.dart']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes for package: URI import containing the folder', () {
      final predicate = DependOnFolderPredicate('lib/domain');
      final result = predicate.analyze(
        classSubject('ViewModel', imports: ['package:app/lib/domain/user.dart']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('pass result message contains folder name', () {
      final predicate = DependOnFolderPredicate('lib/data');
      final result = predicate.analyze(
        classSubject('MyClass', imports: ['lib/data/something.dart']),
        ctx,
      );
      expect(result.passed, isTrue);
      expect(result.message, contains('lib/data'));
    });

    test('passes when multiple imports match the folder', () {
      final predicate = DependOnFolderPredicate('lib/data');
      final result = predicate.analyze(
        classSubject('BigClass', imports: [
          'lib/data/user_dao.dart',
          'lib/data/order_dao.dart',
        ]),
        ctx,
      );
      expect(result.passed, isTrue);
    });
  });

  group('DependOnFolderPredicate — transitive: true', () {
    test('passes when class transitively depends on folder', () {
      // a.dart → b.dart → lib/data/repo.dart
      final graphCtx = ctxWithGraph({
        'lib/domain/a.dart': ['lib/domain/b.dart'],
        'lib/domain/b.dart': ['lib/data/repo.dart'],
      });
      final predicate = DependOnFolderPredicate('lib/data', transitive: true);
      final result = predicate.analyze(
        classSubject('A', filePath: 'lib/domain/a.dart'),
        graphCtx,
      );
      expect(result.passed, isTrue);
    });

    test('fails when no transitive dependency on folder', () {
      final graphCtx = ctxWithGraph({
        'lib/domain/a.dart': ['lib/domain/b.dart'],
      });
      final predicate = DependOnFolderPredicate('lib/data', transitive: true);
      final result = predicate.analyze(
        classSubject('A', filePath: 'lib/domain/a.dart'),
        graphCtx,
      );
      expect(result.passed, isFalse);
    });

    test('false when transitive dep matches only partial folder name', () {
      final graphCtx = ctxWithGraph({
        'lib/domain/a.dart': ['lib/data_access/repo.dart'],
      });
      final predicate = DependOnFolderPredicate('lib/data', transitive: true);
      final result = predicate.analyze(
        classSubject('A', filePath: 'lib/domain/a.dart'),
        graphCtx,
      );
      expect(result.passed, isFalse);
    });
  });
}
