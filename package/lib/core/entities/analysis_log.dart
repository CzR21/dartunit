import '../enums/rule_severity.dart';
import 'violation.dart';

/// A single recorded analysis run.
class AnalysisLog {
  final DateTime timestamp;
  final int rulesCount;
  final List<Violation> violations;

  const AnalysisLog({
    required this.timestamp,
    required this.rulesCount,
    required this.violations,
  });

  bool get passed => violations.isEmpty;
  int get errorCount => violations.where((v) => v.severity == RuleSeverity.error || v.severity == RuleSeverity.critical).length;
  int get warningCount => violations.where((v) => v.severity == RuleSeverity.warning).length;
  int get infoCount => violations.where((v) => v.severity == RuleSeverity.info).length;

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'rulesCount': rulesCount,
        'violations': violations
            .map((v) => {
                  'ruleDescription': v.ruleDescription,
                  'message': v.message,
                  'filePath': v.filePath,
                  'severity': v.severity.name,
                  if (v.line != null) 'line': v.line,
                })
            .toList(),
      };

  factory AnalysisLog.fromJson(Map<String, dynamic> json) {
    return AnalysisLog(
      timestamp: DateTime.parse(json['timestamp'] as String),
      rulesCount: (json['rulesCount'] as int?) ?? 0,
      violations: (json['violations'] as List)
          .cast<Map<String, dynamic>>()
          .map((v) => Violation(
                ruleDescription: v['ruleDescription'] as String,
                message: v['message'] as String,
                filePath: v['filePath'] as String,
                severity: RuleSeverity.fromString(v['severity'] as String),
                line: v['line'] as int?,
              ))
          .toList(),
    );
  }
}
