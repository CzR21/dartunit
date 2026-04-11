import '../../analyzer/context/analysis_context.dart';
import '../entities/subject.dart';
import '../entities/predicate.dart';

/// Passes if the subject's class exposes no public instance fields.
///
/// Static fields are excluded from the check.
class HasNoPublicFieldsPredicate extends Predicate {
  const HasNoPublicFieldsPredicate();

  @override
  PredicateResult analyze(Subject subject, AnalysisContext context) {
    final cls = subject.asClass;
    final publicFields = cls.fields
        .where((f) => !f.isStatic && !f.name.startsWith('_'))
        .toList();
    if (publicFields.isEmpty) return const PredicateResult.pass();
    final names = publicFields.map((f) => f.name).join(', ');
    return PredicateResult.fail(
        '${cls.name} exposes public instance fields: $names');
  }
}
