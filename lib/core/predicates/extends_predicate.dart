import '../../analyzer/context/analysis_context.dart';
import '../selector/selector.dart';
import '../entities/predicate.dart';

class ExtendsPredicate extends Predicate {
  final String typeName;
  const ExtendsPredicate(this.typeName);

  @override
  PredicateResult evaluate(Subject subject, AnalysisContext context) {
    final cls = subject.asClass;
    if (cls.extendedType == typeName) return const PredicateResult.pass();
    return PredicateResult.fail(
      '${cls.name} must extend $typeName (currently extends: ${cls.extendedType ?? 'nothing'})',
    );
  }
}
