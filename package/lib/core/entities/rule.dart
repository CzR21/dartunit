import '../enums/rule_severity.dart';
import '../extensions/string_extensions.dart';
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

  bool _isExcepted(String filePath) {
    final normalizedPath = filePath.normalized;
    return exceptions.any((e) {
      final norm = e.normalized;
      if (norm.endsWith('.dart')) {
        return normalizedPath.endsWith(norm) || normalizedPath == norm;
      }
      final prefix = norm.endsWith('/') ? norm : '$norm/';
      return normalizedPath.contains(prefix);
    });
  }

  @override
  String toString() => 'Rule($description)';
}