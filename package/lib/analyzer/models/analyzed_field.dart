/// Represents an analyzed field inside a Dart class.
class AnalyzedField {
  /// The field name, e.g. `_repository`.
  final String name;

  /// The declared type as a string, e.g. `UserRepository`.
  final String type;

  /// Annotations applied to this field, e.g. `['inject']`.
  final List<String> annotations;

  /// Whether the field is declared with the `static` modifier.
  final bool isStatic;

  /// Whether the field is declared `final`.
  final bool isFinal;

  /// Whether the field is declared `const`.
  final bool isConst;

  /// Source line number where the field is declared (1-based), or null.
  final int? line;

  const AnalyzedField({
    required this.name,
    required this.type,
    this.annotations = const [],
    this.isStatic = false,
    this.isFinal = false,
    this.isConst = false,
    this.line,
  });

  @override
  String toString() => 'AnalyzedField($name: $type)';
}
