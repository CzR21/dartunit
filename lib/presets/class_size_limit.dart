import 'package:test/test.dart';

import '../core/enums/rule_severity.dart';
import '../runner/arch_flutter_runner.dart';
import '../runner/arch_matchers.dart';

/// Limits the number of [maxMethods] and/or [maxFields] per class.
///
/// When [folders] is empty, applies to all classes in the project.
///
/// ```dart
/// void main() => classSizeLimit(
///   maxMethods: 20,
///   maxFields: 15,
///   folders: ['lib'],
/// );
/// ```
void classSizeLimit({
  int? maxMethods,
  int? maxFields,
  List<String> folders = const [],
  RuleSeverity severity = RuleSeverity.error,
  List<String> exceptions = const [],
  String projectRoot = '.',
}) {
  assert(
    maxMethods != null || maxFields != null,
    'classSizeLimit: provide at least one of maxMethods or maxFields.',
  );

  final targets = folders.isEmpty ? <String?>[null] : folders.map((f) => f as String?).toList();

  testArchGroup(
    'Metrics — class size limit',
    () {
      for (final folder in targets) {
        final scope = folder == null ? 'Classes' : 'Classes in "$folder"';
        if (maxMethods != null) {
          testArch('$scope must have at most $maxMethods methods', (arch) {
            expect(
              arch.classes(folder: folder, exceptions: exceptions),
              hasMaxMethods(maxMethods),
            );
          });
        }
        if (maxFields != null) {
          testArch('$scope must have at most $maxFields fields', (arch) {
            expect(
              arch.classes(folder: folder, exceptions: exceptions),
              hasMaxFields(maxFields),
            );
          });
        }
      }
    },
    severity: severity,
    projectRoot: projectRoot,
  );
}
