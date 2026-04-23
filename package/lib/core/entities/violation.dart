import '../enums/rule_severity.dart';

class Violation {
  
  final String ruleDescription;
  final String message;
  final String filePath;
  final int? line;
  final RuleSeverity severity;

  const Violation({
    required this.ruleDescription,
    required this.message,
    required this.filePath,
    required this.severity,
    this.line,
  });

  @override
  String toString() => '[$severity] $ruleDescription: $message in $filePath${line != null ? ':$line' : ''}';
}
