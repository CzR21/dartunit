import 'dart:convert';

import 'package:test/test.dart';

import '../analyzer/context/analysis_context.dart';
import '../core/entities/rule.dart';
import '../engine/rule_executor.dart';
import 'violation_serializer.dart';
import 'violation_report_formatter.dart';

/// Evaluates [rule] against [context], emits structured output for
/// `dartunit analyze`, and fails the test if any error-level violations exist.
void runRule(ArchitectureRule rule, AnalysisContext context) {
  final violations = const RuleExecutor().execute(rule, context);

  // Parsed by `dartunit analyze` from the dart-test --reporter json stream.
  print('DARTUNIT_RESULT:${jsonEncode(serializeViolations(rule, violations))}');

  if (violations.isNotEmpty) {
    print(formatViolationReport(rule, violations));
  }

  final failures = violations.where((v) => v.severity.isFailure).toList();
  expect(
    failures,
    isEmpty,
    reason: failures
        .map((v) => '  [${v.severity.name}] ${v.filePath}: ${v.message}')
        .join('\n'),
  );
}
