import '../../analyzer/context/analysis_context.dart';
import '../entities/subject.dart';
import '../entities/predicate.dart';

/// Passes if the subject is a concrete class (not abstract, mixin, enum, or extension).
class IsConcreteClassPredicate extends Predicate {
  const IsConcreteClassPredicate();

  @override
  PredicateResult analyze(Subject subject, AnalysisContext context) {
    final cls = subject.asClass;
    final isConcrete =
        !cls.isAbstract && !cls.isMixin && !cls.isEnum && !cls.isExtension;
    if (isConcrete) return const PredicateResult.pass();
    return PredicateResult.fail(
      '${cls.name} must be a concrete class (not abstract, mixin, enum, or extension)',
    );
  }
}
