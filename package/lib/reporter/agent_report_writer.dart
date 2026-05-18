import 'dart:io';

import 'package:path/path.dart' as p;

import '../core/entities/violation.dart';
import '../core/enums/rule_severity.dart';

class AgentReportWriter {
  static const String _dirName = '.dartunit';
  static const String _fileName = 'agent_report.md';

  /// Writes `.dartunit/agent_report.md` and returns the absolute file path.
  String write({
    required String projectRoot,
    required List<Violation> violations,
    required int rulesCount,
    required List<String> ruleFiles,
    required DateTime timestamp,
  }) {
    final byCount = _countBySeverity(violations);
    final failures = byCount[RuleSeverity.error]! + byCount[RuleSeverity.critical]!;
    final status = violations.isEmpty ? 'passed' : 'failed';

    final buf = StringBuffer();

    buf.writeln('# DartUnit Analysis Report');
    buf.writeln();
    buf.writeln('Generated: ${timestamp.toIso8601String()}');
    buf.writeln('Project: $projectRoot');
    buf.writeln('Rule files:');
    for (final f in ruleFiles) {
      buf.writeln('- ${p.relative(f, from: projectRoot)}');
    }

    buf.writeln();
    buf.writeln('## Summary');
    buf.writeln();
    buf.writeln('- Rules analyzed: $rulesCount');
    buf.writeln('- Total violations: ${violations.length}');
    buf.writeln('- Failures: $failures');
    buf.writeln('- Warnings: ${byCount[RuleSeverity.warning]}');
    buf.writeln('- Info: ${byCount[RuleSeverity.info]}');
    buf.writeln('- Status: $status');

    if (violations.isNotEmpty) {
      buf.writeln();
      buf.writeln('## Violations');

      for (final v in violations) {
        buf.writeln();
        buf.writeln('### ${v.severity.name}');
        buf.writeln();
        buf.writeln('Rule: ${v.ruleDescription}');
        buf.writeln('File: ${p.relative(v.filePath, from: projectRoot)}');
        if (v.line != null) buf.writeln('Line: ${v.line}');
        buf.writeln('Message: ${v.message}');
      }
    }

    final dir = Directory(p.join(projectRoot, _dirName));
    if (!dir.existsSync()) dir.createSync(recursive: true);

    final outPath = p.join(dir.path, _fileName);
    File(outPath).writeAsStringSync(buf.toString());

    return outPath;
  }

  static Map<RuleSeverity, int> _countBySeverity(List<Violation> violations) {
    final counts = {
      for (final s in RuleSeverity.values) s: 0,
    };
    for (final v in violations) {
      counts[v.severity] = counts[v.severity]! + 1;
    }
    return counts;
  }
}
