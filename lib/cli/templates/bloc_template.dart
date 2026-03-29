const List<({String fileName, String content})> blocRuleFiles = [
  (fileName: 'bloc_layer_dependencies_arch_test.dart', content: _layerDependencies),
  (fileName: 'bloc_contracts_arch_test.dart', content: _contracts),
  (fileName: 'bloc_quality_arch_test.dart', content: _quality),
];

const String _layerDependencies = r'''
import 'package:dartunit/dartunit.dart';

/// BLoC Architecture — Layer Dependency Rules
/// Reference: https://bloclibrary.dev/architecture/
///
/// Enforces the unidirectional dependency flow:
///   Presentation (BLoC/Cubit) → Domain → Data
///
/// Adjust folder paths to match your project structure.
void main() {
  
  // BLoCs and Cubits communicate with the domain through repositories and
  // use cases. They must never import directly from the data layer.
  testArchGroup('Presentation layer — must not access data directly', [
    ArchitectureRule(
      description: 'BLoC classes must not import from the data layer',
      severity: RuleSeverity.error,
      selector: ClassSelector(namePattern: r'.*Bloc$'),
      predicate: NotPredicate(DependOnFolderPredicate('lib/data')),
    ),
    ArchitectureRule(
      description: 'Cubit classes must not import from the data layer',
      severity: RuleSeverity.error,
      selector: ClassSelector(namePattern: r'.*Cubit$'),
      predicate: NotPredicate(DependOnFolderPredicate('lib/data')),
    ),
    ArchitectureRule(
      description: 'Presentation widgets must not import from the data layer',
      severity: RuleSeverity.error,
      selector: ClassSelector(folder: 'lib/presentation'),
      predicate: NotPredicate(DependOnFolderPredicate('lib/data')),
    ),
  ]);

  /// Domain is the innermost layer. It defines the business rules and contracts
  /// (abstract repositories, use cases, entities). It must know nothing about
  /// how data is fetched or how the UI is built — including the Flutter SDK.
  testArchGroup('Domain layer — must be pure and isolated', [
    ArchitectureRule(
      description: 'Domain must not depend on the presentation layer',
      severity: RuleSeverity.error,
      selector: ClassSelector(folder: 'lib/domain'),
      predicate: NotPredicate(DependOnFolderPredicate('lib/presentation')),
    ),
    ArchitectureRule(
      description: 'Domain must not depend on the BLoC layer',
      severity: RuleSeverity.error,
      selector: ClassSelector(folder: 'lib/domain'),
      predicate: NotPredicate(DependOnFolderPredicate('lib/blocs')),
    ),
    ArchitectureRule(
      description: 'Domain must not depend on the data layer',
      severity: RuleSeverity.error,
      selector: ClassSelector(folder: 'lib/domain'),
      predicate: NotPredicate(DependOnFolderPredicate('lib/data')),
    ),
    ArchitectureRule(
      description: 'Domain must be Flutter-agnostic — no package:flutter imports',
      severity: RuleSeverity.error,
      selector: ClassSelector(folder: 'lib/domain'),
      predicate: NotPredicate(DependOnPackagePredicate('flutter')),
    ),
  ]);

  /// The data layer implements the repository contracts defined in domain.
  /// It must not reach back up into the BLoC or presentation layers.
  testArchGroup('Data layer — must not reach back into presentation', [
    ArchitectureRule(
      description: 'Data layer must not depend on the presentation layer',
      severity: RuleSeverity.error,
      selector: ClassSelector(folder: 'lib/data'),
      predicate: NotPredicate(DependOnFolderPredicate('lib/presentation')),
    ),
    ArchitectureRule(
      description: 'Data layer must not depend on the BLoC layer',
      severity: RuleSeverity.error,
      selector: ClassSelector(folder: 'lib/data'),
      predicate: NotPredicate(DependOnFolderPredicate('lib/blocs')),
    ),
  ]);
}
''';

