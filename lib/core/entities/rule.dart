import '../enums/rule_severity.dart';
import 'violation.dart';
import '../../analyzer/context/analysis_context.dart';
import 'predicate.dart';
import 'selector.dart';

/// Represents a declared architecture rule.
///
/// A rule selects a set of elements with a [Selector] and then
/// evaluates a [Predicate] against each of them. Any element that
/// fails the predicate generates a [Violation].
class Rule {

  final String id;
  final String description;
  final RuleSeverity severity;
  final Selector selector;
  final Predicate predicate;

  const Rule({
    required this.id,
    required this.description,
    required this.severity,
    required this.selector,
    required this.predicate,
  });

  /// Evaluates the rule against the given [context] and returns all violations.
  List<Violation> evaluate(AnalysisContext context) {
    final subjects = selector.select(context);
    final violations = <Violation>[];

    for (final subject in subjects) {
      final result = predicate.evaluate(subject, context);
      if (!result.passed) {
        violations.add(Violation(
          ruleId: id,
          ruleDescription: description,
          message: result.message,
          filePath: subject.filePath,
          severity: severity,
          line: subject.line,
        ));
      }
    }

    return violations;
  }

  @override
  String toString() => 'Rule($id: $description)';
}
