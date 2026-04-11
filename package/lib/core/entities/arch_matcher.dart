import 'dart:convert';
import 'dart:io';
import '../../dartunit.dart';
import '../../utils/report_helper.dart';
import 'package:test/test.dart';

/// A [Matcher] that applies a [Predicate] to an [ArchSubject] and records
/// any violations produced.
///
/// Always returns `true` from [matches] — violations are collected on the
/// [ArchTester] rather than causing an immediate [expect] failure, so all
/// rules in a group are evaluated before the test fails.
class ArchMatcher extends Matcher {

  final Predicate _predicate;
  final String _description;

  const ArchMatcher(this._predicate, this._description);

  @override
  bool matches(Object? item, Map matchState) {
    if (item is! ArchSubject) return false;

    final rule = Rule(
      description: _description,
      severity: item.defaultSeverity,
      selector: item.selector,
      predicate: _predicate,
      exceptions: item.exceptions,
    );

    final violations = const RuleExecutor().execute(rule, item.context);

    if (Platform.environment['DARTUNIT_PROTOCOL'] == '1') {
      stderr.writeln('DARTUNIT_RESULT:${jsonEncode(ReportHelper.serializeViolations(rule, violations))}');
    }

    print(ReportHelper.formatTestResult(rule, violations));

    final failures = violations.where((v) => v.severity.isFailure).toList();
    item.tester.failures.addAll(failures);

    return true;
  }

  @override
  Description describe(Description description) =>
      description.add(_description);
}
