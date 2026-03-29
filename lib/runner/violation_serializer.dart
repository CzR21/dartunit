import '../core/entities/rule.dart';
import '../core/entities/violation.dart';

/// Serializes an [ArchitectureRule] and its [violations] into a JSON-compatible
/// map for the `DARTUNIT_RESULT:` protocol consumed by `dartunit analyze`.
Map<String, dynamic> serializeViolations(
  ArchitectureRule rule,
  List<Violation> violations,
) {
  return {
    'ruleDescription': rule.description,
    'severity': rule.severity.name,
    'violations': violations
        .map((v) => <String, dynamic>{
              'ruleDescription': v.ruleDescription,
              'message': v.message,
              'filePath': v.filePath,
              'severity': v.severity.name,
              if (v.line != null) 'line': v.line,
            })
        .toList(),
  };
}
