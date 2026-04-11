import '../../analyzer/context/analysis_context.dart';
import '../entities/subject.dart';
import '../entities/predicate.dart';

/// Passes if the subject's class implements [typeName].
class ImplementsPredicate extends Predicate {
  final String typeName;
  const ImplementsPredicate(this.typeName);

  @override
  PredicateResult analyze(Subject subject, AnalysisContext context) {
    final cls = subject.asClass;
    if (cls.implementedTypes.contains(typeName))
      return const PredicateResult.pass();
    return PredicateResult.fail('${cls.name} must implement $typeName');
  }
}
