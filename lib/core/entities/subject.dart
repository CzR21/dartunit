import '../../analyzer/models/analyzed_class.dart';

/// A subject is the unit that a predicate evaluates.
///
/// It wraps any selectable element (class, file) with a common interface.
class Subject {
  final String name;
  final String filePath;
  final int? line;
  final dynamic element;

  const Subject({
    required this.name,
    required this.filePath,
    required this.element,
    this.line,
  });

  /// Casts the inner element to [AnalyzedClass].
  AnalyzedClass get asClass => element as AnalyzedClass;

  @override
  String toString() => 'Subject($name @ $filePath)';
}

