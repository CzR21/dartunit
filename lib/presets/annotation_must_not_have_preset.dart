import 'package:yaml/yaml.dart';
import '../core/predicates/not_annotated_with_predicate.dart';
import '../core/entities/rule.dart';
import '../core/entities/preset.dart';

/// Preset: `annotation/must-not-have`
///
/// Classes in the configured folders must NOT carry the specified annotation.
///
/// ```yaml
/// - preset: annotation/must-not-have
///   severity: error
///   annotation: injectable
///   folders:
///     - lib/ui
///   exceptions: []
/// ```
class AnnotationMustNotHavePreset extends Preset {
  @override
  String get presetId => 'annotation/must-not-have';

  @override
  List<Rule> expand(YamlMap config) {
    final sev = severity(config);
    final annotation = config['annotation'] as String;
    return folders(config).map((folder) {
      return Rule(
        id: 'PRESET_annotation_must_not_have_${annotation}_${safeId(folder)}',
        description:
            'Classes in "$folder" must NOT be annotated with @$annotation',
        severity: sev,
        selector: classSelector(config, folder),
        predicate: NotAnnotatedWithPredicate(annotation),
      );
    }).toList();
  }
}
