import 'package:yaml/yaml.dart';

import '../core/predicates/has_circular_dependency_predicate.dart';
import '../core/entities/rule.dart';
import '../core/selector/class_selector.dart';
import 'architecture_preset.dart';

/// Preset: `structure/no-circular-dependencies`
///
/// No file in the project may participate in a circular import chain.
/// Applies to all classes (no folder restriction).
///
/// ```yaml
/// - preset: structure/no-circular-dependencies
///   severity: error
/// ```
class NoCircularDependenciesPreset extends ArchitecturePreset {
  @override
  String get presetId => 'structure/no-circular-dependencies';

  @override
  List<Rule> expand(YamlMap config) => [
        Rule(
          id: 'PRESET_no_circular_dependencies',
          description: 'No circular dependencies allowed',
          severity: severity(config),
          selector: const ClassSelector(),
          predicate: const HasCircularDependencyPredicate(),
        )
      ];
}
