import '../entities/violation.dart';

/// Sorting helpers for violation lists.
extension ViolationListSort on List<Violation> {
  /// Returns a new list sorted by severity (most severe first),
  /// then by rule ID, then by file path.
  List<Violation> sortedBySeverity() {
    return [...this]..sort((a, b) {
      final bySev = b.severity.index.compareTo(a.severity.index);
      if (bySev != 0) return bySev;
      final byRule = a.ruleId.compareTo(b.ruleId);
      if (byRule != 0) return byRule;
      return a.filePath.compareTo(b.filePath);
    });
  }
}