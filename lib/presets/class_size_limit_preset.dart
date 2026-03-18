import 'package:yaml/yaml.dart';

import '../core/predicates/max_fields_predicate.dart';
import '../core/predicates/max_methods_predicate.dart';
import '../core/entities/rule.dart';
import '../core/entities/preset.dart';

/// Preset: `metrics/class-size-limit`
///
/// Limits the number of methods and/or fields per class. Generates one rule
/// per metric per folder. When [folders] is empty, applies to all classes.
///
/// ```yaml
/// - preset: metrics/class-size-limit
///   severity: warning
///   max_methods: 20
///   max_fields: 15
///   folders:
///     - lib
///   exceptions: []
/// ```
class ClassSizeLimitPreset extends Preset {
  @override
  String get presetId => 'metrics/class-size-limit';

  @override
  List<Rule> expand(YamlMap config) {
    final sev = severity(config);
    final maxMethods = config['max_methods'] as int?;
    final maxFields = config['max_fields'] as int?;
    final rawFolders = folders(config);
    final targets = rawFolders.isEmpty ? [''] : rawFolders;
    final rules = <Rule>[];

    for (final folder in targets) {
      final sel = classSelector(config, folder);
      final label = folder.isEmpty ? 'all' : safeId(folder);
      final scope = folder.isEmpty ? 'Classes' : 'Classes in "$folder"';

      if (maxMethods != null) {
        rules.add(Rule(
          id: 'PRESET_max_methods_$label',
          description: '$scope must have at most $maxMethods methods',
          severity: sev,
          selector: sel,
          predicate: MaxMethodsPredicate(maxMethods),
        ));
      }

      if (maxFields != null) {
        rules.add(Rule(
          id: 'PRESET_max_fields_$label',
          description: '$scope must have at most $maxFields fields',
          severity: sev,
          selector: sel,
          predicate: MaxFieldsPredicate(maxFields),
        ));
      }
    }

    return rules;
  }
}
