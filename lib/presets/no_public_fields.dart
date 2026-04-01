import 'package:test/test.dart';

import '../core/enums/rule_severity.dart';
import '../runner/arch_flutter_runner.dart';
import '../runner/arch_matchers.dart';

/// Classes in each [folder] must not expose public instance fields.
///
/// ```dart
/// void main() => noPublicFields(
///   folders: ['lib/domain'],
/// );
/// ```
void noPublicFields({
  required List<String> folders,
  RuleSeverity severity = RuleSeverity.error,
  List<String> exceptions = const [],
  String projectRoot = '.',
}) {
  testArchGroup(
    'Structure — no public fields',
    () {
      for (final folder in folders) {
        testArch(
            'Classes in "$folder" must not expose public instance fields',
            (arch) {
          expect(
            arch.classes(folder: folder, exceptions: exceptions),
            hasNoPublicFields(),
          );
        });
      }
    },
    severity: severity,
    projectRoot: projectRoot,
  );
}
