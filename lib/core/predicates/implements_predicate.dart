import '../../analyzer/context/analysis_context.dart';
import '../entities/subject.dart';
import '../entities/predicate.dart';

class ImplementsPredicate extends Predicate {
  final String typeName;
  const ImplementsPredicate(this.typeName);

  @override
  PredicateResult evaluate(Subject subject, AnalysisContext context) {
    final cls = subject.asClass;
    if (cls.implementedTypes.contains(typeName))
      return const PredicateResult.pass();
    return PredicateResult.fail('${cls.name} must implement $typeName');
  }
}
