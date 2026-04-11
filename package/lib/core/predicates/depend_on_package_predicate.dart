import '../../analyzer/context/analysis_context.dart';
import '../entities/subject.dart';
import '../entities/predicate.dart';

/// Passes if the subject imports from the given [packageName].
///
/// Use with [NotPredicate] to enforce that a layer does NOT depend on an
/// external package (e.g. `flutter`, `dio`).
class DependOnPackagePredicate extends Predicate {
  final String packageName;
  const DependOnPackagePredicate(this.packageName);

  @override
  PredicateResult analyze(Subject subject, AnalysisContext context) {
    final cls = subject.asClass;
    final prefix = 'package:$packageName/';
    final matching =
        cls.imports.where((imp) => imp.startsWith(prefix)).toList();
    if (matching.isNotEmpty) {
      return PredicateResult.pass(
        '${cls.name} imports from package "$packageName":\n  ${matching.join('\n  ')}',
      );
    }
    return PredicateResult.fail(
        '${cls.name} does not import from package "$packageName"');
  }
}
