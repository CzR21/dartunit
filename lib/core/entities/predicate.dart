import 'subject.dart';
import '../../analyzer/context/analysis_context.dart';

/// Base interface for all rule predicates.
///
/// A predicate defines the **positive condition** that a subject satisfies.
/// When the condition IS met, [analyze] returns [PredicateResult.pass].
/// When the condition is NOT met, it returns [PredicateResult.fail].
///
/// Rules typically use [NotPredicate] to enforce that the condition is absent:
/// ```dart
/// // "Domain classes must NOT depend on the data layer"
/// NotPredicate(DependOnFolderPredicate('lib/data'))
/// ```
abstract class Predicate {
  const Predicate();

  PredicateResult analyze(Subject subject, AnalysisContext context);

  /// Convenience factory: negate this predicate.
  Predicate not() => _NotPredicate(this);

  /// Convenience factory: AND composition.
  Predicate and(Predicate other) => _AndPredicate([this, other]);

  /// Convenience factory: OR composition.
  Predicate or(Predicate other) => _OrPredicate([this, other]);
}

/// The result of evaluating a predicate against a subject.
///
/// Both pass and fail results carry a [message]:
/// - For **fail**: the violation message shown in the report.
/// - For **pass**: a condition description that [NotPredicate] can reuse
///   as a violation message when inverting the result.
class PredicateResult {
  final bool passed;
  final String message;

  /// Creates a passing result, optionally with a description of the satisfied
  /// condition (used by [NotPredicate] to produce informative violations).
  const PredicateResult.pass([this.message = '']) : passed = true;

  /// Creates a failing result with a [message] describing the violation.
  const PredicateResult.fail(this.message) : passed = false;
}

class _NotPredicate extends Predicate {
  final Predicate _inner;
  const _NotPredicate(this._inner);

  @override
  PredicateResult analyze(Subject subject, AnalysisContext context) {
    final result = _inner.analyze(subject, context);
    if (!result.passed) {
      // Inner condition was NOT met → negation passes (no violation).
      return const PredicateResult.pass();
    }
    // Inner condition WAS met → negation fails (violation).
    // Use the inner's pass message as the violation detail.
    final detail = result.message.isEmpty
        ? '${subject.name} must NOT satisfy: ${_inner.runtimeType}'
        : result.message;
    return PredicateResult.fail(detail);
  }
}

class _AndPredicate extends Predicate {
  final List<Predicate> _predicates;
  const _AndPredicate(this._predicates);

  @override
  PredicateResult analyze(Subject subject, AnalysisContext context) {
    for (final p in _predicates) {
      final result = p.analyze(subject, context);
      if (!result.passed) return result;
    }
    return const PredicateResult.pass();
  }
}

class _OrPredicate extends Predicate {
  final List<Predicate> _predicates;
  const _OrPredicate(this._predicates);

  @override
  PredicateResult analyze(Subject subject, AnalysisContext context) {
    final failures = <String>[];
    for (final p in _predicates) {
      final result = p.analyze(subject, context);
      if (result.passed) return const PredicateResult.pass();
      failures.add(result.message);
    }
    return PredicateResult.fail(failures.join(' OR '));
  }
}
