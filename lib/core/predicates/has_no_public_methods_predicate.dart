import '../../analyzer/context/analysis_context.dart';
import '../selector/selector.dart';
import '../entities/predicate.dart';

class HasNoPublicMethodsPredicate extends Predicate {
  const HasNoPublicMethodsPredicate();

  @override
  PredicateResult evaluate(Subject subject, AnalysisContext context) {
    final cls = subject.asClass;
    final publicMethods = cls.methods.where((m) => !m.name.startsWith('_')).toList();
    if (publicMethods.isEmpty) return const PredicateResult.pass();
    final names = publicMethods.map((m) => m.name).join(', ');
    return PredicateResult.fail('${cls.name} exposes public methods: $names');
  }
}
