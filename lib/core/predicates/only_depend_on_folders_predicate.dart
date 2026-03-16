import '../../analyzer/context/analysis_context.dart';
import '../selector/selector.dart';
import '../entities/predicate.dart';

class OnlyDependOnFoldersPredicate extends Predicate {
  final List<String> allowedFolders;
  const OnlyDependOnFoldersPredicate(this.allowedFolders);

  @override
  PredicateResult evaluate(Subject subject, AnalysisContext context) {
    final cls = subject.asClass;
    final normalized = allowedFolders.map((f) => f.replaceAll('\\', '/')).toList();
    final forbidden = cls.imports
        .where((imp) => !normalized.any((allowed) => imp.contains(allowed)))
        .toList();
    if (forbidden.isEmpty) return const PredicateResult.pass();
    return PredicateResult.fail(
      '${cls.name} imports from disallowed locations:\n  ${forbidden.join('\n  ')}\nAllowed: ${normalized.join(', ')}',
    );
  }
}
