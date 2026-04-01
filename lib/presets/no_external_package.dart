import 'package:test/test.dart';

import '../core/enums/rule_severity.dart';
import '../runner/arch_flutter_runner.dart';
import '../runner/arch_matchers.dart';

/// Classes in each [folder] must not import any of the listed [packages].
///
/// ```dart
/// void main() => noExternalPackage(
///   packages: ['http', 'dio'],
///   folders: ['lib/domain'],
/// );
/// ```
void noExternalPackage({
  required List<String> packages,
  required List<String> folders,
  RuleSeverity severity = RuleSeverity.error,
  List<String> exceptions = const [],
  String projectRoot = '.',
}) {
  testArchGroup(
    'Dependency — no external packages: ${packages.join(', ')}',
    () {
      for (final folder in folders) {
        for (final pkg in packages) {
          testArch(
              'Classes in "$folder" must not import package "$pkg"', (arch) {
            expect(
              arch.classes(folder: folder, exceptions: exceptions),
              doesNotDependOnPackage(pkg),
            );
          });
        }
      }
    },
    severity: severity,
    projectRoot: projectRoot,
  );
}
