import 'package:test/test.dart';

import '../core/enums/rule_severity.dart';
import '../runner/arch_runner.dart';
import '../runner/arch_matchers.dart';

/// No file in the project may participate in a circular import chain.
///
/// ```dart
/// void main() => noCircularDependencies();
/// ```
void noCircularDependencies({
  RuleSeverity severity = RuleSeverity.error,
  String projectRoot = '.',
}) {
  testArch(
    'No circular dependencies allowed',
    (selector) {
      expect(selector.classes(), hasNoCircularDependency());
    },
    severity: severity,
    projectRoot: projectRoot,
  );
}
