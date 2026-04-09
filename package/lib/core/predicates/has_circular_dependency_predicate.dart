import '../../analyzer/context/analysis_context.dart';
import '../entities/subject.dart';
import '../entities/predicate.dart';
import '../extensions/string_extensions.dart';

class HasCircularDependencyPredicate extends Predicate {
  const HasCircularDependencyPredicate();

  @override
  PredicateResult analyze(Subject subject, AnalysisContext context) {
    final cycles = context.dependencyGraph.detectCycles();
    final subjectPath = subject.filePath.normalized;
    final involvedCycles =
        cycles.where((cycle) => cycle.contains(subjectPath)).toList();
    if (involvedCycles.isEmpty) return const PredicateResult.pass();
    return PredicateResult.fail(
      '${subject.name} is part of a circular dependency: ${involvedCycles.first.join(' -> ')}',
    );
  }
}
