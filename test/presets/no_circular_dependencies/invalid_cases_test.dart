import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('noCircularDependencies preset — invalid cases (HasCircularDependencyPredicate)', () {
    const predicate = HasCircularDependencyPredicate();

    test('fails when subject is in a two-node cycle', () {
      final graph = DependencyGraph()
        ..addEdge('lib/a.dart', 'lib/b.dart')
        ..addEdge('lib/b.dart', 'lib/a.dart');
      final ctx = AnalysisContext(
        classes: [], files: [], dependencyGraph: graph, projectRoot: '/p',
      );
      final result = predicate.analyze(classSubject('A', filePath: 'lib/a.dart'), ctx);
      expect(result.passed, isFalse);
      expect(result.message, contains('circular dependency'));
    });

    test('fails for both nodes in a cycle', () {
      final graph = DependencyGraph()
        ..addEdge('lib/x.dart', 'lib/y.dart')
        ..addEdge('lib/y.dart', 'lib/x.dart');
      final ctx = AnalysisContext(
        classes: [], files: [], dependencyGraph: graph, projectRoot: '/p',
      );
      final resultX = predicate.analyze(classSubject('X', filePath: 'lib/x.dart'), ctx);
      final resultY = predicate.analyze(classSubject('Y', filePath: 'lib/y.dart'), ctx);
      expect(resultX.passed, isFalse);
      expect(resultY.passed, isFalse);
    });

    test('fails for three-node cycle', () {
      final graph = DependencyGraph()
        ..addEdge('lib/a.dart', 'lib/b.dart')
        ..addEdge('lib/b.dart', 'lib/c.dart')
        ..addEdge('lib/c.dart', 'lib/a.dart');
      final ctx = AnalysisContext(
        classes: [], files: [], dependencyGraph: graph, projectRoot: '/p',
      );
      final result = predicate.analyze(classSubject('B', filePath: 'lib/b.dart'), ctx);
      expect(result.passed, isFalse);
    });

    test('failure message contains subject name', () {
      final graph = DependencyGraph()
        ..addEdge('lib/a.dart', 'lib/b.dart')
        ..addEdge('lib/b.dart', 'lib/a.dart');
      final ctx = AnalysisContext(
        classes: [], files: [], dependencyGraph: graph, projectRoot: '/p',
      );
      final result = predicate.analyze(classSubject('CycleA', filePath: 'lib/a.dart'), ctx);
      expect(result.passed, isFalse);
      expect(result.message, contains('CycleA'));
    });

    test('fails for self-referential import', () {
      final graph = DependencyGraph()..addEdge('lib/a.dart', 'lib/a.dart');
      final ctx = AnalysisContext(
        classes: [], files: [], dependencyGraph: graph, projectRoot: '/p',
      );
      final result = predicate.analyze(classSubject('A', filePath: 'lib/a.dart'), ctx);
      expect(result.passed, isFalse);
    });
  });
}
