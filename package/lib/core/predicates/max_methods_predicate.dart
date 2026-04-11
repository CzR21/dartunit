import '../../analyzer/context/analysis_context.dart';
import '../entities/subject.dart';
import '../entities/predicate.dart';

/// Passes if the subject's class has at most [maxMethods] methods.
class MaxMethodsPredicate extends Predicate {
  final int maxMethods;
  const MaxMethodsPredicate(this.maxMethods);

  @override
  PredicateResult analyze(Subject subject, AnalysisContext context) {
    final cls = subject.asClass;
    final count = cls.methods.length;
    if (count <= maxMethods) return const PredicateResult.pass();
    return PredicateResult.fail(
      '${cls.name} has $count methods — maximum allowed is $maxMethods',
    );
  }
}
