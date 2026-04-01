import 'package:test/test.dart';

import '../core/enums/rule_severity.dart';
import '../runner/arch_flutter_runner.dart';
import '../runner/arch_matchers.dart';

/// Declares all layers with their allowed dependencies and generates
/// "must not depend on" rules for every forbidden pair automatically.
///
/// ```dart
/// void main() => layeredArchitecture(
///   layers: [
///     (name: 'ui',     folder: 'lib/ui',     canAccess: ['lib/bloc', 'lib/domain']),
///     (name: 'bloc',   folder: 'lib/bloc',   canAccess: ['lib/domain']),
///     (name: 'domain', folder: 'lib/domain', canAccess: []),
///   ],
/// );
/// ```
void layeredArchitecture({
  required List<({String name, String folder, List<String> canAccess})> layers,
  RuleSeverity severity = RuleSeverity.error,
  List<String> exceptions = const [],
  String projectRoot = '.',
}) {
  testArchGroup(
    'Layered architecture',
    () {
      for (final from in layers) {
        for (final to in layers) {
          if (from.folder == to.folder) continue;
          if (from.canAccess.contains(to.folder)) continue;
          testArch(
              'Layer "${from.name}" must not depend on layer "${to.name}"',
              (arch) {
            expect(
              arch.classes(folder: from.folder, exceptions: exceptions),
              doesNotDependOn(to.folder),
            );
          });
        }
      }
    },
    severity: severity,
    projectRoot: projectRoot,
  );
}
