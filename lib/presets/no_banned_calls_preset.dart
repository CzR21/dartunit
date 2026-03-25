import 'package:yaml/yaml.dart';

import '../core/predicates/composite/not_predicate.dart';
import '../core/predicates/content_predicate.dart';
import '../core/entities/rule.dart';
import '../core/selector/file_selector.dart';
import '../core/entities/preset.dart';

/// Preset: `quality/no-banned-calls`
///
/// Files must not contain any of the listed regex patterns. Operates on raw
/// file content via [FileSelector], making it suitable for banning `print()`,
/// `debugPrint()`, TODO comments, or any other textual pattern.
///
/// One rule is generated per pattern so violations are reported individually.
///
/// ```yaml
/// - preset: quality/no-banned-calls
///   severity: warning
///   patterns:
///     - 'print\s*\('
///     - 'debugPrint\s*\('
///   exclude_folders:
///     - test
/// ```
class NoBannedCallsPreset extends Preset {
  @override
  String get presetId => 'quality/no-banned-calls';

  @override
  List<Rule> expand(YamlMap config) {
    final sev = severity(config);
    final patterns = toList(config['patterns']);
    final excludeFolders = toList(config['exclude_folders']);
    final rules = <Rule>[];

    for (var i = 0; i < patterns.length; i++) {
      final pattern = patterns[i];
      rules.add(Rule(
        description: 'Files must not contain banned pattern: $pattern',
        severity: sev,
        selector: FileSelector(excludeFolders: excludeFolders),
        predicate: NotPredicate(
          FileContentMatchesPredicate(
            pattern,
            description: 'contains banned pattern "$pattern"',
          ),
        ),
      ));
    }

    return rules;
  }
}
