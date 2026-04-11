import '../../analyzer/context/analysis_context.dart';
import '../entities/subject.dart';
import '../entities/predicate.dart';
import '../extensions/string_extensions.dart';

/// Passes if the subject imports ONLY from folders listed in [allowedFolders].
///
/// Any import that does not match an allowed prefix is reported as a violation.
class OnlyDependOnFoldersPredicate extends Predicate {
  final List<String> allowedFolders;
  const OnlyDependOnFoldersPredicate(this.allowedFolders);

  @override
  PredicateResult analyze(Subject subject, AnalysisContext context) {
    final cls = subject.asClass;
    final normalized = allowedFolders
        .map((f) => f.normalized)
        .map((f) => f.endsWith('/') ? f : '$f/')
        .toList();
    final forbidden = cls.imports
        .where((imp) => !normalized.any((prefix) => imp.contains(prefix)))
        .toList();
    if (forbidden.isEmpty) return const PredicateResult.pass();
    return PredicateResult.fail(
      '${cls.name} imports from disallowed locations:\n  ${forbidden.join('\n  ')}\nAllowed: ${normalized.join(', ')}',
    );
  }
}
