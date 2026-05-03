import 'package:test/test.dart';

import '../core/enums/rule_severity.dart';
import '../runner/arch_runner.dart';
import '../runner/arch_matchers.dart';

/// All classes in each [folder] must be declared `abstract`.
///
/// ```dart
/// void main() => mustBeAbstract(
///   folders: ['lib/domain/repository'],
/// );
/// ```
void mustBeAbstract({
  required List<String> folders,
  RuleSeverity severity = RuleSeverity.error,
  List<String> exceptions = const [],
  String projectRoot = '.',
}) {
  testArchGroup(
    'Structure — must be abstract',
    () {
      for (final folder in folders) {
        testArch('Classes in "$folder" must be abstract', (selector) {
          expect(
            selector.classes(inFolder: folder, exceptions: exceptions),
            isAbstractClass(),
          );
        });
      }
    },
    severity: severity,
    projectRoot: projectRoot,
  );
}
