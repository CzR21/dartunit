import 'package:test/test.dart';

import '../core/enums/rule_severity.dart';
import '../runner/arch_runner.dart';
import '../runner/arch_matchers.dart';

/// Files must not contain any of the listed regex [patterns].
///
/// Operates on raw file content — suitable for banning `print()`,
/// `debugPrint()`, TODO comments, or any textual pattern.
///
/// ```dart
/// void main() => noBannedCalls(
///   patterns: [r'print\s*\(', r'debugPrint\s*\('],
///   excludeFolders: ['test'],
/// );
/// ```
void noBannedCalls({
  required List<String> patterns,
  List<String> excludeFolders = const [],
  RuleSeverity severity = RuleSeverity.error,
  String projectRoot = '.',
}) {
  testArchGroup(
    'Quality — no banned calls',
    () {
      for (final pattern in patterns) {
        testArch('Files must not contain banned pattern: $pattern', (arch) {
          expect(
            arch.files(exceptions: excludeFolders),
            hasNoContent(pattern),
          );
        });
      }
    },
    severity: severity,
    projectRoot: projectRoot,
  );
}
