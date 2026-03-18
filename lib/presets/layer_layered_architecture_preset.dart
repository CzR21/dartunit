import 'package:yaml/yaml.dart';

import '../core/predicates/composite/not_predicate.dart';
import '../core/predicates/depend_on_folder_predicate.dart';
import '../core/entities/rule.dart';
import '../core/selector/class_selector.dart';
import '../core/entities/preset.dart';

/// Preset: `layer/layered-architecture`
///
/// Declares all layers with their allowed dependencies. For every pair (A, B)
/// where B is NOT in A's `can_access` list, a "must not depend on" rule is
/// generated automatically.
///
/// ```yaml
/// - preset: layer/layered-architecture
///   severity: error
///   exceptions: []
///   layers:
///     - name: ui
///       folder: lib/ui
///       can_access: [lib/bloc, lib/domain]
///     - name: bloc
///       folder: lib/bloc
///       can_access: [lib/domain]
///     - name: domain
///       folder: lib/domain
///       can_access: []
/// ```
class LayerLayeredPreset extends Preset {
  @override
  String get presetId => 'layer/layered-architecture';

  @override
  List<Rule> expand(YamlMap config) {
    final sev = severity(config);
    final exc = exceptions(config);
    final layersRaw = config['layers'] as YamlList;

    final layers = layersRaw.map((l) {
      final lm = l as YamlMap;
      return (
        name: lm['name'] as String,
        folder: lm['folder'] as String,
        canAccess: toList(lm['can_access']),
      );
    }).toList();

    final rules = <Rule>[];

    for (final from in layers) {
      for (final to in layers) {
        if (from.folder == to.folder) continue;
        if (from.canAccess.contains(to.folder)) continue;
        rules.add(Rule(
          id: 'PRESET_layered_${safeId(from.folder)}_no_${safeId(to.folder)}',
          description:
              'Layer "${from.name}" must not depend on layer "${to.name}"',
          severity: sev,
          selector: ClassSelector(folder: from.folder, excludeNames: exc),
          predicate: NotPredicate(DependOnFolderPredicate(to.folder)),
        ));
      }
    }

    return rules;
  }
}
