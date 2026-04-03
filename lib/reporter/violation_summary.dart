import '../core/enums/rule_severity.dart';
import '../core/entities/violation.dart';

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
      critical: violations.where((v) => v.severity == RuleSeverity.critical).length,
      errors: violations.where((v) => v.severity == RuleSeverity.error).length,
      warnings: violations.where((v) => v.severity == RuleSeverity.warning).length,
      infos: violations.where((v) => v.severity == RuleSeverity.info).length,
    );
  }

  /// `true` when there are any error or critical violations.
  bool get hasFailures => errors > 0 || critical > 0;

  /// Pre-formatted summary line ready for terminal output.
  String get line =>
      '$total violation(s)'
      '  ·  ${RuleSeverity.critical.icon}  $critical critical(s)'
      '  ·  ${RuleSeverity.error.icon}  $errors error(s)'
      '  ·  ${RuleSeverity.warning.icon} $warnings warning(s)'
      '  ·  ${RuleSeverity.info.icon} $infos info';
}


