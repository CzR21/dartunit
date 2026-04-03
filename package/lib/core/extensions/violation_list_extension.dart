import '../entities/violation.dart';

/// Sorting helpers for violation lists.
extension ViolationListSort on List<Violation> {
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