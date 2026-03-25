import 'dart:convert';
import 'dart:io';

import '../analyzer/project_analyzer.dart';
import '../core/entities/rule.dart';
import '../engine/rule_executor.dart';

/// Runs [rule] against the project and writes violations as JSON to stdout.
///
/// Call this from the `main()` of an arch_test rule file:
///
/// ```dart
/// void main(List<String> args) => archTest(args, myRule);
/// ```
///
/// The [args] list may contain `--path <dir>` to specify the project root.
/// If omitted, the current working directory is used.
Future<void> archTest(List<String> args, ArchitectureRule rule) async {
  String projectRoot = '.';
  for (var i = 0; i < args.length - 1; i++) {
    if (args[i] == '--path') {
      projectRoot = args[i + 1];
      break;
    }
  }

  final context = await ProjectAnalyzer(projectRoot).analyze();
  final violations = const RuleExecutor().execute(rule, context);

  final data = <String, dynamic>{
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

  stdout.writeln('DARTUNIT_RESULT:${jsonEncode(data)}');
}
