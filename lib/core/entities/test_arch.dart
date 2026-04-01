part of '../../runner/arch_flutter_runner.dart';

/// Registers a single architecture test, analogous to [testWidgets].
///
/// [body] receives an [ArchTester] to build selectors ("finders"), which are
/// then passed to [expect] with arch matchers:
///
/// ```dart
/// void main() => testArch('UI must not depend on data', (arch) {
///   final ui = arch.classes(folder: 'lib/ui');
///   expect(ui, doesNotDependOn('lib/data'));
/// });
/// ```
///
/// When called inside [testArchGroup], the project is analyzed once and the
/// context is shared across all tests in the group. When called standalone,
/// [projectRoot] is analyzed independently.
///
/// [severity] overrides the group severity (if any). Defaults to
/// [RuleSeverity.error] when called outside a group.
void testArch(
    String description,
    FutureOr<void> Function(ArchTester arch) body, {
      String projectRoot = '.',
      RuleSeverity? severity,
    }) {
  // Capture severity at registration time — testArchGroup sets
  // _activeGroupSeverity synchronously before calling body().
  final effectiveSeverity =
      severity ?? _activeGroupSeverity ?? RuleSeverity.error;

  test(description, () async {
    // Context is read at execution time — setUpAll has already populated the
    // stack by the time this test body runs.
    final context =
        _activeGroupContext ?? await ProjectAnalyzer(projectRoot).analyze();
    final tester = ArchTester(context, effectiveSeverity);
    await body(tester);
    // Violations were already printed by ArchMatcher inside expect().
    // Call fail() here, outside of expect(), so the test fails without
    // the Expected/Actual/Which block from package:matcher.
    if (tester.failures.isNotEmpty) {
      fail('');
    }
  });
}
