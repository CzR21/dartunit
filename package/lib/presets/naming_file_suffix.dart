import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../core/enums/rule_severity.dart';
import '../runner/arch_runner.dart';
import '../runner/arch_matchers.dart';
import '../utils/name_pattern_helper.dart';

/// Files in each [folder] must match a naming pattern.
///
/// By default the expected suffix is derived from the folder basename in
/// snake_case, appended with `.dart`
/// (e.g. `lib/services` → files must end with `_services.dart`).
///
void namingFileSuffix({
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
    'Naming — file suffix',
    () {
      for (final folder in folders) {
        final effectiveSuffix = suffix != null
            ? _ensureDartExtension(suffix)
            : '${p.basename(folder)}.dart';

        final effectivePattern = namePattern ??
            resolveNamePattern(
              prefix: prefix,
              suffix: effectiveSuffix,
            )!;

        final description = _buildDescription(
          folder, prefix, suffix, namePattern, p.basename(folder),
        );

        testArch(description, (arch) {
          expect(
            arch.files(folder: folder, exceptions: exceptions),
            nameMatchesPattern(effectivePattern),
          );
        });
      }
    },
    severity: severity,
    projectRoot: projectRoot,
  );
}

String _ensureDartExtension(String s) =>
    s.endsWith('.dart') ? s : '$s.dart';

String _buildDescription(
  String folder,
  String? prefix,
  String? suffix,
  String? namePattern,
  String folderBasename,
) {
  if (namePattern != null) {
    return 'Files in "$folder" must match pattern "$namePattern"';
  }
  final effectiveSuffix = suffix != null
      ? _ensureDartExtension(suffix)
      : '_$folderBasename.dart';
  if (prefix != null) {
    return 'Files in "$folder" must start with "$prefix" and end with "$effectiveSuffix"';
  }
  return 'Files in "$folder" must end with "$effectiveSuffix"';
}
