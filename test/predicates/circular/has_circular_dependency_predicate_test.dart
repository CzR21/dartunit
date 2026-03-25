import 'package:dartunit/core/entities/subject.dart';
import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';

// HasCircularDependencyPredicate semantics:
//   PASSES  → file has NO circular dependencies (clean)
//   FAILS   → file IS part of a cycle (violation detected)
// In rules it is wrapped with NotPredicate to enforce "must not be in a cycle"
// OR used directly to verify "no cycles exist (positive test)".

DependencyGraph _graph(List<(String, String)> edges) {
  final g = DependencyGraph();
  for (final e in edges) {
    g.addEdge(e.$1, e.$2);
  }
  return g;
}

Subject _subject(String filePath) {
  final cls = AnalyzedClass(
      name: filePath.split('/').last.replaceAll('.dart', ''),
      filePath: filePath,
      packagePath: 'package:app/$filePath');
  return Subject(
      name: cls.name, filePath: filePath, element: cls);
}

AnalysisContext _ctx(DependencyGraph graph) => AnalysisContext(
      classes: [],
      files: [],
      dependencyGraph: graph,
      projectRoot: '/p',
    );

void main() {
  const pred = HasCircularDependencyPredicate();

  // ── valid cases (passes = no cycle for this file) ─────────────────────────

  group('HasCircularDependencyPredicate — passes (no cycle)', () {
    test('passes when subject file has no dependencies at all', () {
      final result = pred.analyze(
        _subject('/p/lib/clean.dart'),
        _ctx(DependencyGraph()),
      );
      expect(result.passed, isTrue);
    });

    test('passes when file is in a DAG (no cycles)', () {
      final graph = _graph([
        ('/p/a.dart', '/p/b.dart'),
        ('/p/b.dart', '/p/c.dart'),
      ]);
      expect(pred.analyze(_subject('/p/a.dart'), _ctx(graph)).passed, isTrue);
    });

    test('passes for a file not involved in a cycle that exists elsewhere', () {
      // b↔c form a cycle, but a is completely separate
      final graph = _graph([
        ('/p/b.dart', '/p/c.dart'),
        ('/p/c.dart', '/p/b.dart'),
      ]);
      expect(pred.analyze(_subject('/p/a.dart'), _ctx(graph)).passed, isTrue);
    });
  });

  // ── fail cases (fails = cycle detected for this file) ─────────────────────

  group('HasCircularDependencyPredicate — fails (cycle detected)', () {
    test('fails when subject file is part of a direct A→B→A cycle', () {
      final graph = _graph([
        ('/p/a.dart', '/p/b.dart'),
        ('/p/b.dart', '/p/a.dart'),
      ]);
      expect(pred.analyze(_subject('/p/a.dart'), _ctx(graph)).passed, isFalse);
    });

    test('fails when subject file is in a three-node cycle (A→B→C→A)', () {
      final graph = _graph([
        ('/p/a.dart', '/p/b.dart'),
        ('/p/b.dart', '/p/c.dart'),
        ('/p/c.dart', '/p/a.dart'),
      ]);
      expect(pred.analyze(_subject('/p/c.dart'), _ctx(graph)).passed, isFalse);
    });

    test('fail message contains the file path involved in the cycle', () {
      final graph = _graph([
        ('/p/x.dart', '/p/y.dart'),
        ('/p/y.dart', '/p/x.dart'),
      ]);
      final result = pred.analyze(_subject('/p/x.dart'), _ctx(graph));
      expect(result.passed, isFalse);
      expect(result.message, contains('/p/x.dart'));
    });
  });
}
