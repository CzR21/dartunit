import '../../core/entities/selector.dart';
import '../../core/entities/subject.dart';
import '../../analyzer/context/analysis_context.dart';

/// Selects classes based on a configurable set of criteria.
///
/// All specified filters are applied together (logical AND).
/// Omitting a filter means "no restriction on that attribute".
///
/// Example — select all Bloc classes in lib/presentation:
/// ```dart
/// ClassSelector(folder: 'lib/presentation', namePattern: r'.*Bloc$')
/// ```
class ClassSelector extends Selector {
  /// Only select classes whose file path contains this folder segment.
  final String? folder;

  /// Only select classes whose name matches this regex pattern.
  final String? namePattern;

  /// Only select classes that carry this annotation (e.g. `'injectable'`).
  final String? annotatedWith;

  /// Only select classes that extend this type name.
  final String? extendsType;

  /// Only select classes that implement this interface name.
  final String? implementsType;

  /// Class names to exclude from selection (exact match).
  final List<String> excludeNames;

  const ClassSelector({
    this.folder,
    this.namePattern,
    this.annotatedWith,
    this.extendsType,
    this.implementsType,
    this.excludeNames = const [],
  });

  @override
  List<Subject> select(AnalysisContext context) {
    var classes = context.classes;

    if (folder != null) {
      classes = classes
          .where((c) => c.normalizedFilePath.contains(folder!))
          .toList();
    }

    if (namePattern != null) {
      final regex = RegExp(namePattern!);
      classes = classes.where((c) => regex.hasMatch(c.name)).toList();
    }

    if (annotatedWith != null) {
      classes = classes
          .where((c) => c.annotations.contains(annotatedWith))
          .toList();
    }

    if (extendsType != null) {
      classes =
          classes.where((c) => c.extendedType == extendsType).toList();
    }

    if (implementsType != null) {
      classes = classes
          .where((c) => c.implementedTypes.contains(implementsType))
          .toList();
    }

    if (excludeNames.isNotEmpty) {
      classes = classes.where((c) => !excludeNames.contains(c.name)).toList();
    }

    return classes
        .map((c) => Subject(
              name: c.name,
              filePath: c.filePath,
              element: c,
              line: c.line,
            ))
        .toList();
  }
}
