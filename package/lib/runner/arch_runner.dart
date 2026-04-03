import 'dart:async';
import 'package:test/test.dart';
import '../analyzer/context/analysis_context.dart';
import '../analyzer/project_analyzer.dart';
import '../core/enums/rule_severity.dart';
import 'arch_tester.dart';

part 'test_arch.dart';
part 'test_arch_group.dart';

final _contextStack = <AnalysisContext>[];

AnalysisContext? get _activeGroupContext => _contextStack.isEmpty ? null : _contextStack.last;

const _dartunitSeverityKey = #_dartunit_severity;

RuleSeverity? get _activeGroupSeverity => Zone.current[_dartunitSeverityKey] as RuleSeverity?;
