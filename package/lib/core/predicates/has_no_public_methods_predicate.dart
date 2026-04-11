import '../../analyzer/context/analysis_context.dart';
import '../entities/subject.dart';
import '../entities/predicate.dart';

/// Passes if the subject's class exposes no public methods.
///
/// Methods whose names start with `_` are considered private and ignored.
class HasNoPublicMethodsPredicate extends Predicate {
  const HasNoPublicMethodsPredicate();

  @override
  PredicateResult analyze(Subject subject, AnalysisContext context) {
    final cls = subject.asClass;
    final publicMethods =
        cls.methods.where((m) => !m.name.startsWith('_')).toList();
    if (publicMethods.isEmpty) return const PredicateResult.pass();
    final names = publicMethods.map((m) => m.name).join(', ');
    return PredicateResult.fail('${cls.name} exposes public methods: $names');
  }
}
