import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('HasCircularDependencyPredicate — valid cases', () {
    const predicate = HasCircularDependencyPredicate();

    test('passes when graph is empty (no edges)', () {
      final ctx = emptyCtx();
      final result = predicate.analyze(classSubject('A'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes when subject has no connections in graph', () {
      final graph = DependencyGraph()
        ..addEdge('lib/b.dart', 'lib/c.dart');
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
      expect(result.passed, isTrue);
    });

    test('passes when graph has linear chain and subject is not in cycle', () {
      final graph = DependencyGraph()
        ..addEdge('lib/a.dart', 'lib/b.dart')
        ..addEdge('lib/b.dart', 'lib/c.dart');
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
      expect(result.passed, isTrue);
    });

    test('passes for file with outgoing edge but no cycle', () {
      final graph = DependencyGraph()
        ..addEdge('lib/x.dart', 'lib/y.dart');
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
      expect(result.passed, isTrue);
    });

    test('passes for file not involved in unrelated cycle', () {
      // cycle between b and c, but subject is a
      final graph = DependencyGraph()
        ..addEdge('lib/b.dart', 'lib/c.dart')
        ..addEdge('lib/c.dart', 'lib/b.dart')
        ..addEdge('lib/a.dart', 'lib/b.dart');
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
      expect(result.passed, isTrue);
    });
  });
}
