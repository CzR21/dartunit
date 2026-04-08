import '../../utils/terminal_helper.dart';

/// Severity levels for architecture rule violations.
///
/// Each value carries its display [label], emoji [icon], and [ansiColor] so
/// callers never need to switch on severity for presentation purposes.
enum RuleSeverity {
  /// Informational — violation is noted but does not fail the analysis.
  info(
    label: 'INFO',
    icon: 'ℹ️',
    ansiColor: '\x1B[36m',
  ),

  /// Warning — violation should be fixed but does not fail the build.
  warning(
    label: 'WARN',
    icon: '⚠️',
    ansiColor: '\x1B[33m',
  ),

  /// Error — violation fails the analysis run.
  error(
    label: 'ERR',
    icon: '✖',
    ansiColor: '\x1B[31m',
  ),

  /// Critical — violation represents a fundamental architecture breach.
  critical(
    label: 'CRIT',
    icon: '🚨',
    ansiColor: '\x1B[35m',
  );

  const RuleSeverity({
    required this.label,
    required this.icon,
    required this.ansiColor,
  });

  /// Short ASCII label used in table cells (max 4 chars, terminal-safe).
  final String label;

  /// Emoji icon used in summary lines where column alignment is not required.
  final String icon;

  /// ANSI escape code for coloured terminal output.
  final String ansiColor;

  static RuleSeverity fromString(String value) {
    return RuleSeverity.values.firstWhere(
      (s) => s.name == value.toLowerCase(),
      orElse: () => RuleSeverity.error,
    );
  }

  /// Icon safe for the current terminal: emoji when Unicode is supported,
  /// plain [label] otherwise (e.g. `INFO`, `WARN`, `ERR`, `CRIT`).
  String get displayIcon =>
      TerminalHelper.supportsUnicode ? icon : label;

  /// Terminal column width of [displayIcon]: 1 for [error] (`✖`), 2 for all
  /// others (emoji icons occupy two columns in Unicode-capable terminals).
  int get iconDisplayWidth => this == error ? 1 : 2;

  /// Returns true if this severity should cause the analysis to fail.
  bool get isFailure => this == error || this == critical;

  @override
  String toString() => name.toUpperCase();
}
