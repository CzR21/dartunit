import '../../analyzer/context/analysis_context.dart';
import '../entities/subject.dart';
import '../entities/predicate.dart';

class MaxImportsPredicate extends Predicate {
  final int maxImports;
  const MaxImportsPredicate(this.maxImports);

  @override
  PredicateResult evaluate(Subject subject, AnalysisContext context) {
    final cls = subject.asClass;
    final count = cls.imports.length;
    if (count <= maxImports) return const PredicateResult.pass();
    return PredicateResult.fail(
      '${cls.name} has $count imports — maximum allowed is $maxImports',
    );
  }
}
