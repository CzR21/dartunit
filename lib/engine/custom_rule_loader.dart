import 'dart:io';
import 'package:path/path.dart' as p;

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
