import 'package:test/test.dart';

import '../core/enums/rule_severity.dart';
import '../runner/arch_runner.dart';
import '../runner/arch_matchers.dart';

/// Classes in [from] must NOT import from any folder listed in [to].
///
/// ```dart
/// void main() => layerCannotDependOn(
///   from: 'lib/domain',
///   to: ['lib/data', 'lib/ui'],
/// );
/// ```
void layerCannotDependOn({
  required String from,
  required List<String> to,
  RuleSeverity severity = RuleSeverity.error,
  List<String> exceptions = const [],
  String projectRoot = '.',
}) {
  testArchGroup(
    '"$from" must not depend on: ${to.join(', ')}',
    () {
      for (final target in to) {
        testArch('"$from" must not depend on "$target"', (selector) {
          expect(
            selector.classes(inFolder: from, exceptions: exceptions),
            doesNotDependOn(target),
          );
        });
      }
    },
    severity: severity,
    projectRoot: projectRoot,
  );
}
