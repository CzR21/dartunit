import '../../../analyzer/context/analysis_context.dart';
import '../../selector/selector.dart';
import '../../entities/predicate.dart';

/// Passes when AT LEAST ONE inner predicate passes (logical OR).
///
/// Evaluation is short-circuited: if any predicate passes, the remaining
/// predicates are not evaluated.  If all predicates fail, the returned
/// message combines all individual failure reasons.
///
/// Example — class must end with `Bloc` OR `Cubit`:
/// ```dart
/// OrPredicate([
///   NameEndsWithPredicate('Bloc'),
///   NameEndsWithPredicate('Cubit'),
/// ])
/// ```
class OrPredicate extends Predicate {
  /// The list of predicates, at least one of which must pass.
  final List<Predicate> predicates;

  const OrPredicate(this.predicates);

  @override
  PredicateResult evaluate(Subject subject, AnalysisContext context) {
    final failures = <String>[];

    // Short-circuit: return pass as soon as one predicate succeeds.
    for (final p in predicates) {
      final result = p.evaluate(subject, context);
      if (result.passed) return const PredicateResult.pass();
      failures.add(result.message);
    }

    // All predicates failed — combine their messages.
    return PredicateResult.fail(
      'None of the OR conditions were met:\n  ${failures.join('\n  ')}',
    );
  }
}
