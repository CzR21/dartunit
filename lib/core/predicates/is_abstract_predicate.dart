import '../../analyzer/context/analysis_context.dart';
import '../selector/selector.dart';
import '../entities/predicate.dart';

class IsAbstractPredicate extends Predicate {
  const IsAbstractPredicate();

  @override
  PredicateResult evaluate(Subject subject, AnalysisContext context) {
    final cls = subject.asClass;
    if (cls.isAbstract) return const PredicateResult.pass();
    return PredicateResult.fail('${cls.name} must be abstract');
  }
}
