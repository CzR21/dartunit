import 'package:test/test.dart';

import '../core/enums/rule_severity.dart';
import '../runner/arch_runner.dart';
import '../runner/arch_matchers.dart';

/// Classes in each [folder] must have names matching [pattern].
///
/// ```dart
/// void main() => namingNamePattern(
///   pattern: r'.*(Bloc|Cubit)$',
///   folders: ['lib/bloc'],
/// );
/// ```
void namingNamePattern({
  required String pattern,
  required List<String> folders,
  RuleSeverity severity = RuleSeverity.error,
  List<String> exceptions = const [],
  String projectRoot = '.',
}) {
  testArchGroup(
    'Naming — name pattern "$pattern"',
    () {
      for (final folder in folders) {
        testArch('Classes in "$folder" must match pattern "$pattern"', (arch) {
          expect(
            arch.classes(folder: folder, exceptions: exceptions),
            nameMatchesPattern(pattern),
          );
        });
      }
    },
    severity: severity,
    projectRoot: projectRoot,
  );
}
