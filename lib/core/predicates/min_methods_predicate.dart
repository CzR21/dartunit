import '../../analyzer/context/analysis_context.dart';
import '../selector/selector.dart';
import '../entities/predicate.dart';

class MinMethodsPredicate extends Predicate {
  final int minMethods;
  const MinMethodsPredicate(this.minMethods);

  @override
  PredicateResult evaluate(Subject subject, AnalysisContext context) {
    final cls = subject.asClass;
    final count = cls.methods.length;
    if (count >= minMethods) return const PredicateResult.pass();
    return PredicateResult.fail(
      '${cls.name} has $count methods — minimum required is $minMethods',
    );
  }
}
