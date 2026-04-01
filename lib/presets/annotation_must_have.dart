import 'package:test/test.dart';

import '../core/enums/rule_severity.dart';
import '../runner/arch_flutter_runner.dart';
import '../runner/arch_matchers.dart';

/// Classes in each [folder] must carry the annotation [@annotation].
///
/// ```dart
/// void main() => annotationMustHave(
///   annotation: 'injectable',
///   folders: ['lib/data/repository'],
/// );
/// ```
void annotationMustHave({
  required String annotation,
  required List<String> folders,
  RuleSeverity severity = RuleSeverity.error,
  List<String> exceptions = const [],
  String projectRoot = '.',
}) {
  testArchGroup(
    'Annotation — must have @$annotation',
    () {
      for (final folder in folders) {
        testArch(
            'Classes in "$folder" must be annotated with @$annotation',
            (arch) {
          expect(
            arch.classes(folder: folder, exceptions: exceptions),
            hasAnnotation(annotation),
          );
        });
      }
    },
    severity: severity,
    projectRoot: projectRoot,
  );
}
