import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../core/enums/rule_severity.dart';
import '../runner/arch_runner.dart';
import '../runner/arch_matchers.dart';
import '../utils/name_pattern_helper.dart';

/// Classes in each [folder] must match a naming pattern.
///
/// By default the expected suffix is derived from the capitalised folder
/// basename (e.g. `lib/service` → must end with `Service`).
///
/// Override with [suffix], [prefix], or a raw [namePattern]:
///
/// ```dart
/// // Auto-suffix from folder name
/// void main() => namingFolderSuffix(
///   folders: ['lib/service', 'lib/repository'],
/// );
///
/// // Explicit suffix
/// void main() => namingFolderSuffix(
///   folders: ['lib/bloc'],
///   suffix: 'Bloc',
/// );
///
/// // Prefix + suffix
/// void main() => namingFolderSuffix(
///   folders: ['lib/domain/repository'],
///   prefix: 'I',
///   suffix: 'Repository',
/// );
///
/// // Raw regex
/// void main() => namingFolderSuffix(
///   folders: ['lib/bloc'],
///   namePattern: r'.*(Bloc|Cubit)$',
/// );
/// ```
void namingFolderSuffix({
  required List<String> folders,
  String? namePattern,
  String? prefix,
  String? suffix,
  RuleSeverity severity = RuleSeverity.error,
  List<String> exceptions = const [],
  String projectRoot = '.',
}) {
  assert(
    namePattern == null || (prefix == null && suffix == null),
    'Use namePattern OR prefix/suffix, not both.',
  );

  testArchGroup(
    'Naming — folder name suffix',
    () {
      for (final folder in folders) {
        final effectivePattern = resolveNamePattern(
          namePattern: namePattern,
          prefix: prefix,
          suffix: suffix ?? _capitalize(p.basename(folder)),
        );

        final description = _buildDescription(folder, prefix, suffix, namePattern, p.basename(folder));

        testArch(description, (arch) {
          expect(
            arch.classes(folder: folder, exceptions: exceptions),
            nameMatchesPattern(effectivePattern!),
          );
        });
      }
    },
    severity: severity,
    projectRoot: projectRoot,
  );
}

String _buildDescription(
  String folder,
  String? prefix,
  String? suffix,
  String? namePattern,
  String folderBasename,
) {
  if (namePattern != null) {
    return 'Classes in "$folder" must match pattern "$namePattern"';
  }
  final effectiveSuffix = suffix ?? _capitalize(folderBasename);
  if (prefix != null) {
    return 'Classes in "$folder" must start with "$prefix" and end with "$effectiveSuffix"';
  }
  return 'Classes in "$folder" must end with "$effectiveSuffix"';
}

String _capitalize(String s) =>
    s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
