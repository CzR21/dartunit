import '../../analyzer/context/analysis_context.dart';
import '../entities/subject.dart';
import '../entities/predicate.dart';

/// Passes if the subject's class carries the given [annotation].
///
/// Example — all domain entities must be annotated with `@immutable`:
/// ```dart
/// AnnotatedWithPredicate('immutable')
/// ```
class AnnotatedWithPredicate extends Predicate {
  /// The annotation name to check for (without the leading `@`).
  final String annotation;

  const AnnotatedWithPredicate(this.annotation);

  @override
  PredicateResult evaluate(Subject subject, AnalysisContext context) {
    final cls = subject.asClass;
    if (cls.annotations.contains(annotation)) {
      return const PredicateResult.pass();
    }
    return PredicateResult.fail(
      '${cls.name} must be annotated with @$annotation',
    );
  }
}
