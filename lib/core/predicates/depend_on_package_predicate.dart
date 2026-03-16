import '../../analyzer/context/analysis_context.dart';
import '../selector/selector.dart';
import '../entities/predicate.dart';

class DependOnPackagePredicate extends Predicate {
  final String packageName;
  const DependOnPackagePredicate(this.packageName);

  @override
  PredicateResult evaluate(Subject subject, AnalysisContext context) {
    final cls = subject.asClass;
    final prefix = 'package:$packageName/';
    final matching = cls.imports.where((imp) => imp.startsWith(prefix)).toList();
    if (matching.isNotEmpty) {
      return PredicateResult.pass(
        '${cls.name} imports from package "$packageName":\n  ${matching.join('\n  ')}',
      );
    }
    return PredicateResult.fail('${cls.name} does not import from package "$packageName"');
  }
}
