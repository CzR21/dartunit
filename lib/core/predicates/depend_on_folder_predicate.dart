import '../../analyzer/context/analysis_context.dart';
import '../entities/subject.dart';
import '../entities/predicate.dart';

class DependOnFolderPredicate extends Predicate {
  final String folder;
  const DependOnFolderPredicate(this.folder);

  @override
  PredicateResult evaluate(Subject subject, AnalysisContext context) {
    final cls = subject.asClass;
    final normalized = folder.replaceAll('\\', '/');
    final matchingImports =
        cls.imports.where((imp) => imp.contains(normalized)).toList();
    if (matchingImports.isNotEmpty) {
      return PredicateResult.pass(
        '${cls.name} imports from "$folder":\n  ${matchingImports.join('\n  ')}',
      );
    }
    return PredicateResult.fail('${cls.name} does not depend on "$folder"');
  }
}
