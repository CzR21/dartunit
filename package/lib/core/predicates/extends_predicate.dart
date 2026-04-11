import '../../analyzer/context/analysis_context.dart';
import '../entities/subject.dart';
import '../entities/predicate.dart';

/// Passes if the subject's class extends [typeName].
class ExtendsPredicate extends Predicate {
  final String typeName;
  const ExtendsPredicate(this.typeName);

  @override
  PredicateResult analyze(Subject subject, AnalysisContext context) {
    final cls = subject.asClass;
    if (cls.extendedType == typeName) return const PredicateResult.pass();
    return PredicateResult.fail(
      '${cls.name} must extend $typeName (currently extends: ${cls.extendedType ?? 'nothing'})',
    );
  }
}
