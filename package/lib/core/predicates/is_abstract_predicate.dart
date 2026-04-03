import '../../analyzer/context/analysis_context.dart';
import '../entities/subject.dart';
import '../entities/predicate.dart';

class IsAbstractPredicate extends Predicate {
  const IsAbstractPredicate();

  @override
  PredicateResult analyze(Subject subject, AnalysisContext context) {
    final cls = subject.asClass;
    if (cls.isAbstract) return const PredicateResult.pass();
    return PredicateResult.fail('${cls.name} must be abstract');
  }
}
