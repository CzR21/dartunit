import 'package:yaml/yaml.dart';

import '../core/predicates/composite/not_predicate.dart';
import '../core/predicates/depend_on_folder_predicate.dart';
import '../core/entities/rule.dart';
import 'architecture_preset.dart';

/// Preset: `layer/cannot-depend-on`
///
/// Classes in [from] must not import from any folder listed in [to].
/// [to] accepts either a single string or a list of strings.
///
/// ```yaml
/// - preset: layer/cannot-depend-on
///   severity: error
///   from: lib/domain
///   to:
///     - lib/data
///     - lib/ui
///   exceptions: []
/// ```
class LayerCannotDependOnPreset extends ArchitecturePreset {
  @override
  String get presetId => 'layer/cannot-depend-on';

  @override
  List<Rule> expand(YamlMap config) {
    final sev = severity(config);
    final from = config['from'] as String;
    final toFolders = toList(config['to']);
    return toFolders.map((to) {
      return Rule(
        id: 'PRESET_cannot_depend_${safeId(from)}_on_${safeId(to)}',
        description: '"$from" must not depend on "$to"',
        severity: sev,
        selector: classSelector(config, from),
        predicate: NotPredicate(DependOnFolderPredicate(to)),
      );
    }).toList();
  }
}
