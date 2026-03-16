import 'dart:io';
import 'package:path/path.dart' as p;

import '../core/entities/rule.dart';

/// Interface that all custom rules must implement.
///
/// Custom rules live in `.dartunit/custom_rules/` and are loaded by the engine.
/// Because Dart does not support dynamic class loading without `dart:mirrors`
/// or native isolate compilation, custom rules are loaded via a generated
/// registry file (`custom_rules_registry.dart`) that the `generate` command
/// maintains automatically.
///
/// Example implementation:
/// ```dart
/// class NoRepositoryInUIRule implements CustomArchitectureRule {
///   @override
///   String get id => 'CUSTOM_NO_REPO_IN_UI';
///
///   @override
///   String get description => 'UI must not access repositories directly';
///
///   @override
///   ArchitectureRule build() {
///     return ArchitectureRule(
///       id: id,
///       description: description,
///       severity: RuleSeverity.error,
///       selector: ClassSelector(folder: 'lib/ui'),
///       predicate: NotPredicate(DependOnFolderPredicate('lib/data')),
///     );
///   }
/// }
/// ```
abstract class CustomArchitectureRule {
  String get id;
  String get description;
  Rule build();
}

/// Discovers custom rule Dart files in [customRulesDir].
///
/// Returns the list of file paths found. The actual loading of class
/// definitions is done via the generated registry.
class CustomRuleLoader {
  final String customRulesDir;

  CustomRuleLoader(this.customRulesDir);

  /// Returns paths to all `.dart` files inside [customRulesDir].
  List<String> discoverRuleFiles() {
    final dir = Directory(customRulesDir);
    if (!dir.existsSync()) return [];

    return dir
        .listSync(recursive: false)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart') &&
            !p.basename(f.path).startsWith('_'))
        .map((f) => f.path)
        .toList();
  }

  /// Prints a discovery summary to stdout.
  void printDiscoverySummary(List<String> files) {
    if (files.isEmpty) {
      stdout.writeln('  No custom rules found in $customRulesDir');
      return;
    }
    stdout.writeln('  Found ${files.length} custom rule file(s):');
    for (final f in files) {
      stdout.writeln('    - ${p.basename(f)}');
    }
  }
}
