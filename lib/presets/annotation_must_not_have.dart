import 'package:test/test.dart';

import '../core/enums/rule_severity.dart';
import '../runner/arch_flutter_runner.dart';
import '../runner/arch_matchers.dart';

/// Classes in each [folder] must NOT carry the annotation [@annotation].
///
/// ```dart
/// void main() => annotationMustNotHave(
///   annotation: 'deprecated',
///   folders: ['lib/ui'],
/// );
/// ```
void annotationMustNotHave({
  required String annotation,
  required List<String> folders,
  RuleSeverity severity = RuleSeverity.error,
  List<String> exceptions = const [],
  String projectRoot = '.',
}) {
  testArchGroup(
    'Annotation — must NOT have @$annotation',
    () {
      for (final folder in folders) {
        testArch(
            'Classes in "$folder" must NOT be annotated with @$annotation',
            (arch) {
          expect(
            arch.classes(folder: folder, exceptions: exceptions),
            doesNotHaveAnnotation(annotation),
          );
        });
      }
    },
    severity: severity,
    projectRoot: projectRoot,
  );
}
