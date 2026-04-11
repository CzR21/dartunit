import '../../analyzer/context/analysis_context.dart';
import '../entities/subject.dart';
import '../entities/predicate.dart';

/// Passes if the subject is declared as an `extension`.
class IsExtensionPredicate extends Predicate {
  const IsExtensionPredicate();

  @override
  PredicateResult analyze(Subject subject, AnalysisContext context) {
    final cls = subject.asClass;
    if (cls.isExtension) return const PredicateResult.pass();
    return PredicateResult.fail('${cls.name} must be declared as an extension');
  }
}
