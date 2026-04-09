import 'dart:io';
import 'package:path/path.dart' as p;
import '../core/extensions/string_extensions.dart';

/// Path utilities used throughout the analyzer.
class PathHelper {
  PathHelper._();

  /// Normalises [path] to use forward slashes for cross-platform consistency.
  static String normalize(String path) => path.normalized;

  /// Converts an absolute [filePath] to a `package:` URI when it lives under
  /// `<projectRoot>/lib/`. Returns the normalised path unchanged otherwise.
  static String toPackagePath(
    String filePath,
    String projectRoot,
    String packageName,
  ) {
    final normalized = normalize(filePath);
    final libPath = normalize(p.join(projectRoot, 'lib'));
    if (normalized.startsWith(libPath)) {
      return 'package:$packageName/${normalized.substring(libPath.length + 1)}';
    }
    return normalized;
  }

  /// Reads the project name from `<projectRoot>/pubspec.yaml`.
  ///
  /// Returns `'unknown'` if the file is missing or contains no `name:` field.
  static String readPackageName(String projectRoot) {
    final pubspec = File(p.join(projectRoot, 'pubspec.yaml'));
    if (!pubspec.existsSync()) return 'unknown';
    for (final line in pubspec.readAsLinesSync()) {
      if (line.startsWith('name:')) {
        return line.replaceFirst('name:', '').trim();
      }
    }
    return 'unknown';
  }
}
