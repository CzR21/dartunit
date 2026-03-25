import '../../analyzer/context/analysis_context.dart';
import '../entities/subject.dart';
import '../entities/predicate.dart';

class NameEndsWithPredicate extends Predicate {
  final String suffix;
  const NameEndsWithPredicate(this.suffix);

  @override
  PredicateResult analyze(Subject subject, AnalysisContext context) {
    if (subject.name.endsWith(suffix)) return const PredicateResult.pass();
    return PredicateResult.fail('${subject.name} must end with "$suffix"');
  }
}
