import '../../analyzer/context/analysis_context.dart';
import '../entities/subject.dart';
import '../entities/predicate.dart';

class IsMixinPredicate extends Predicate {
  const IsMixinPredicate();

  @override
  PredicateResult analyze(Subject subject, AnalysisContext context) {
    final cls = subject.asClass;
    if (cls.isMixin) return const PredicateResult.pass();
    return PredicateResult.fail('${cls.name} must be declared as a mixin');
  }
}
