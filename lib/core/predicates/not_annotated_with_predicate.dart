import '../../analyzer/context/analysis_context.dart';
import '../selector/selector.dart';
import '../entities/predicate.dart';

/// Passes if the subject's class does NOT carry the given [annotation].
///
/// Example — UI classes must not carry `@injectable` (use factory instead):
/// ```dart
/// NotAnnotatedWithPredicate('injectable')
/// ```
class NotAnnotatedWithPredicate extends Predicate {
  /// The annotation name that must be absent (without the leading `@`).
  final String annotation;

  const NotAnnotatedWithPredicate(this.annotation);

  @override
  PredicateResult evaluate(Subject subject, AnalysisContext context) {
    final cls = subject.asClass;
    if (!cls.annotations.contains(annotation)) {
      return const PredicateResult.pass();
    }
    return PredicateResult.fail(
      '${cls.name} must NOT be annotated with @$annotation',
    );
  }
}
