import '../core/entities/violation.dart';
import '../core/entities/rule.dart';

/// Formats a human-readable violation report block for terminal output.
String formatViolationReport(ArchitectureRule rule, List<Violation> violations) {
  final buf = StringBuffer();
  buf.writeln();
  buf.writeln('  ┌─ dartunit: ${rule.description}');
  for (final v in violations) {
    final icon = v.severity.isFailure ? '✗' : '⚠';
    buf.writeln('  │ $icon [${v.severity.name}] ${v.filePath}');
    buf.writeln('  │   ${v.message}');
  }
  buf.writeln('  │');
  buf.write('  └─ ${violations.length} violation(s) found');
  return buf.toString();
}
