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

  /// Analyzes [rule] against [context] and returns all detected violations.
  ///
  /// If [rule.analyze] throws, a synthetic [Violation] describing the
  /// error is returned instead, preserving the rule's ID and severity.
  List<Violation> execute(
    Rule rule,
    AnalysisContext context,
  ) {
    try {
      return rule.analyze(context);
    } catch (e) {
      // Prevent a single broken rule from crashing the entire analysis.
      // Return a synthetic violation so the reporter surfaces the problem.
      return [
        Violation(
          ruleDescription: rule.description,
          message: 'Rule analysis error: $e',
          filePath: '',
          severity: rule.severity,
        ),
      ];
    }
  }
}
