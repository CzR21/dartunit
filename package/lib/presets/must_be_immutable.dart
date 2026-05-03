import 'package:test/test.dart';

import '../core/enums/rule_severity.dart';
import '../runner/arch_runner.dart';
import '../runner/arch_matchers.dart';

/// All instance fields of classes in each [folder] must be `final`.
///
/// ```dart
/// void main() => mustBeImmutable(
///   folders: ['lib/domain/entities'],
/// );
/// ```
void mustBeImmutable({
  required List<String> folders,
  RuleSeverity severity = RuleSeverity.error,
  List<String> exceptions = const [],
  String projectRoot = '.',
}) {
  testArchGroup(
    'Structure — must be immutable',
    () {
      for (final folder in folders) {
        testArch('Classes in "$folder" must have all-final fields', (selector) {
          expect(
            selector.classes(inFolder: folder, exceptions: exceptions),
            hasAllFinalFields(),
          );
        });
      }
    },
    severity: severity,
    projectRoot: projectRoot,
  );
}
