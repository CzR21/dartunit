import '../enums/rule_severity.dart';

/// Represents a single violation of an architecture rule.
///
/// A violation is produced when a [Subject] fails its [Predicate] check
/// during rule analysis. It carries enough context for the reporter
/// to display a meaningful error message with file location.
class Violation {

  /// The human-readable description of the violated rule.
  final String ruleDescription;

  /// A description of why this particular subject violated the rule.
  final String message;

  /// The forward-slash-normalised path to the file containing the violation.
  final String filePath;

  /// The source line of the violating element (1-based), or null.
  final int? line;

  /// The severity level of this violation.
  final RuleSeverity severity;

  const Violation({
    required this.ruleDescription,
    required this.message,
    required this.filePath,
    required this.severity,
    this.line,
  });

  @override
  String toString() =>
      '[$severity] $ruleDescription: $message in $filePath${line != null ? ':$line' : ''}';
}
