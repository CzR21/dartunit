import 'dart:convert';
import 'dart:io';

import '../core/entities/violation.dart';
import '../core/enums/rule_severity.dart';

/// Reads the NDJSON results file written by [ArchMatcher] during a
/// `dart test` subprocess and reconstructs the [Violation] list.
///
/// Each line in the file is a self-contained JSON object:
/// ```json
/// {"ruleDescription":"...","severity":"error","violations":[...]}
/// ```
/// Lines that fail to decode are silently skipped.
class TestResultParser {
  const TestResultParser();

  /// Parses [file] and returns all violations found.
  ///
  /// [parsedRules] counts how many result lines were successfully decoded.
  /// The caller uses this to detect complete test failures (file missing or
  /// empty means no rule ran at all).
  ({List<Violation> violations, int parsedRules}) parseFile(File file) {
    if (!file.existsSync()) return (violations: [], parsedRules: 0);

    final violations = <Violation>[];
    var parsedRules = 0;

    for (final line in file.readAsLinesSync()) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      try {
        final json = jsonDecode(trimmed) as Map<String, dynamic>;
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
}
