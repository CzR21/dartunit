import '../enums/rule_severity.dart';
import 'violation.dart';
import '../../analyzer/context/analysis_context.dart';
import 'predicate.dart';
import 'selector.dart';

/// Represents a declared architecture rule.
///
/// A rule selects a set of elements with a [Selector] and then
/// analyzes a [Predicate] against each of them. Any element that
/// fails the predicate generates a [Violation].
class Rule {

  final String description;
  final RuleSeverity severity;
  final Selector selector;
  final Predicate predicate;

  /// File path substrings that are exempt from this rule.
  ///
  /// A violation is suppressed when its [Violation.filePath] contains
  /// any entry in this list. Accepts full paths, partial paths, or
  /// folder prefixes (e.g. `'lib/legacy/'`, `'generated/models.dart'`).
  final List<String> exceptions;

  const Rule({
    required this.description,
    this.severity = RuleSeverity.error,
    required this.selector,
    required this.predicate,
    this.exceptions = const [],
  });

  /// Analyzes the rule against the given [context] and returns all violations.
  ///
  /// Violations whose [Violation.filePath] matches any entry in [exceptions]
  /// are silently discarded.
  List<Violation> analyze(AnalysisContext context) {
    final subjects = selector.select(context);
    final violations = <Violation>[];

    for (final subject in subjects) {
      if (_isExcepted(subject.filePath)) continue;
      final result = predicate.analyze(subject, context);
      if (!result.passed) {
        violations.add(Violation(
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

  bool _isExcepted(String filePath) =>
      exceptions.any((e) => filePath.contains(e));

  @override
  String toString() => 'Rule($description)';
}

/// Alias for [Rule] — use this name in test_arch rule files.
typedef ArchitectureRule = Rule;
