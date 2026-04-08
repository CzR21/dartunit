import 'package:test/test.dart';

import '../core/enums/rule_severity.dart';
import '../runner/arch_runner.dart';
import '../runner/arch_matchers.dart';
import '../utils/name_pattern_helper.dart';

/// Classes in each [folder] must have names matching a pattern.
///
/// Accepts a raw [namePattern] regex, or the friendlier [prefix]/[suffix]
/// shortcuts — but not both.
///
/// ```dart
/// // Raw regex
/// void main() => namingNamePattern(
///   namePattern: r'.*(Bloc|Cubit)$',
///   folders: ['lib/bloc'],
/// );
///
/// // Suffix shortcut
/// void main() => namingNamePattern(
///   suffix: 'Repository',
///   folders: ['lib/data'],
/// );
///
/// // Prefix + suffix
/// void main() => namingNamePattern(
///   prefix: 'I',
///   suffix: 'Repository',
///   folders: ['lib/domain/repository'],
/// );
/// ```
void namingNamePattern({
  String? namePattern,
  String? prefix,
  String? suffix,
  required List<String> folders,
  RuleSeverity severity = RuleSeverity.error,
  List<String> exceptions = const [],
  String projectRoot = '.',
}) {
  assert(
    namePattern == null || (prefix == null && suffix == null),
    'Use namePattern OR prefix/suffix, not both.',
  );
  assert(
    namePattern != null || prefix != null || suffix != null,
    'Provide at least one of: namePattern, prefix, or suffix.',
  );

  final effectivePattern = resolveNamePattern(
    namePattern: namePattern,
    prefix: prefix,
    suffix: suffix,
  )!;

  final label = _buildLabel(prefix, suffix, namePattern);

  testArchGroup(
    'Naming — $label',
    () {
      for (final folder in folders) {
        testArch('Classes in "$folder" must match $label', (arch) {
          expect(
            arch.classes(folder: folder, exceptions: exceptions),
            nameMatchesPattern(effectivePattern),
          );
        });
      }
    },
    severity: severity,
    projectRoot: projectRoot,
  );
}

String _buildLabel(String? prefix, String? suffix, String? namePattern) {
  if (namePattern != null) return 'pattern "$namePattern"';
  if (prefix != null && suffix != null) return 'prefix "$prefix" + suffix "$suffix"';
  if (prefix != null) return 'prefix "$prefix"';
  return 'suffix "$suffix"';
}
