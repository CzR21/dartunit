import 'analyzed_method.dart';
import 'analyzed_field.dart';

/// Represents an analyzed Dart class, mixin, enum, or extension.
class AnalyzedClass {
  final String name;
  final String filePath;
  final String packagePath;
  final List<String> annotations;
  final List<String> imports;
  final String? extendedType;
  final List<String> implementedTypes;
  final List<String> mixinTypes;
  final List<AnalyzedMethod> methods;
  final List<AnalyzedField> fields;
  final bool isAbstract;
  final bool isMixin;
  final bool isEnum;
  final bool isExtension;
  final int? line;

  const AnalyzedClass({
    required this.name,
    required this.filePath,
    required this.packagePath,
    this.annotations = const [],
    this.imports = const [],
    this.extendedType,
    this.implementedTypes = const [],
    this.mixinTypes = const [],
    this.methods = const [],
    this.fields = const [],
    this.isAbstract = false,
    this.isMixin = false,
    this.isEnum = false,
    this.isExtension = false,
    this.line,
  });

  /// Returns the folder containing this class file.
  String get folder {
    final parts = filePath.replaceAll('\\', '/').split('/');
    return parts.sublist(0, parts.length - 1).join('/');
  }

  /// Returns the normalized file path using forward slashes.
  String get normalizedFilePath => filePath.replaceAll('\\', '/');

  /// Returns true if this class depends on files in [folderPath].
  bool dependsOnFolder(String folderPath) {
    final normalized = folderPath.replaceAll('\\', '/');
    return imports.any((imp) => imp.contains(normalized));
  }

  /// Returns true if this class directly imports [filePath].
  bool importsFile(String filePath) {
    return imports.contains(filePath);
  }

  @override
  String toString() => 'AnalyzedClass($name @ $filePath)';
}
