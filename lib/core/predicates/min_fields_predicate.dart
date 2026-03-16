import '../../analyzer/context/analysis_context.dart';
import '../selector/selector.dart';
import '../entities/predicate.dart';

class MinFieldsPredicate extends Predicate {
  final int minFields;
  const MinFieldsPredicate(this.minFields);

  @override
  PredicateResult evaluate(Subject subject, AnalysisContext context) {
    final cls = subject.asClass;
    final count = cls.fields.length;
    if (count >= minFields) return const PredicateResult.pass();
    return PredicateResult.fail(
      '${cls.name} has $count fields — minimum required is $minFields',
    );
  }
}
