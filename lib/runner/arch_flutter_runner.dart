import 'dart:async';

import 'package:test/test.dart';

import '../analyzer/context/analysis_context.dart';
import '../analyzer/project_analyzer.dart';
import '../core/entities/arch_matcher.dart';
import '../core/enums/rule_severity.dart';
import 'arch_tester.dart';

part '../core/entities/test_arch.dart';
part '../core/entities/test_arch_group.dart';

// ---------------------------------------------------------------------------
// Group-context stack — allows nested testArchGroups to each share their own
// AnalysisContext without re-analyzing the project for each testArch inside.
// Pushed in setUpAll (execution time), popped in tearDownAll.
// ---------------------------------------------------------------------------
final _contextStack = <AnalysisContext>[];

AnalysisContext? get _activeGroupContext => _contextStack.isEmpty ? null : _contextStack.last;

// ---------------------------------------------------------------------------
// Group-severity — set synchronously during testArchGroup body registration
// so every testArch inside captures it at call time.
// Restored synchronously after body() so sibling groups don't inherit it.
// ---------------------------------------------------------------------------
RuleSeverity? _activeGroupSeverity;
