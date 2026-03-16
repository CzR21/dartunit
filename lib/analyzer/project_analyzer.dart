import 'dart:io';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:path/path.dart' as p;
import 'context/analysis_context.dart';
import 'graph/dependency_graph.dart';
import '../helpers/path_helper.dart';
import 'models/analyzed_file.dart';
import '../helpers/class_parser_helper.dart';
import 'parsers/import_parser.dart';

/// Analyzes a Dart/Flutter project and produces an [AnalysisContext].
///
/// Uses regex-based parsing — no compiler required. Fast on large codebases
/// but method/field counts may be inflated by matches inside string literals.
class ProjectAnalyzer {
  /// The root directory of the project to analyze.
  final String projectRoot;

  ProjectAnalyzer(this.projectRoot);

  /// Scans all `.dart` files under `<projectRoot>/lib/` and returns an
  /// [AnalysisContext] containing classes, files, and the dependency graph.
  Future<AnalysisContext> analyze() async {
    final packageName = PathHelper.readPackageName(projectRoot);
    final importParser = ImportParser(
      projectRoot: projectRoot,
      packageName: packageName,
    );
    const classParser = ClassParserHelper();

    final graph = DependencyGraph();
    final allFiles = <AnalyzedFile>[];
    final allClasses = <dynamic>[];

    for (final filePath in _discoverDartFiles()) {
      final content = await File(filePath).readAsString();
      final normalizedPath = PathHelper.normalize(filePath);
      final packagePath =
          PathHelper.toPackagePath(filePath, projectRoot, packageName);
      final imports = importParser.parse(filePath, content);

      allFiles.add(AnalyzedFile(
        filePath: normalizedPath,
        packagePath: packagePath,
        imports: imports,
      ));

      for (final imp in imports) {
        graph.addEdge(normalizedPath, PathHelper.normalize(imp));
      }

      allClasses.addAll(
        classParser.parse(filePath, packagePath, imports, content),
      );
    }

    return AnalysisContext(
      classes: List.of(allClasses.cast()),
      files: allFiles,
      dependencyGraph: graph,
      projectRoot: projectRoot,
    );
  }

  /// Returns all `.dart` files under `<projectRoot>/lib/` recursively.
  ///
  /// Only `lib/` is scanned — test files are excluded by design because
  /// architecture rules target production code.
  List<String> _discoverDartFiles() {
    final libDir = p.join(projectRoot, 'lib');
    final files = <String>[];

    if (Directory(libDir).existsSync()) {
      final glob = Glob('**.dart');
      for (final entity in glob.listSync(root: libDir)) {
        if (entity is File) files.add(entity.path);
      }
    }

    return files;
  }
}