const String _contracts = r'''
import 'package:dartunit/dartunit.dart';

/// BLoC Architecture — Contracts, Naming and Immutability Rules
/// Reference: https://bloclibrary.dev/naming-conventions/
///
/// Validates:
///   - Repository pattern: abstract contract in domain, concrete impl in data
///   - Use cases: pure business logic, no framework dependencies
///   - State / Event objects: immutable (all fields final)
///
/// Adjust folder paths and naming patterns to match your project.
void main() {

  // Repository interfaces belong to domain — they define WHAT data operations
  // are available without specifying HOW they are performed.
  // Concrete implementations belong to data and must not be abstract.
  testArchGroup('Repository pattern — interface vs implementation', [
    ArchitectureRule(
      description: 'Repository interfaces in lib/domain must be abstract',
      severity: RuleSeverity.error,
      selector: ClassSelector(folder: 'lib/domain', namePattern: r'.*Repository$'),
      predicate: IsAbstractPredicate(),
    ),
    ArchitectureRule(
      description: 'Repository implementations must not be abstract',
      severity: RuleSeverity.error,
      selector: ClassSelector(namePattern: r'.*RepositoryImpl$'),
      predicate: NotPredicate(IsAbstractPredicate()),
    ),
    ArchitectureRule(
      description: 'Repository implementations must not import from presentation',
      severity: RuleSeverity.error,
      selector: ClassSelector(namePattern: r'.*RepositoryImpl$'),
      predicate: NotPredicate(DependOnFolderPredicate('lib/presentation')),
    ),
  ]);

  // Use cases encapsulate a single piece of business logic. They must remain
  // pure Dart — no Flutter framework, no direct data layer access.
  // A use case with too many methods is likely violating Single Responsibility.
  testArchGroup('Use cases — pure business logic', [
    ArchitectureRule(
      description: 'Use cases must not import from the data layer directly',
      severity: RuleSeverity.error,
      selector: ClassSelector(namePattern: r'.*UseCase$'),
      predicate: NotPredicate(DependOnFolderPredicate('lib/data')),
    ),
    ArchitectureRule(
      description: 'Use cases must be Flutter-agnostic',
      severity: RuleSeverity.error,
      selector: ClassSelector(namePattern: r'.*UseCase$'),
      predicate: NotPredicate(DependOnPackagePredicate('flutter')),
    ),
    ArchitectureRule(
      description: 'Use cases must have at most 3 methods (single responsibility)',
      severity: RuleSeverity.warning,
      selector: ClassSelector(namePattern: r'.*UseCase$'),
      predicate: MaxMethodsPredicate(3),
    ),
  ]);

  // In BLoC, state transitions are driven by events. Both states and events
  // must be immutable so that BLoC can compare them reliably and the UI can
  // rebuild deterministically. All fields should be final.
  testArchGroup('State and Event immutability', [
    ArchitectureRule(
      description: 'BLoC State classes must have all-final fields (immutable)',
      severity: RuleSeverity.error,
      selector: ClassSelector(namePattern: r'.*State$'),
      predicate: HasAllFinalFieldsPredicate(),
    ),
    ArchitectureRule(
      description: 'BLoC Event classes must have all-final fields (immutable)',
      severity: RuleSeverity.error,
      selector: ClassSelector(namePattern: r'.*Event$'),
      predicate: HasAllFinalFieldsPredicate(),
    ),
  ]);
}
''';

const String _quality = r'''
import 'package:dartunit/dartunit.dart';

/// BLoC Architecture — Domain Quality and Coupling Rules
///
/// Validates:
///   - Domain entities: immutable value objects, no public mutable state
///   - BLoC coupling: import count limits to prevent god-object BLoCs
///   - Data models: immutable DTOs that mirror domain entities
///
/// Adjust thresholds and folder paths to match your project.
void main() {

  // Entities represent core business concepts. They should be immutable value
  // objects with no exposure of internal mutable state. Keeping them
  // Flutter-agnostic allows reuse across platforms (mobile, web, server).
  testArchGroup('Domain entities — immutability and encapsulation', [
    ArchitectureRule(
      description: 'Domain entities must have all-final fields',
      severity: RuleSeverity.error,
      selector: ClassSelector(folder: 'lib/domain', namePattern: r'.*Entity$'),
      predicate: HasAllFinalFieldsPredicate(),
    ),
    ArchitectureRule(
      description: 'Domain entities must not expose public mutable fields',
      severity: RuleSeverity.error,
      selector: ClassSelector(folder: 'lib/domain', namePattern: r'.*Entity$'),
      predicate: HasNoPublicFieldsPredicate(),
    ),
  ]);

  // Data models (DTOs) carry data between the data layer and domain. They must
  // be immutable to avoid unintended mutation after deserialization.
  testArchGroup('Data models — immutable DTOs', [
    ArchitectureRule(
      description: 'Data model classes must have all-final fields',
      severity: RuleSeverity.warning,
      selector: ClassSelector(folder: 'lib/data', namePattern: r'.*Model$'),
      predicate: HasAllFinalFieldsPredicate(),
    ),
  ]);

  // A BLoC with many imports is doing too much. Limiting imports encourages
  // smaller, focused BLoCs that delegate to use cases rather than accumulating
  // business logic directly.
  testArchGroup('Coupling limits — prevent god-object BLoCs', [
    ArchitectureRule(
      description: 'BLoC classes must import at most 15 dependencies',
      severity: RuleSeverity.warning,
      selector: ClassSelector(namePattern: r'.*Bloc$'),
      predicate: MaxImportsPredicate(15),
    ),
    ArchitectureRule(
      description: 'Cubit classes must import at most 15 dependencies',
      severity: RuleSeverity.warning,
      selector: ClassSelector(namePattern: r'.*Cubit$'),
      predicate: MaxImportsPredicate(15),
    ),
  ]);
}
''';