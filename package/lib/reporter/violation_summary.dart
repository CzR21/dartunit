import '../core/enums/rule_severity.dart';
import '../core/entities/violation.dart';
import '../core/extensions/violation_list_extension.dart';

/// Aggregated counts of violations by severity level.
class ViolationSummary {
  final int total;
  final int critical;
  final int errors;
  final int warnings;
  final int infos;

  const ViolationSummary({
    required this.total,
    required this.critical,
    required this.errors,
    required this.warnings,
    required this.infos,
  });

  /// Computes the summary from a list of [violations].
  factory ViolationSummary.from(List<Violation> violations) {
    return ViolationSummary(
      total: violations.length,
      critical: violations.criticalCount,
      errors: violations.errorCount,
      warnings: violations.warningCount,
      infos: violations.infoCount,
    );
  }

  /// `true` when there are any error or critical violations.
  bool get hasFailures => errors > 0 || critical > 0;

  /// Pre-formatted summary line ready for terminal output.
  String get line =>
      '$total violation(s)'
      '  ·  ${RuleSeverity.critical.displayIcon}  $critical critical(s)'
      '  ·  ${RuleSeverity.error.displayIcon}  $errors error(s)'
      '  ·  ${RuleSeverity.warning.displayIcon}  $warnings warning(s)'
      '  ·  ${RuleSeverity.info.displayIcon}  $infos info';
}
