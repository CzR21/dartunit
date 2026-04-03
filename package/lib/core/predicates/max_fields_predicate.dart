import '../../analyzer/context/analysis_context.dart';
import '../entities/subject.dart';
import '../entities/predicate.dart';

class MaxFieldsPredicate extends Predicate {
  final int maxFields;
  const MaxFieldsPredicate(this.maxFields);

  @override
  PredicateResult analyze(Subject subject, AnalysisContext context) {
    final cls = subject.asClass;
    final count = cls.fields.length;
    if (count <= maxFields) return const PredicateResult.pass();
    return PredicateResult.fail(
      '${cls.name} has $count fields — maximum allowed is $maxFields',
    );
  }
}
