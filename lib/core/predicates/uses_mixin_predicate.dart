import '../../analyzer/context/analysis_context.dart';
import '../entities/subject.dart';
import '../entities/predicate.dart';

class UsesMixinPredicate extends Predicate {
  final String mixinName;
  const UsesMixinPredicate(this.mixinName);

  @override
  PredicateResult analyze(Subject subject, AnalysisContext context) {
    final cls = subject.asClass;
    if (cls.mixinTypes.contains(mixinName)) return const PredicateResult.pass();
    return PredicateResult.fail('${cls.name} must use mixin $mixinName');
  }
}
