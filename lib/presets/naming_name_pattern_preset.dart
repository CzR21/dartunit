import 'package:yaml/yaml.dart';

import '../core/predicates/name_matches_pattern_predicate.dart';
import '../core/entities/rule.dart';
import '../core/entities/preset.dart';

/// Preset: `naming/name-pattern`
///
/// Classes in each configured folder must match the given regex [pattern].
///
/// ```yaml
/// - preset: naming/name-pattern
///   severity: error
///   pattern: '.*(Bloc|Cubit)$'
///   folders:
///     - lib/bloc
///   exceptions: []
/// ```
class NamingNamePatternPreset extends Preset {
  @override
  String get presetId => 'naming/name-pattern';

  @override
  List<Rule> expand(YamlMap config) {
    final sev = severity(config);
    final pattern = config['pattern'] as String;
    return folders(config).map((folder) {
      return Rule(
        id: 'PRESET_naming_pattern_${safeId(folder)}',
        description: 'Classes in "$folder" must match pattern "$pattern"',
        severity: sev,
        selector: classSelector(config, folder),
        predicate: NameMatchesPatternPredicate(pattern),
      );
    }).toList();
  }
}
