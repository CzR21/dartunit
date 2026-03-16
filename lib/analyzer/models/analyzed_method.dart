/// Represents an analyzed method or function inside a Dart class.
class AnalyzedMethod {
  /// The method name, e.g. `fetchUser`.
  final String name;

  /// The declared return type as a string, e.g. `Future<User>`.
  /// Defaults to `'dynamic'` when the return type cannot be inferred.
  final String returnType;

  /// Annotations applied to this method, e.g. `['override', 'visibleForTesting']`.
  final List<String> annotations;

  /// Whether the method is declared with the `static` modifier.
  final bool isStatic;

  /// Whether the method is declared `abstract` (in an abstract class).
  final bool isAbstract;

  /// Whether the method is annotated with `@override`.
  final bool isOverride;

  /// Source line number where the method is declared (1-based), or null.
  final int? line;

  const AnalyzedMethod({
    required this.name,
    required this.returnType,
    this.annotations = const [],
    this.isStatic = false,
    this.isAbstract = false,
    this.isOverride = false,
    this.line,
  });

  @override
  String toString() => 'AnalyzedMethod($name: $returnType)';
}
