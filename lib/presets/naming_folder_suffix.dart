import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../core/enums/rule_severity.dart';
import '../runner/arch_flutter_runner.dart';
import '../runner/arch_matchers.dart';

/// Classes in each [folder] must end with the capitalised folder basename.
///
/// Example: classes in `lib/service` must end with `Service`.
///
/// ```dart
/// void main() => namingFolderSuffix(
///   folders: ['lib/service', 'lib/repository'],
/// );
/// ```
void namingFolderSuffix({
  required List<String> folders,
  RuleSeverity severity = RuleSeverity.error,
  List<String> exceptions = const [],
  String projectRoot = '.',
}) {
  testArchGroup(
    'Naming — folder name suffix',
    () {
      for (final folder in folders) {
        final suffix = _capitalize(p.basename(folder));
        testArch('Classes in "$folder" must end with "$suffix"', (arch) {
          expect(
            arch.classes(folder: folder, exceptions: exceptions),
            nameEndsWith(suffix),
          );
        });
      }
    },
    severity: severity,
    projectRoot: projectRoot,
  );
}

String _capitalize(String s) =>
    s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
