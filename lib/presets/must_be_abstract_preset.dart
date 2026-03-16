import 'package:yaml/yaml.dart';

import '../core/predicates/is_abstract_predicate.dart';
import '../core/entities/rule.dart';
import 'architecture_preset.dart';

/// Preset: `structure/must-be-abstract`
///
/// All classes in the configured folders must be declared `abstract`.
/// Useful for enforcing that repository or service interfaces are never
/// accidentally made concrete.
///
/// ```yaml
/// - preset: structure/must-be-abstract
///   severity: error
///   folders:
///     - lib/domain/repository
///   exceptions: []
/// ```
class MustBeAbstractPreset extends ArchitecturePreset {
  @override
  String get presetId => 'structure/must-be-abstract';

  @override
  List<Rule> expand(YamlMap config) {
    final sev = severity(config);
    return folders(config).map((folder) {
      return Rule(
        id: 'PRESET_must_be_abstract_${safeId(folder)}',
        description: 'Classes in "$folder" must be abstract',
        severity: sev,
        selector: classSelector(config, folder),
        predicate: const IsAbstractPredicate(),
      );
    }).toList();
  }
}
