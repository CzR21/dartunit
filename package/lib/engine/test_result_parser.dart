import 'dart:convert';

import '../core/entities/violation.dart';
import '../core/enums/rule_severity.dart';

/// Parses the stderr output of a `dart test` subprocess and extracts
/// [Violation]s emitted via the `DARTUNIT_RESULT:` protocol.
///
/// Each compliant line has the form:
/// ```
/// DARTUNIT_RESULT:{"violations":[...]}
/// ```
/// Lines that do not start with the prefix are ignored.
class TestResultParser {
  const TestResultParser();

  static const _prefix = 'DARTUNIT_RESULT:';

  /// Parses [stderr] and returns all violations found.
  ///
  /// Also reports how many result lines were successfully decoded via
  /// [parsedRules], which the caller uses to detect complete test failures.
  ({List<Violation> violations, int parsedRules}) parse(String stderr) {
    final violations = <Violation>[];
    var parsedRules = 0;

    for (final line in stderr.split('\n')) {
      final trimmed = line.trim();
      if (!trimmed.startsWith(_prefix)) continue;
      try {
        final json = jsonDecode(trimmed.substring(_prefix.length))
            as Map<String, dynamic>;
        parsedRules++;
        for (final v in (json['violations'] as List).cast<Map<String, dynamic>>()) {
          violations.add(Violation(
            ruleDescription: v['ruleDescription'] as String,
            message: v['message'] as String,
            filePath: v['filePath'] as String,
            severity: RuleSeverity.fromString(v['severity'] as String),
            line: v['line'] as int?,
          ));
        }
      } catch (_) {
        // Malformed line — skip.
      }
    }

    return (violations: violations, parsedRules: parsedRules);
  }

  /// Returns only the non-protocol lines from [stderr], used to surface
  /// raw `dart test` errors to the user when parsing fails.
  String extractRawError(String stderr) => stderr
      .split('\n')
      .where((l) => !l.trim().startsWith(_prefix))
      .join('\n')
      .trim();
}
