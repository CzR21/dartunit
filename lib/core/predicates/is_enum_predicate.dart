import '../../analyzer/context/analysis_context.dart';
import '../entities/subject.dart';
import '../entities/predicate.dart';

class IsEnumPredicate extends Predicate {
  const IsEnumPredicate();

  @override
  PredicateResult evaluate(Subject subject, AnalysisContext context) {
    final cls = subject.asClass;
    if (cls.isEnum) return const PredicateResult.pass();
    return PredicateResult.fail('${cls.name} must be declared as an enum');
  }
}
