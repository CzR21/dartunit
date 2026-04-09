import '../entities/violation.dart';
import '../enums/rule_severity.dart';

/// Sorting and counting helpers for violation lists.
extension ViolationListSort on List<Violation> {
  int get criticalCount => where((v) => v.severity == RuleSeverity.critical).length;
  int get errorCount    => where((v) => v.severity == RuleSeverity.error).length;
  int get warningCount  => where((v) => v.severity == RuleSeverity.warning).length;
  int get infoCount     => where((v) => v.severity == RuleSeverity.info).length;

  /// `true` when there are any error or critical violations.
  bool get hasFailures => criticalCount > 0 || errorCount > 0;

  /// Returns a new list sorted by severity (most severe first),
  /// then by rule description, then by file path.
  List<Violation> sortedBySeverity() {
    return [...this]..sort((a, b) {
      final bySev = b.severity.index.compareTo(a.severity.index);
      if (bySev != 0) return bySev;
      final byRule = a.ruleDescription.compareTo(b.ruleDescription);
      if (byRule != 0) return byRule;
      return a.filePath.compareTo(b.filePath);
    });
  }
}