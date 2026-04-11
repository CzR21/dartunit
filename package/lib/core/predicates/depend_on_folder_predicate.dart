import '../../analyzer/context/analysis_context.dart';
import '../entities/subject.dart';
import '../entities/predicate.dart';
import '../extensions/string_extensions.dart';

/// Passes if the subject imports from [folder] (directly or transitively).
///
/// Use with [NotPredicate] to enforce that a layer does NOT depend on a folder.
class DependOnFolderPredicate extends Predicate {
  final String folder;

  /// When [transitive] is true, checks the full transitive closure of
  /// dependencies instead of only direct imports.
  final bool transitive;

  const DependOnFolderPredicate(this.folder, {this.transitive = false});

  @override
  PredicateResult analyze(Subject subject, AnalysisContext context) {
    final cls = subject.asClass;
    final norm = folder.normalized;
    final prefix = norm.endsWith('/') ? norm : '$norm/';

    final imports = transitive
        ? context.dependencyGraph.transitiveDependenciesOf(cls.filePath)
        : cls.imports.toSet();

    final matchingImports =
        imports.where((imp) => imp.contains(prefix)).toList();
    if (matchingImports.isNotEmpty) {
      return PredicateResult.pass(
        '${cls.name} imports from "$folder": ${matchingImports.join(', ')}',
      );
    }
    return PredicateResult.fail('${cls.name} does not depend on "$folder"');
  }
}
