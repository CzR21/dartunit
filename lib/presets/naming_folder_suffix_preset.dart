import 'package:yaml/yaml.dart';

import '../core/predicates/name_ends_with_predicate.dart';
import '../core/entities/rule.dart';
import 'architecture_preset.dart';

/// Preset: `naming/folder-name-suffix`
///
/// Classes in each configured folder must end with the capitalised folder
/// basename. For example, classes in `lib/service` must end with `Service`.
///
/// ```yaml
/// - preset: naming/folder-name-suffix
///   severity: error
///   folders:
///     - lib/service
///     - lib/repository
///   exceptions:
///     - BaseService
/// ```
class NamingFolderSuffixPreset extends ArchitecturePreset {
  @override
  String get presetId => 'naming/folder-name-suffix';

  @override
  List<Rule> expand(YamlMap config) {
    final sev = severity(config);
    return folders(config).map((folder) {
      final suffix = capitalize(folderBasename(folder));
      return Rule(
        id: 'PRESET_naming_suffix_${safeId(folder)}',
        description: 'Classes in "$folder" must end with "$suffix"',
        severity: sev,
        selector: classSelector(config, folder),
        predicate: NameEndsWithPredicate(suffix),
      );
    }).toList();
  }
}
