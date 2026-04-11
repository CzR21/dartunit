import 'analyzed_method.dart';
import 'analyzed_field.dart';
import '../../core/extensions/string_extensions.dart';

/// Represents an analyzed Dart class, mixin, enum, or extension.
class AnalyzedClass {
  /// The simple class/mixin/enum/extension name as declared in source.
  final String name;

  /// The absolute or project-relative path to the file containing this element.
  final String filePath;

  /// The `package:` URI path used in import statements.
  final String packagePath;

  /// Annotation names applied to this element (without the leading `@`).
  final List<String> annotations;

  /// Resolved import paths of all `import` directives in this file.
  final List<String> imports;

  /// The name of the directly extended supertype, or `null` if none.
  final String? extendedType;

  /// Names of all interfaces this element implements.
  final List<String> implementedTypes;

  /// Names of all mixins applied with `with`.
  final List<String> mixinTypes;

  /// All methods declared directly in this element.
  final List<AnalyzedMethod> methods;

  /// All fields declared directly in this element.
  final List<AnalyzedField> fields;

  /// Whether this element is declared `abstract`.
  final bool isAbstract;

  /// Whether this element is declared as a `mixin`.
  final bool isMixin;

  /// Whether this element is declared as an `enum`.
  final bool isEnum;

  /// Whether this element is declared as an `extension`.
  final bool isExtension;

  /// The 1-based source line of the declaration, or `null` if unavailable.
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
    final parts = filePath.normalized.split('/');
    return parts.sublist(0, parts.length - 1).join('/');
  }

  /// Returns the normalized file path using forward slashes.
  String get normalizedFilePath => filePath.normalized;

  /// Returns true if this class depends on files in [folderPath].
  bool dependsOnFolder(String folderPath) =>
      imports.any((imp) => imp.contains(folderPath.normalized));

  /// Returns true if this class directly imports [filePath].
  bool importsFile(String filePath) {
    return imports.contains(filePath);
  }

  @override
  String toString() => 'AnalyzedClass($name @ $filePath)';
}
