import '../../analyzer/context/analysis_context.dart';
import '../entities/subject.dart';
import '../entities/predicate.dart';

class NameStartsWithPredicate extends Predicate {
  final String prefix;
  const NameStartsWithPredicate(this.prefix);

  @override
  PredicateResult analyze(Subject subject, AnalysisContext context) {
    if (subject.name.startsWith(prefix)) return const PredicateResult.pass();
    return PredicateResult.fail('${subject.name} must start with "$prefix"');
  }
}
