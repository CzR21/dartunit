/// Severity levels for architecture rule violations.
///
/// Each value carries its display [label] and [ansiColor] so callers
/// never need to switch on severity for presentation purposes.
enum RuleSeverity {
  /// Informational — violation is noted but does not fail the analysis.
  info(
    label: 'ℹ️     ',
    ansiColor: '\x1B[36m',
  ),

  /// Warning — violation should be fixed but does not fail the build.
  warning(
    label: '⚠️  ',
    ansiColor: '\x1B[33m',
  ),

  /// Error — violation fails the analysis run.
  error(
    label: '❌    ',
    ansiColor: '\x1B[31m',
  ),

  /// Critical — violation represents a fundamental architecture breach.
  critical(
    label: '🚨 ',
    ansiColor: '\x1B[35m',
  );

  const RuleSeverity({required this.label, required this.ansiColor});

  /// Pre-formatted display label including emoji.
  final String label;

  /// ANSI escape code for coloured terminal output.
  final String ansiColor;

  static RuleSeverity fromString(String value) {
    return RuleSeverity.values.firstWhere(
      (s) => s.name == value.toLowerCase(),
      orElse: () => RuleSeverity.error,
    );
  }

  /// Returns true if this severity should cause the analysis to fail.
  bool get isFailure => this == error || this == critical;

  @override
  String toString() => name.toUpperCase();
}
