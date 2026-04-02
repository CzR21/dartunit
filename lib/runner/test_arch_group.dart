part of 'arch_runner.dart';

/// Groups related [testArch] calls, analyzing the project **once** for all of
/// them — analogous to [group] wrapping multiple tests with a shared setup.
///
/// ```dart
/// void main() {
///   testArchGroup('Domain isolation', () {
///     testArch('must not depend on data', (arch) {
///       expect(arch.classes(folder: 'lib/domain'), doesNotDependOn('lib/data'));
///     });
///     testArch('must be Flutter-agnostic', (arch) {
///       expect(arch.classes(folder: 'lib/domain'), doesNotDependOnPackage('flutter'));
///     });
///   }, severity: RuleSeverity.error);
/// }
/// ```
///
/// [severity] is inherited by every [testArch] inside [body] that does not
/// specify its own [severity]. Nested [testArchGroup]s override it for their
/// own children.
void testArchGroup(
  String groupName,
  void Function() body, {
  String projectRoot = '.',
  RuleSeverity severity = RuleSeverity.error,
}) {
  group(groupName, () {
    // --- Context: managed via stack at execution time ---
    setUpAll(() async {
      _contextStack.add(await ProjectAnalyzer(projectRoot).analyze());
    });

    tearDownAll(() {
      if (_contextStack.isNotEmpty) _contextStack.removeLast();
    });

    runZoned(body, zoneValues: {_dartunitSeverityKey: severity});
  });
}
