import 'package:yaml/yaml.dart';

import '../core/predicates/has_all_final_fields_predicate.dart';
import '../core/entities/rule.dart';
import 'architecture_preset.dart';

/// Preset: `structure/must-be-immutable`
///
/// All instance fields in classes within the configured folders must be
/// `final` or `const`. Enforces immutability for entities, value objects,
/// and other domain types.
///
/// ```yaml
/// - preset: structure/must-be-immutable
///   severity: error
///   folders:
///     - lib/domain/entities
///   exceptions: []
/// ```
class MustBeImmutablePreset extends ArchitecturePreset {
  @override
  String get presetId => 'structure/must-be-immutable';

  @override
  List<Rule> expand(YamlMap config) {
    final sev = severity(config);
    return folders(config).map((folder) {
      return Rule(
        id: 'PRESET_must_be_immutable_${safeId(folder)}',
        description: 'Classes in "$folder" must have all final fields',
        severity: sev,
        selector: classSelector(config, folder),
        predicate: const HasAllFinalFieldsPredicate(),
      );
    }).toList();
  }
}
