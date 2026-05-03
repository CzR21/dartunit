part of 'arch_runner.dart';

/// Registers a single architecture test, analogous to [testWidgets].
///
/// [body] receives an [ArchTester] to build selectors ("finders"), which are
/// then passed to [expect] with arch matchers:
///
/// ```dart
/// void main() => testArch('UI must not depend on data', (selector) {
///   final ui = selector.classes(inFolder: 'lib/ui');
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
  FutureOr<void> Function(ArchTester selector) body, {
  String projectRoot = '.',
  RuleSeverity? severity,
}) {
  final effectiveSeverity = _activeGroupSeverity ?? severity ?? RuleSeverity.error;

  test(description, () async {

    final context = _activeGroupContext ?? await ProjectAnalyzer(projectRoot).analyze();
    final tester = ArchTester(context, effectiveSeverity);
    await body(tester);

    if (tester.failures.isNotEmpty) {
      fail('');
    }
  });
}
