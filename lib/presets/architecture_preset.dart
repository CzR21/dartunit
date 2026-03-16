import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';
import '../core/enums/rule_severity.dart';
import '../core/entities/rule.dart';
import '../core/selector/class_selector.dart';

/// Base class for all built-in presets.
///
/// Provides shared helper methods so each concrete preset only needs to
/// implement [presetId] and [expand].
abstract class ArchitecturePreset {
  /// The YAML key that identifies this preset (e.g. `'naming/folder-name-suffix'`).
  String get presetId;

  /// Expands the preset configuration into one or more [Rule]s.
  List<Rule> expand(YamlMap config);

  // ---------------------------------------------------------------------------
  // Shared helpers
  // ---------------------------------------------------------------------------

  RuleSeverity severity(YamlMap cfg) =>
      RuleSeverity.fromString(cfg['severity'] as String? ?? 'error');

  List<String> exceptions(YamlMap cfg) => toList(cfg['exceptions']);

  List<String> folders(YamlMap cfg) => toList(cfg['folders']);

  /// Normalises a YAML value that may be a plain [String] or a [YamlList].
  List<String> toList(dynamic value) {
    if (value == null) return const [];
    if (value is String) return [value];
    return (value as YamlList).map((e) => e as String).toList();
  }

  /// Capitalises the first character of [s].
  String capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  /// Produces a safe ASCII segment for use inside rule IDs.
  String safeId(String path) => path
      .replaceAll(RegExp(r'[/\\]'), '_')
      .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');

  /// Shorthand for building a [ClassSelector] with the exception list applied.
  ClassSelector classSelector(YamlMap cfg, String folder) => ClassSelector(
        folder: folder.isEmpty ? null : folder,
        excludeNames: exceptions(cfg),
      );

  /// Extracts the last path segment of [folder] (e.g. `'lib/service'` → `'service'`).
  String folderBasename(String folder) => p.basename(folder);
}
