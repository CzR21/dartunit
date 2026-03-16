import 'package:yaml/yaml.dart';

import '../core/predicates/only_depend_on_folders_predicate.dart';
import '../core/entities/rule.dart';
import 'architecture_preset.dart';

/// Preset: `layer/can-only-depend-on`
///
/// Classes in [layer] may only import from the folders listed in [allowed].
/// Any import that falls outside the allowed list is a violation.
///
/// ```yaml
/// - preset: layer/can-only-depend-on
///   severity: error
///   layer: lib/domain
///   allowed:
///     - lib/domain
///     - lib/shared
///   exceptions: []
/// ```
class LayerCanOnlyDependOnPreset extends ArchitecturePreset {
  @override
  String get presetId => 'layer/can-only-depend-on';

  @override
  List<Rule> expand(YamlMap config) {
    final layer = config['layer'] as String;
    final allowed = toList(config['allowed']);
    return [
      Rule(
        id: 'PRESET_can_only_depend_${safeId(layer)}',
        description: '"$layer" can only depend on: ${allowed.join(', ')}',
        severity: severity(config),
        selector: classSelector(config, layer),
        predicate: OnlyDependOnFoldersPredicate(allowed),
      )
    ];
  }
}
