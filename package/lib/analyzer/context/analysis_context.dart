import '../models/analyzed_class.dart';
import '../models/analyzed_file.dart';
import '../graph/dependency_graph.dart';
import '../../core/extensions/string_extensions.dart';

/// Holds the full result of analyzing a Dart/Flutter project.
///
/// All selectors and predicates operate on this context.
class AnalysisContext {
  /// All classes discovered in the project.
  final List<AnalyzedClass> classes;

  /// All source files discovered in the project.
  final List<AnalyzedFile> files;

  /// The dependency graph built from import statements.
  final DependencyGraph dependencyGraph;

  /// The root path of the analyzed project.
  final String projectRoot;

  // Pre-built indexes for O(1) folder lookups instead of O(n) linear scans.
  late final Map<String, List<AnalyzedClass>> _classesByFolder;
  late final Map<String, List<AnalyzedFile>> _filesByFolder;
  late final Map<String, AnalyzedClass> _classByName;

  AnalysisContext({
    required this.classes,
    required this.files,
    required this.dependencyGraph,
    required this.projectRoot,
  }) {
    _classesByFolder = {};
    for (final c in classes) {
      final path = c.normalizedFilePath;
      final segments = path.split('/');
      // Index every ancestor folder prefix so "lib/data" matches
      // "lib/data/repos/user_repo.dart".
      for (var i = 1; i < segments.length; i++) {
        final prefix = segments.sublist(0, i).join('/');
        (_classesByFolder[prefix] ??= []).add(c);
      }
    }
    _classByName = {for (final c in classes) c.name: c};

    _filesByFolder = {};
    for (final f in files) {
      final path = f.filePath.normalized;
      final segments = path.split('/');
      for (var i = 1; i < segments.length; i++) {
        final prefix = segments.sublist(0, i).join('/');
        (_filesByFolder[prefix] ??= []).add(f);
      }
    }
  }

  /// Returns all classes located in a folder that contains [folderPath].
  List<AnalyzedClass> classesInFolder(String folderPath) {
    final key = folderPath.normalized.replaceAll(RegExp(r'/$'), '');
    return _classesByFolder[key] ?? [];
  }

  /// Returns the class with the given [name], or null.
  AnalyzedClass? findClass(String name) => _classByName[name];

  /// Returns all files located in [folderPath].
  List<AnalyzedFile> filesInFolder(String folderPath) {
    final key = folderPath.normalized.replaceAll(RegExp(r'/$'), '');
    return _filesByFolder[key] ?? [];
  }
}
