import '../../../analyzer/context/analysis_context.dart';
import '../../entities/subject.dart';
import '../../entities/predicate.dart';

/// Passes when the inner predicate FAILS (logical negation).
///
/// When the inner predicate passes (condition IS met), this predicate
/// fails and uses the inner's pass message as the violation detail —
/// giving informative output like "UserService imports from 'lib/data': ...".
class NotPredicate extends Predicate {
  final Predicate inner;

  const NotPredicate(this.inner);

  @override
  PredicateResult analyze(Subject subject, AnalysisContext context) {
    final result = inner.analyze(subject, context);
    if (!result.passed) {
      return const PredicateResult.pass();
    }
    // Inner condition was met → negation is a violation.
    final detail = result.message.isEmpty
        ? '${subject.name} must NOT satisfy the condition'
        : result.message;
    return PredicateResult.fail(detail);
  }
}
