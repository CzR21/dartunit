import '../analyzer/context/analysis_context.dart';
import '../core/entities/rule.dart';
import '../core/entities/violation.dart';
import 'rule_executor.dart';

/// The central engine that runs all rules and collects violations.
///
/// Inject a custom [RuleExecutor] for testing or to add cross-cutting
/// concerns (e.g. timing, logging) around individual rule analyses.
class RuleEngine {

  /// The ordered list of rules to analyze.
  final List<Rule> rules;

  final RuleExecutor _executor;

  RuleEngine(this.rules, {RuleExecutor? executor})
      : _executor = executor ?? const RuleExecutor();

  /// Runs all [rules] against [context] and returns every violation found.
  ///
  /// Rules are analyzed in the order they appear in [rules]. Each rule
  /// is isolated: a failure in one rule does not abort the others.
  List<Violation> analyze(AnalysisContext context) {
    final violations = <Violation>[];

    for (final rule in rules) {
      final ruleViolations = _executor.execute(rule, context);
      violations.addAll(ruleViolations);
    }

    return violations;
  }

  /// Returns `true` if any `error` or `critical` violations were found.
  ///
  /// Used by [AnalyzeCommand] to decide the process exit code.
  bool hasFailures(List<Violation> violations) {
    return violations.any((v) => v.severity.isFailure);
  }

  /// Returns violations grouped by rule description for structured reporting.
  Map<String, List<Violation>> groupByRule(List<Violation> violations) {
    final grouped = <String, List<Violation>>{};
    for (final v in violations) {
      grouped.putIfAbsent(v.ruleDescription, () => []).add(v);
    }
    return grouped;
  }
}
