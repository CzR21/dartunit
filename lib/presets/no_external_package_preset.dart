import 'package:yaml/yaml.dart';

import '../core/predicates/composite/not_predicate.dart';
import '../core/predicates/depend_on_package_predicate.dart';
import '../core/entities/rule.dart';
import '../core/entities/preset.dart';

/// Preset: `dependency/no-external-package`
///
/// Classes in the configured folders must not import from the listed packages.
/// Generates one rule per (folder, package) combination.
///
/// ```yaml
/// - preset: dependency/no-external-package
///   severity: error
///   packages:
///     - http
///     - dio
///   folders:
///     - lib/domain
///   exceptions: []
/// ```
class NoExternalPackagePreset extends Preset {
  @override
  String get presetId => 'dependency/no-external-package';

  @override
  List<Rule> expand(YamlMap config) {
    final sev = severity(config);
    final packages = toList(config['packages']);
    final rules = <Rule>[];

    for (final folder in folders(config)) {
      for (final pkg in packages) {
        rules.add(Rule(
          description: 'Classes in "$folder" must not import package "$pkg"',
          severity: sev,
          selector: classSelector(config, folder),
          predicate: NotPredicate(DependOnPackagePredicate(pkg)),
        ));
      }
    }

    return rules;
  }
}
