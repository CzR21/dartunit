import '../../analyzer/context/analysis_context.dart';
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

/// Base interface for all selectors.
///
/// A selector determines which elements of the codebase are evaluated
/// by a given rule.
abstract class Selector {
  const Selector();

  /// Returns all subjects from [context] that match this selector.
  List<Subject> select(AnalysisContext context);
}
