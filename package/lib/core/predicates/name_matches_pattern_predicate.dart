import '../../analyzer/context/analysis_context.dart';
import '../entities/subject.dart';
import '../entities/predicate.dart';

/// Passes if the subject's name matches the regex [pattern].
///
/// The pattern is compiled once at construction time and reused across subjects.
class NameMatchesPatternPredicate extends Predicate {
  final String pattern;
  late final RegExp _regex;

  NameMatchesPatternPredicate(this.pattern) {
    _regex = RegExp(pattern);
  }

  @override
  PredicateResult analyze(Subject subject, AnalysisContext context) {
    if (_regex.hasMatch(subject.name)) return const PredicateResult.pass();
    return PredicateResult.fail(
        '${subject.name} must match pattern "$pattern"');
  }
}
