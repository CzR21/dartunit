import '../../analyzer/context/analysis_context.dart';
import '../entities/subject.dart';
import '../entities/predicate.dart';

class HasMethodPredicate extends Predicate {
  final String methodName;
  const HasMethodPredicate(this.methodName);

  @override
  PredicateResult evaluate(Subject subject, AnalysisContext context) {
    final cls = subject.asClass;
    if (cls.methods.any((m) => m.name == methodName))
      return const PredicateResult.pass();
    return PredicateResult.fail(
        '${cls.name} must declare a method named "$methodName"');
  }
}
