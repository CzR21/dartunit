import '../../analyzer/context/analysis_context.dart';
import '../selector/selector.dart';
import '../entities/predicate.dart';

class IsConcreteClassPredicate extends Predicate {
  const IsConcreteClassPredicate();

  @override
  PredicateResult evaluate(Subject subject, AnalysisContext context) {
    final cls = subject.asClass;
    final isConcrete = !cls.isAbstract && !cls.isMixin && !cls.isEnum && !cls.isExtension;
    if (isConcrete) return const PredicateResult.pass();
    return PredicateResult.fail(
      '${cls.name} must be a concrete class (not abstract, mixin, enum, or extension)',
    );
  }
}
