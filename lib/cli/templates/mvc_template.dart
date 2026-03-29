const List<({String fileName, String content})> mvcRuleFiles = [
  (fileName: 'mvc_layer_dependencies_arch_test.dart', content: _layerDependencies),
  (fileName: 'mvc_structure_arch_test.dart', content: _structure),
];

const String _layerDependencies = r'''
import 'package:dartunit/dartunit.dart';

/// MVC Architecture — Layer Dependency Rules
///
/// Model must have no knowledge of View or Controller.
/// View must interact with Controller only, not Model directly.
/// Controller is the only layer allowed to bridge View and Model.
/// Services hold shared business logic and must remain UI-agnostic.
///
/// Adjust folder paths to match your project structure.
void main() {

  // Models are the core of MVC: they hold business data and rules. They must
  // have no knowledge of who uses them — neither the View that displays them
  // nor the Controller that orchestrates them. This isolation makes Models
  // independently testable.
  testArchGroup('Model layer — must not know about View or Controller', [
    ArchitectureRule(
      description: 'Models must not depend on controllers',
      severity: RuleSeverity.error,
      selector: ClassSelector(folder: 'lib/models'),
      predicate: NotPredicate(DependOnFolderPredicate('lib/controllers')),
    ),
    ArchitectureRule(
      description: 'Models must not depend on views',
      severity: RuleSeverity.error,
      selector: ClassSelector(folder: 'lib/models'),
      predicate: NotPredicate(DependOnFolderPredicate('lib/views')),
    ),
    ArchitectureRule(
      description: 'Models must be Flutter-agnostic (no package:flutter imports)',
      severity: RuleSeverity.warning,
      selector: ClassSelector(folder: 'lib/models'),
      predicate: NotPredicate(DependOnPackagePredicate('flutter')),
    ),
  ]);

  // Views render what the Controller tells them to display. Bypassing the
  // Controller to access Model data directly breaks the MVC flow and couples
  // the View to business logic that it should never own.
  testArchGroup('View layer — must communicate through Controller', [
    ArchitectureRule(
      description: 'Views must not access models directly',
      severity: RuleSeverity.error,
      selector: ClassSelector(folder: 'lib/views'),
      predicate: NotPredicate(DependOnFolderPredicate('lib/models')),
    ),
    ArchitectureRule(
      description: 'Views must not access services directly',
      severity: RuleSeverity.error,
      selector: ClassSelector(folder: 'lib/views'),
      predicate: NotPredicate(DependOnFolderPredicate('lib/services')),
    ),
  ]);

  // Services provide shared business logic consumed by Controllers. They must
  // remain UI-agnostic — they should not know about Views or Controllers.
  testArchGroup('Service layer — must be UI-agnostic', [
    ArchitectureRule(
      description: 'Services must not depend on views',
      severity: RuleSeverity.error,
      selector: ClassSelector(namePattern: r'.*Service$'),
      predicate: NotPredicate(DependOnFolderPredicate('lib/views')),
    ),
    ArchitectureRule(
      description: 'Services must not depend on controllers',
      severity: RuleSeverity.error,
      selector: ClassSelector(namePattern: r'.*Service$'),
      predicate: NotPredicate(DependOnFolderPredicate('lib/controllers')),
    ),
  ]);
}
''';

const String _structure = r'''
import 'package:dartunit/dartunit.dart';

/// arch_test/mvc_structure_arch_test.dart
///
/// MVC Architecture — Structure and Quality Rules
///
/// Validates:
///   - Models: immutable data (all fields final, no public mutable state)
///   - Controllers: focused responsibility (max methods and imports)
///   - Services: stateless infrastructure (all fields final)
///
/// Adjust thresholds and patterns to match your project.
void main() {
  
  // In Flutter/Dart, mutable models cause subtle rebuild bugs. When a model
  // changes a field directly, the widget tree may not react. Prefer immutable
  // models where updates return a new instance (copyWith pattern), making
  // state changes explicit and predictable.
  testArchGroup('Model immutability — explicit state changes via copyWith', [
    ArchitectureRule(
      description: 'Model classes must have all-final fields',
      severity: RuleSeverity.error,
      selector: ClassSelector(folder: 'lib/models'),
      predicate: HasAllFinalFieldsPredicate(),
    ),
    ArchitectureRule(
      description: 'Model classes must not expose public mutable fields',
      severity: RuleSeverity.error,
      selector: ClassSelector(folder: 'lib/models'),
      predicate: HasNoPublicFieldsPredicate(),
    ),
  ]);

  // A Controller that grows too large is a classic MVC antipattern — the
  // "Massive View Controller". Limiting method count forces Controllers to
  // delegate to Services rather than accumulating all logic themselves.
  testArchGroup('Controller cohesion — avoid the massive controller', [
    ArchitectureRule(
      description: 'Controller classes must have at most 15 public methods',
      severity: RuleSeverity.warning,
      selector: ClassSelector(namePattern: r'.*Controller$'),
      predicate: MaxMethodsPredicate(15),
    ),
    ArchitectureRule(
      description: 'Controller classes must import at most 12 dependencies',
      severity: RuleSeverity.warning,
      selector: ClassSelector(namePattern: r'.*Controller$'),
      predicate: MaxImportsPredicate(12),
    ),
  ]);

  // Services encapsulate shared business logic. They should be stateless:
  // accept dependencies via constructor and hold them as final fields.
  // Mutable state in a Service creates hidden coupling between Controllers.
  testArchGroup('Services — stateless and injectable', [
    ArchitectureRule(
      description: 'Service classes must have all-final fields (stateless)',
      severity: RuleSeverity.error,
      selector: ClassSelector(namePattern: r'.*Service$'),
      predicate: HasAllFinalFieldsPredicate(),
    ),
  ]);
}
''';