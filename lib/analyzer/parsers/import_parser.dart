import 'package:path/path.dart' as p;
import '../../utils/path_helper.dart';

/// Parses and resolves `import` statements from Dart source text.
class ImportParser {
  final String projectRoot;
  final String packageName;

  const ImportParser({required this.projectRoot, required this.packageName});

  static final _importRegex = RegExp(
    r'''import\s+['"]([^'"]+)['"]\s*(?:as\s+\w+\s*)?;''',
  );

  /// Returns the resolved import paths found in [content].
  ///
  /// [filePath] is the absolute path of the file being parsed, used to
  /// resolve relative imports.
  List<String> parse(String filePath, String content) {
    final imports = <String>[];
    final fileDir = p.dirname(filePath);

    for (final match in _importRegex.allMatches(content)) {
      final uri = match.group(1)!;

      // SDK built-ins have no file path — skip them.
      if (uri.startsWith('dart:')) continue;

      if (uri.startsWith('package:')) {
        if (uri.startsWith('package:$packageName/')) {
          // Intra-project package import — resolve to an absolute file path.
          final relative = uri.replaceFirst('package:$packageName/', '');
          imports.add(PathHelper.normalize(p.join(projectRoot, 'lib', relative)));
        } else {
          // External package — keep the URI as-is for graph edges.
          imports.add(uri);
        }
        continue;
      }

      // Relative import — resolve against the importing file's directory.
      imports.add(PathHelper.normalize(p.normalize(p.join(fileDir, uri))));
    }

    return imports;
  }
}
