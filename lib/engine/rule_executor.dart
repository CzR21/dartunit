// rule_executor.dart
//
// Thin wrapper around [ArchitectureRule.evaluate] that provides isolation:
// any exception thrown during a single rule's evaluation is caught and
// converted into a synthetic violation so that the rest of the analysis
// can continue unaffected.

import '../analyzer/context/analysis_context.dart';
import '../core/entities/rule.dart';
import '../core/entities/violation.dart';

/// Executes a single [Rule] against an [AnalysisContext].
///
/// The executor is stateless and reusable across multiple rules.
/// Its primary responsibility is **fault isolation**: a buggy predicate
/// or selector must not crash the entire analysis run.
class RuleExecutor {
  const RuleExecutor();

  /// Evaluates [rule] against [context] and returns all detected violations.
  ///
  /// If [rule.evaluate] throws, a synthetic [Violation] describing the
  /// error is returned instead, preserving the rule's ID and severity.
  List<Violation> execute(
    Rule rule,
    AnalysisContext context,
  ) {
    try {
      return rule.evaluate(context);
    } catch (e) {
      // Prevent a single broken rule from crashing the entire analysis.
      // Return a synthetic violation so the reporter surfaces the problem.
      return [
        Violation(
          ruleId: rule.id,
          ruleDescription: rule.description,
          message: 'Rule evaluation error: $e',
          filePath: '',
          severity: rule.severity,
        ),
      ];
    }
  }
}
