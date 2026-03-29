import 'dart:io';

/// Discovers architecture rule Dart files in [archTestDir].
///
/// Returns the list of file paths found. Files must end with `_arch_test.dart`.
class CustomRuleLoader {
  final String archTestDir;

  CustomRuleLoader(this.archTestDir);

  /// Returns paths to all `*_arch_test.dart` files inside [archTestDir].
  List<String> discoverRuleFiles() {
    final dir = Directory(archTestDir);
    if (!dir.existsSync()) return [];

    return dir
        .listSync(recursive: false)
        .whereType<File>()
        .where((f) => f.path.endsWith('_arch_test.dart'))
        .map((f) => f.path)
        .toList();
  }
}
