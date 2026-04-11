import '../../analyzer/context/analysis_context.dart';
import '../entities/subject.dart';
import '../entities/predicate.dart';

/// Passes if the subject is declared as an `enum`.
class IsEnumPredicate extends Predicate {
  const IsEnumPredicate();

  @override
  PredicateResult analyze(Subject subject, AnalysisContext context) {
    final cls = subject.asClass;
    if (cls.isEnum) return const PredicateResult.pass();
    return PredicateResult.fail('${cls.name} must be declared as an enum');
  }
}
