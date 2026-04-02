import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('HasCircularDependencyPredicate — invalid cases', () {
    const predicate = HasCircularDependencyPredicate();

    test('fails when subject file is in a two-node cycle', () {
      final graph = DependencyGraph()
        ..addEdge('lib/a.dart', 'lib/b.dart')
        ..addEdge('lib/b.dart', 'lib/a.dart');
      final ctx = AnalysisContext(
        classes: [],
        files: [],
        dependencyGraph: graph,
        projectRoot: '/p',
      );
      final result = predicate.analyze(
        classSubject('A', filePath: 'lib/a.dart'),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('A'));
    });

    test('fails for the second node in a two-node cycle', () {
      final graph = DependencyGraph()
        ..addEdge('lib/a.dart', 'lib/b.dart')
        ..addEdge('lib/b.dart', 'lib/a.dart');
      final ctx = AnalysisContext(
        classes: [],
        files: [],
        dependencyGraph: graph,
        projectRoot: '/p',
      );
      final result = predicate.analyze(
        classSubject('B', filePath: 'lib/b.dart'),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('B'));
    });

    test('fails when subject is part of a three-node cycle', () {
      final graph = DependencyGraph()
        ..addEdge('lib/a.dart', 'lib/b.dart')
        ..addEdge('lib/b.dart', 'lib/c.dart')
        ..addEdge('lib/c.dart', 'lib/a.dart');
      final ctx = AnalysisContext(
        classes: [],
        files: [],
        dependencyGraph: graph,
        projectRoot: '/p',
      );
      final result = predicate.analyze(
        classSubject('B', filePath: 'lib/b.dart'),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('fails with message containing "circular dependency"', () {
      final graph = DependencyGraph()
        ..addEdge('lib/x.dart', 'lib/y.dart')
        ..addEdge('lib/y.dart', 'lib/x.dart');
      final ctx = AnalysisContext(
        classes: [],
        files: [],
        dependencyGraph: graph,
        projectRoot: '/p',
      );
      final result = predicate.analyze(
        classSubject('X', filePath: 'lib/x.dart'),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('circular dependency'));
    });

    test('fails for self-referential import', () {
      final graph = DependencyGraph()
        ..addEdge('lib/a.dart', 'lib/a.dart');
      final ctx = AnalysisContext(
        classes: [],
        files: [],
        dependencyGraph: graph,
        projectRoot: '/p',
      );
      final result = predicate.analyze(
        classSubject('A', filePath: 'lib/a.dart'),
        ctx,
      );
      expect(result.passed, isFalse);
    });
  });
}
