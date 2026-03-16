import 'dart:io';
import 'package:yaml/yaml.dart';
import '../core/entities/rule.dart';
import 'architecture_preset.dart';
import 'annotation_must_have_preset.dart';
import 'annotation_must_not_have_preset.dart';
import 'class_size_limit_preset.dart';
import 'layer_can_only_depend_on_preset.dart';
import 'layer_cannot_depend_on_preset.dart';
import 'layer_layered_architecture_preset.dart';
import 'must_be_abstract_preset.dart';
import 'must_be_immutable_preset.dart';
import 'naming_folder_suffix_preset.dart';
import 'naming_name_pattern_preset.dart';
import 'no_banned_calls_preset.dart';
import 'no_circular_dependencies_preset.dart';
import 'no_external_package_preset.dart';
import 'no_public_fields_preset.dart';

/// Reads a `presets:` YAML list and expands each entry into concrete
/// [Rule] objects by dispatching to the matching [ArchitecturePreset].
///
/// Unknown preset IDs produce a stderr warning and are skipped without throwing.
class PresetExpander {
  static final Map<String, ArchitecturePreset> _registry = {
    for (final preset in _all) preset.presetId: preset,
  };

  static final List<ArchitecturePreset> _all = [
    NamingFolderSuffixPreset(),
    NamingNamePatternPreset(),
    LayerCannotDependOnPreset(),
    LayerCanOnlyDependOnPreset(),
    LayerLayeredArchitecturePreset(),
    NoCircularDependenciesPreset(),
    ClassSizeLimitPreset(),
    MustBeAbstractPreset(),
    MustBeImmutablePreset(),
    AnnotationMustHavePreset(),
    AnnotationMustNotHavePreset(),
    NoPublicFieldsPreset(),
    NoExternalPackagePreset(),
    NoBannedCallsPreset(),
  ];

  /// Converts each entry in [presets] into one or more [Rule]s.
  List<Rule> expand(YamlList presets) {
    final rules = <Rule>[];
    for (final entry in presets) {
      if (entry is! YamlMap) continue;
      final presetId = entry['preset'] as String? ?? '';
      if (presetId.isEmpty) {
        stderr.writeln(
            'Warning: Preset entry is missing the "preset" key — skipped.');
        continue;
      }
      final handler = _registry[presetId];
      if (handler == null) {
        stderr.writeln('Warning: Unknown preset "$presetId" — skipped.');
        continue;
      }
      try {
        rules.addAll(handler.expand(entry));
      } on Object catch (e) {
        stderr.writeln(
            'Warning: Failed to expand preset "$presetId": $e — skipped.');
      }
    }
    return rules;
  }
}
