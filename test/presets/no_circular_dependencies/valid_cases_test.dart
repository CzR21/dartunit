import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('noCircularDependencies preset — valid cases (HasCircularDependencyPredicate)', () {
    const predicate = HasCircularDependencyPredicate();

    test('passes when graph is empty (no deps)', () {
      final ctx = emptyCtx();
      final result = predicate.analyze(classSubject('A'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes for class not connected to any cycle', () {
      final graph = DependencyGraph()..addEdge('lib/b.dart', 'lib/c.dart');
      final ctx = AnalysisContext(
        classes: [], files: [], dependencyGraph: graph, projectRoot: '/p',
      );
      final result = predicate.analyze(classSubject('A', filePath: 'lib/a.dart'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes for linear dependency chain', () {
      final graph = DependencyGraph()
        ..addEdge('lib/a.dart', 'lib/b.dart')
        ..addEdge('lib/b.dart', 'lib/c.dart');
      final ctx = AnalysisContext(
        classes: [], files: [], dependencyGraph: graph, projectRoot: '/p',
      );
      final result = predicate.analyze(classSubject('A', filePath: 'lib/a.dart'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes when cycle exists elsewhere but not involving subject', () {
      final graph = DependencyGraph()
        ..addEdge('lib/x.dart', 'lib/y.dart')
        ..addEdge('lib/y.dart', 'lib/x.dart');
      final ctx = AnalysisContext(
        classes: [], files: [], dependencyGraph: graph, projectRoot: '/p',
      );
      // 'lib/a.dart' is not in the x-y cycle
      final result = predicate.analyze(classSubject('A', filePath: 'lib/a.dart'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes for class with outgoing edge but no cycle', () {
      final graph = DependencyGraph()..addEdge('lib/a.dart', 'lib/b.dart');
      final ctx = AnalysisContext(
        classes: [], files: [], dependencyGraph: graph, projectRoot: '/p',
      );
      final result = predicate.analyze(classSubject('A', filePath: 'lib/a.dart'), ctx);
      expect(result.passed, isTrue);
    });
  });
}
