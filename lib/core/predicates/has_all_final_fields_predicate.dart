import '../../analyzer/context/analysis_context.dart';
import '../entities/subject.dart';
import '../entities/predicate.dart';

class HasAllFinalFieldsPredicate extends Predicate {
  const HasAllFinalFieldsPredicate();

  @override
  PredicateResult evaluate(Subject subject, AnalysisContext context) {
    final cls = subject.asClass;
    final mutableFields = cls.fields
        .where((f) => !f.isStatic && !f.isFinal && !f.isConst)
        .toList();
    if (mutableFields.isEmpty) return const PredicateResult.pass();
    final names = mutableFields.map((f) => f.name).join(', ');
    return PredicateResult.fail(
        '${cls.name} has mutable instance fields: $names');
  }
}
