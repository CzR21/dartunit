import '../core/entities/rule.dart';
import '../core/entities/violation.dart';

class ReportHelper {

  /// Serializes an [ArchitectureRule] and its [violations] into a JSON-compatible
  /// map written as one NDJSON line to the temp file consumed by `dartunit analyze`.
  static Map<String, dynamic> serializeViolations(
      ArchitectureRule rule,
      List<Violation> violations,
      ) {
    return {
      'ruleDescription': rule.description,
      'severity': rule.severity.name,
      'violations': violations
          .map((v) => <String, dynamic>{
        'ruleDescription': v.ruleDescription,
        'message': v.message,
        'filePath': v.filePath,
        'severity': v.severity.name,
        if (v.line != null) 'line': v.line,
      })
          .toList(),
    };
  }

  /// Formats a human-readable test result line for terminal output.
  ///
  /// Pass:  `  ✓  Rule description`
  /// Fail:  `  ✗  Rule description`
  ///        `       ✗ lib/x.dart [error] — message`
  static String formatTestResult(ArchitectureRule rule, List<Violation> violations) {
    if (violations.isEmpty) {
      return '  \u2713  ${rule.description}';
    }
    final hasFailures = violations.any((v) => v.severity.isFailure);
    final icon = hasFailures ? '\u2717' : '\u26a0';
    final buf = StringBuffer('  $icon  ${rule.description}');
    for (final v in violations) {
      final vIcon = v.severity.isFailure ? '\u2717' : '\u26a0';
      buf.write('\n       $vIcon ${v.filePath} [${v.severity.name}] \u2014 ${v.message}');
    }
    return buf.toString();
  }

}
