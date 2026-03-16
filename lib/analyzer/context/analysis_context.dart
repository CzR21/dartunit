import '../models/analyzed_class.dart';
import '../models/analyzed_file.dart';
import '../graph/dependency_graph.dart';

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

  const AnalysisContext({
    required this.classes,
    required this.files,
    required this.dependencyGraph,
    required this.projectRoot,
  });

  /// Returns all classes located in a folder that contains [folderPath].
  List<AnalyzedClass> classesInFolder(String folderPath) {
    final normalized = folderPath.replaceAll('\\', '/');
    return classes
        .where((c) => c.normalizedFilePath.contains(normalized))
        .toList();
  }

  /// Returns the class with the given [name], or null.
  AnalyzedClass? findClass(String name) {
    try {
      return classes.firstWhere((c) => c.name == name);
    } catch (_) {
      return null;
    }
  }

  /// Returns all files located in [folderPath].
  List<AnalyzedFile> filesInFolder(String folderPath) {
    final normalized = folderPath.replaceAll('\\', '/');
    return files
        .where((f) => f.filePath.replaceAll('\\', '/').contains(normalized))
        .toList();
  }
}
