import 'package:yaml/yaml.dart';

import '../core/predicates/has_no_public_fields_predicate.dart';
import '../core/entities/rule.dart';
import '../core/entities/preset.dart';

/// Preset: `structure/no-public-fields`
///
/// Classes in the configured folders must not expose public (non-`_`) instance
/// fields. Enforces encapsulation by requiring state to be accessed through
/// methods or getters.
///
/// ```yaml
/// - preset: structure/no-public-fields
///   severity: error
///   folders:
///     - lib/domain
///   exceptions: []
/// ```
class NoPublicFieldsPreset extends Preset {
  @override
  String get presetId => 'structure/no-public-fields';

  @override
  List<Rule> expand(YamlMap config) {
    final sev = severity(config);
    return folders(config).map((folder) {
      return Rule(
        description:
            'Classes in "$folder" must not expose public instance fields',
        severity: sev,
        selector: classSelector(config, folder),
        predicate: const HasNoPublicFieldsPredicate(),
      );
    }).toList();
  }
}
