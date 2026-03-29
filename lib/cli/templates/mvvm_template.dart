const List<({String fileName, String content})> mvvmRuleFiles = [
  (fileName: 'mvvm_layer_dependencies_arch_test.dart', content: _layerDependencies),
  (fileName: 'mvvm_contracts_arch_test.dart', content: _contracts),
  (fileName: 'mvvm_immutability_arch_test.dart', content: _immutability),
];

const String _layerDependencies = r'''
import 'package:dartunit/dartunit.dart';

// MVVM Architecture — Layer Dependency Rules
/// Reference: https://docs.flutter.dev/app-architecture/guide
///
/// Dependency flow: View → ViewModel → Repository → Service
///
/// - Views must not import data or services directly.
/// - ViewModels must be Flutter-agnostic (no package:flutter imports).
/// - Repositories must not reach into the View or ViewModel layers.
/// - Services hold read-only data access; they must not know about UI.
///
/// Adjust folder paths to match your project structure.
void main() {

  // Views (Widgets/Screens) should bind exclusively to ViewModels.
  // Direct access to repositories, services, or data models from a View breaks
  // the separation of concerns and makes the UI harder to test.
  testArchGroup('View layer — must bind to ViewModel only', [
    ArchitectureRule(
      description: 'Views must not access the data layer directly',
      severity: RuleSeverity.error,
      selector: ClassSelector(folder: 'lib/views'),
      predicate: NotPredicate(DependOnFolderPredicate('lib/data')),
    ),
    ArchitectureRule(
      description: 'Views must not access models directly (use ViewModel)',
      severity: RuleSeverity.error,
      selector: ClassSelector(folder: 'lib/views'),
      predicate: NotPredicate(DependOnFolderPredicate('lib/models')),
    ),
    ArchitectureRule(
      description: 'Views must not depend on services directly',
      severity: RuleSeverity.error,
      selector: ClassSelector(folder: 'lib/views'),
      predicate: NotPredicate(DependOnFolderPredicate('lib/services')),
    ),
  ]);

  /// ViewModels transform domain data into UI state and expose commands to the
  /// View. They must be framework-agnostic so they can be unit-tested without
  /// a widget tree. They should only consume repositories, never services
  /// or data sources directly.
  testArchGroup('ViewModel layer — Flutter-agnostic, no direct data access', [
    ArchitectureRule(
      description: 'ViewModels must not import package:flutter (UI-agnostic)',
      severity: RuleSeverity.error,
      selector: ClassSelector(namePattern: r'.*ViewModel$'),
      predicate: NotPredicate(DependOnPackagePredicate('flutter')),
    ),
    ArchitectureRule(
      description: 'ViewModels must not access the data layer directly',
      severity: RuleSeverity.error,
      selector: ClassSelector(namePattern: r'.*ViewModel$'),
      predicate: NotPredicate(DependOnFolderPredicate('lib/data')),
    ),
    ArchitectureRule(
      description: 'ViewModels must not depend on services directly (use repositories)',
      severity: RuleSeverity.warning,
      selector: ClassSelector(namePattern: r'.*ViewModel$'),
      predicate: NotPredicate(DependOnFolderPredicate('lib/services')),
    ),
  ]);

  /// Repositories orchestrate one or more services to provide a clean data API
  /// to ViewModels. Services wrap raw data sources (HTTP, DB). Neither layer
  /// should reach back into the UI.
  testArchGroup('Repository and Service layers — must not reach into UI', [
    ArchitectureRule(
      description: 'Repositories must not depend on views',
      severity: RuleSeverity.error,
      selector: ClassSelector(namePattern: r'.*Repository$'),
      predicate: NotPredicate(DependOnFolderPredicate('lib/views')),
    ),
    ArchitectureRule(
      description: 'Repositories must not depend on viewmodels',
      severity: RuleSeverity.error,
      selector: ClassSelector(namePattern: r'.*Repository$'),
      predicate: NotPredicate(DependOnFolderPredicate('lib/viewmodels')),
    ),
    ArchitectureRule(
      description: 'Services must not depend on views or viewmodels',
      severity: RuleSeverity.error,
      selector: ClassSelector(namePattern: r'.*Service$'),
      predicate: AndPredicate([
        NotPredicate(DependOnFolderPredicate('lib/views')),
        NotPredicate(DependOnFolderPredicate('lib/viewmodels')),
      ]),
    ),
  ]);
}
''';

const String _contracts = r'''
import 'package:dartunit/dartunit.dart';

/// arch_test/mvvm_contracts_arch_test.dart
///
/// MVVM Architecture — Contracts and Naming Rules
///
/// Validates:
///   - ViewModel cohesion: max public method count
///   - Repository interface: must be abstract (enables DI and testing)
///   - ViewModel naming: classes must follow the *ViewModel convention
///
/// Adjust thresholds and patterns to match your project.
void main() {

  // Repository interfaces allow ViewModels to depend on an abstraction rather
  // than a concrete class. This is the key enabler of unit testing ViewModels
  // without a network or database.
  testArchGroup('Repository contracts — abstract interfaces for testability', [
    ArchitectureRule(
      description: 'Repository interfaces must be abstract',
      severity: RuleSeverity.error,
      selector: ClassSelector(
        folder: 'lib/repositories',
        namePattern: r'(?!.*Impl$).*Repository$',
      ),
      predicate: IsAbstractPredicate(),
    ),
    ArchitectureRule(
      description: 'Repository implementations must not be abstract',
      severity: RuleSeverity.error,
      selector: ClassSelector(namePattern: r'.*RepositoryImpl$'),
      predicate: NotPredicate(IsAbstractPredicate()),
    ),
  ]);

  // A ViewModel with many public methods is doing too much. Each ViewModel
  // should serve a single View (or feature screen). Large ViewModels should be
  // split into smaller ones, each with a clear responsibility.
  testArchGroup('ViewModel cohesion — focused responsibility', [
    ArchitectureRule(
      description: 'ViewModels must have at most 10 public methods',
      severity: RuleSeverity.warning,
      selector: ClassSelector(namePattern: r'.*ViewModel$'),
      predicate: MaxMethodsPredicate(10),
    ),
    ArchitectureRule(
      description: 'ViewModels must have at most 15 imports',
      severity: RuleSeverity.warning,
      selector: ClassSelector(namePattern: r'.*ViewModel$'),
      predicate: MaxImportsPredicate(15),
    ),
  ]);
}
''';

const String _immutability = r'''
import 'package:dartunit/dartunit.dart';

/// arch_test/mvvm_immutability_arch_test.dart
///
/// MVVM Architecture — Immutability and Encapsulation Rules
///
/// Immutability in MVVM prevents accidental mutation of shared state.
/// Services should hold only final dependencies (injected at construction).
/// Models represent data snapshots and must not be mutated after creation.
///
/// Adjust naming patterns and folder paths to match your project.
void main() {

  // Models represent domain data. They should be immutable value objects so
  // that ViewModels can safely pass them to Views without risk of mutation.
  testArchGroup('Models — immutable value objects', [
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

  // Services are stateless infrastructure wrappers (API clients, cache adapters).
  // They should accept their dependencies via constructor injection and hold
  // them as final fields. A service with mutable state is hard to test and
  // difficult to reason about across concurrent requests.
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
