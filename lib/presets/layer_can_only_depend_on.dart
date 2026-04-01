import 'package:test/test.dart';

import '../core/enums/rule_severity.dart';
import '../runner/arch_flutter_runner.dart';
import '../runner/arch_matchers.dart';

/// Classes in [layer] may ONLY import from the folders listed in [allowed].
///
/// ```dart
/// void main() => layerCanOnlyDependOn(
///   layer: 'lib/domain',
///   allowed: ['lib/domain', 'lib/shared'],
/// );
/// ```
void layerCanOnlyDependOn({
  required String layer,
  required List<String> allowed,
  RuleSeverity severity = RuleSeverity.error,
  List<String> exceptions = const [],
  String projectRoot = '.',
}) {
  testArch(
    '"$layer" can only depend on: ${allowed.join(', ')}',
    (arch) {
      expect(
        arch.classes(folder: layer, exceptions: exceptions),
        onlyDependsOnFolders(allowed),
      );
    },
    severity: severity,
    projectRoot: projectRoot,
  );
}
