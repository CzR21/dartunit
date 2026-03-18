import '../../analyzer/context/analysis_context.dart';
import '../../core/entities/selector.dart';
import '../../core/entities/subject.dart';

/// Selects analyzed files based on folder or name pattern.
///
/// Both filters are optional and combined with AND logic.
///
/// Example — select all files in lib/data whose name ends with `_impl`:
/// ```dart
/// FileSelector(folder: 'lib/data', namePattern: r'.*_impl\.dart$')
/// ```
class FileSelector extends Selector {
  /// Only select files whose path contains this folder segment.
  final String? folder;

  /// Only select files whose file name matches this regex pattern.
  final String? namePattern;

  /// File paths containing any of these folder segments are excluded.
  final List<String> excludeFolders;

  const FileSelector({
    this.folder,
    this.namePattern,
    this.excludeFolders = const [],
  });

  @override
  List<Subject> select(AnalysisContext context) {
    var files = context.files;

    if (folder != null) {
      files = files
          .where((f) =>
              f.filePath.replaceAll('\\', '/').contains(folder!))
          .toList();
    }

    if (namePattern != null) {
      final regex = RegExp(namePattern!);
      files = files.where((f) => regex.hasMatch(f.fileName)).toList();
    }

    if (excludeFolders.isNotEmpty) {
      files = files.where((f) {
        final path = f.filePath.replaceAll('\\', '/');
        return !excludeFolders.any((ex) => path.contains(ex.replaceAll('\\', '/')));
      }).toList();
    }

    return files
        .map((f) => Subject(
              name: f.fileName,
              filePath: f.filePath,
              element: f,
            ))
        .toList();
  }
}
