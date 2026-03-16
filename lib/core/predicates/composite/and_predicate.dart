import '../../../analyzer/context/analysis_context.dart';
import '../../selector/selector.dart';
import '../../entities/predicate.dart';

/// Passes only when ALL inner predicates pass (logical AND).
///
/// Evaluation is short-circuited: if any predicate fails, the remaining
/// predicates are not evaluated and that failure result is returned.
///
/// Example — class must end with `Repository` AND live in `lib/data`:
/// ```dart
/// AndPredicate([
///   NameEndsWithPredicate('Repository'),
///   DependOnFolderPredicate('lib/data'),
/// ])
/// ```
class AndPredicate extends Predicate {
  /// The list of predicates that must all pass.
  final List<Predicate> predicates;

  const AndPredicate(this.predicates);

  @override
  PredicateResult evaluate(Subject subject, AnalysisContext context) {
    // Short-circuit: return the first failing result.
    for (final p in predicates) {
      final result = p.evaluate(subject, context);
      if (!result.passed) return result;
    }
    return const PredicateResult.pass();
  }
}
