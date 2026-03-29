import '../../analyzer/context/analysis_context.dart';
import '../entities/subject.dart';
import '../entities/predicate.dart';

class NameContainsPredicate extends Predicate {
  final String substring;
  const NameContainsPredicate(this.substring);

  @override
  PredicateResult analyze(Subject subject, AnalysisContext context) {
    if (subject.name.contains(substring)) return const PredicateResult.pass();
    return PredicateResult.fail('${subject.name} must contain "$substring"');
  }
}
