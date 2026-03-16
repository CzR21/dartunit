/// Represents an analyzed Dart source file.
class AnalyzedFile {
  /// The absolute, forward-slash-normalised path to this file.
  final String filePath;

  /// The `package:` URI for this file, e.g. `package:myapp/data/repo.dart`.
  final String packagePath;

  /// Resolved paths of all files imported by this file.
  final List<String> imports;

  /// Resolved paths of all files exported by this file.
  final List<String> exports;

  const AnalyzedFile({
    required this.filePath,
    required this.packagePath,
    required this.imports,
    this.exports = const [],
  });

  /// The directory containing this file (forward-slash separated).
  String get folder {
    final parts = filePath.replaceAll('\\', '/').split('/');
    return parts.sublist(0, parts.length - 1).join('/');
  }

  /// The file name, e.g. `user_repository.dart`.
  String get fileName => filePath.replaceAll('\\', '/').split('/').last;

  @override
  String toString() => 'AnalyzedFile($filePath)';
}
