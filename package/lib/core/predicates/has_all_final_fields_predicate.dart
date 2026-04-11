import '../../analyzer/context/analysis_context.dart';
import '../entities/subject.dart';
import '../entities/predicate.dart';

/// Passes if all instance fields of the subject's class are `final` or `const`.
///
/// Static fields are excluded from the check.
class HasAllFinalFieldsPredicate extends Predicate {
  const HasAllFinalFieldsPredicate();

  @override
  PredicateResult analyze(Subject subject, AnalysisContext context) {
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
