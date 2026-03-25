import 'package:yaml/yaml.dart';

import '../core/predicates/annotation_predicate.dart';
import '../core/entities/rule.dart';
import '../core/entities/preset.dart';

/// Preset: `annotation/must-have`
///
/// All classes in the configured folders must carry the specified annotation.
///
/// ```yaml
/// - preset: annotation/must-have
///   severity: error
///   annotation: injectable
///   folders:
///     - lib/data/repository
///   exceptions: []
/// ```
class AnnotationMustHavePreset extends Preset {
  @override
  String get presetId => 'annotation/must-have';

  @override
  List<Rule> expand(YamlMap config) {
    final sev = severity(config);
    final annotation = config['annotation'] as String;
    return folders(config).map((folder) {
      return Rule(
        description: 'Classes in "$folder" must be annotated with @$annotation',
        severity: sev,
        selector: classSelector(config, folder),
        predicate: AnnotatedWithPredicate(annotation),
      );
    }).toList();
  }
}
