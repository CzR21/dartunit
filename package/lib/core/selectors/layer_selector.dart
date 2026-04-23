import '../../analyzer/context/analysis_context.dart';
import '../../core/entities/selector.dart';
import '../../core/entities/subject.dart';

/// Selects all classes belonging to a named architectural layer.
///
/// A layer is defined by a folder path within the project. The [layerName]
/// is used only for display purposes; [layerFolder] drives the actual selection.
///
/// Example — select all classes in the Presentation layer:
/// ```dart
/// LayerSelector(layerName: 'Presentation', layerFolder: 'lib/presentation')
/// ```
class LayerSelector extends Selector {

  /// A human-readable label for the layer (used in rule descriptions).
  final String layerName;

  /// The folder path that defines the layer boundary, e.g. `'lib/domain'`.
  final String layerFolder;

  const LayerSelector({
    required this.layerName,
    required this.layerFolder,
  });

  @override
  List<Subject> select(AnalysisContext context) {
    return context
        .classesInFolder(layerFolder)
        .map((c) => Subject(
              name: c.name,
              filePath: c.filePath,
              element: c,
              line: c.line,
            ))
        .toList();
  }

  @override
  String toString() => 'LayerSelector($layerName: $layerFolder)';
}
