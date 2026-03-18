import '../../analyzer/context/analysis_context.dart';
import './subject.dart';

/// Base interface for all selectors.
///
/// A selector determines which elements of the codebase are evaluated
/// by a given rule.
abstract class Selector {
  const Selector();

  /// Returns all subjects from [context] that match this selector.
  List<Subject> select(AnalysisContext context);
}
