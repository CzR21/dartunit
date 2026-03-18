import '../../analyzer/context/analysis_context.dart';
import '../entities/subject.dart';
import '../entities/predicate.dart';

class IsExtensionPredicate extends Predicate {
  const IsExtensionPredicate();

  @override
  PredicateResult evaluate(Subject subject, AnalysisContext context) {
    final cls = subject.asClass;
    if (cls.isExtension) return const PredicateResult.pass();
    return PredicateResult.fail('${cls.name} must be declared as an extension');
  }
}
