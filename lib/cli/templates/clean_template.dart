const List<({String fileName, String content})> cleanRuleFiles = [
  (fileName: 'clean_layer_dependencies_arch_test.dart', content: _layerDependencies),
  (fileName: 'clean_domain_contracts_arch_test.dart', content: _domainContracts),
  (fileName: 'clean_immutability_arch_test.dart', content: _immutability),
];

const String _layerDependencies = r'''
import 'package:dartunit/dartunit.dart';

/// Clean Architecture — Layer Dependency Rules
/// Reference: https://docs.flutter.dev/app-architecture/guide
///
/// The Dependency Rule: source code dependencies always point inward.
///   Presentation → Domain ← Data
///
/// Domain defines contracts; Data and Presentation depend on Domain.
/// Domain must never depend on either outer layer.
///
/// Adjust folder paths to match your project structure.
void main() {
  
  // Domain is the innermost layer. It defines the business rules, entities,
  // and repository contracts. It must be completely isolated from infrastructure
  // concerns (Flutter, HTTP clients, databases, platform APIs).
  testArchGroup('Domain layer — isolated from all outer layers', [
    ArchitectureRule(
      description: 'Domain must not depend on the data layer',
      severity: RuleSeverity.error,
      selector: ClassSelector(folder: 'lib/domain'),
      predicate: NotPredicate(DependOnFolderPredicate('lib/data')),
    ),
    ArchitectureRule(
      description: 'Domain must not depend on the presentation layer',
      severity: RuleSeverity.error,
      selector: ClassSelector(folder: 'lib/domain'),
      predicate: NotPredicate(DependOnFolderPredicate('lib/presentation')),
    ),
    ArchitectureRule(
      description: 'Domain must be Flutter-agnostic — no package:flutter imports',
      severity: RuleSeverity.error,
      selector: ClassSelector(folder: 'lib/domain'),
      predicate: NotPredicate(DependOnPackagePredicate('flutter')),
    ),
    ArchitectureRule(
      description: 'Domain must not use HTTP packages (use repository contracts instead)',
      severity: RuleSeverity.error,
      selector: ClassSelector(folder: 'lib/domain'),
      predicate: AndPredicate([
        NotPredicate(DependOnPackagePredicate('dio')),
        NotPredicate(DependOnPackagePredicate('http')),
      ]),
    ),
  ]);

  
  // Presentation orchestrates the UI and calls domain use cases.
  // It must never bypass the domain and reach directly into the data layer.
  testArchGroup('Presentation layer — must go through domain', [
    ArchitectureRule(
      description: 'Presentation must not access the data layer directly',
      severity: RuleSeverity.error,
      selector: ClassSelector(folder: 'lib/presentation'),
      predicate: NotPredicate(DependOnFolderPredicate('lib/data')),
    ),
  ]);

  
  // Data implements the repository contracts from domain. It must not introduce
  // reverse dependencies into the presentation layer.
  testArchGroup('Data layer — must not reach into presentation', [
    ArchitectureRule(
      description: 'Data layer must not depend on the presentation layer',
      severity: RuleSeverity.error,
      selector: ClassSelector(folder: 'lib/data'),
      predicate: NotPredicate(DependOnFolderPredicate('lib/presentation')),
    ),
  ]);
}
''';

const String _domainContracts = r'''
import 'package:dartunit/dartunit.dart';

/// Clean Architecture — Domain Contracts and Use Case Rules
///
/// Repository interfaces live in domain (abstract contracts).
/// Repository implementations live in data (concrete classes).
/// Use cases encapsulate one business operation each and must stay pure.
///
/// Adjust naming patterns and folder paths to match your project.
void main() {

  // The domain defines WHAT data operations exist via abstract repository
  // interfaces. The data layer provides HOW they are performed via concrete
  // implementations. This inversion of control (DIP) is the core of Clean Arch.
  testArchGroup('Repository contract — interface in domain, impl in data', [
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
      description: 'Repository implementations must not access the presentation layer',
      severity: RuleSeverity.error,
      selector: ClassSelector(namePattern: r'.*RepositoryImpl$'),
      predicate: NotPredicate(DependOnFolderPredicate('lib/presentation')),
    ),
  ]);

  // Each use case represents one user-facing business action (e.g., LoginUseCase,
  // FetchProductsUseCase). They must remain pure: no Flutter, no data access.
  // A use case that grows too large is a signal it should be split.
  testArchGroup('Use cases — single responsibility, pure Dart', [
    ArchitectureRule(
      description: 'Use cases must not depend on the data layer',
      severity: RuleSeverity.error,
      selector: ClassSelector(namePattern: r'.*UseCase$'),
      predicate: NotPredicate(DependOnFolderPredicate('lib/data')),
    ),
    ArchitectureRule(
      description: 'Use cases must not depend on the presentation layer',
      severity: RuleSeverity.error,
      selector: ClassSelector(namePattern: r'.*UseCase$'),
      predicate: NotPredicate(DependOnFolderPredicate('lib/presentation')),
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
}
''';

const String _immutability = r'''
import 'package:dartunit/dartunit.dart';

/// Clean Architecture — Immutability and Encapsulation Rules
///
/// Domain entities and value objects must be immutable: they represent business
/// facts that do not change after creation. Data models (DTOs) should also be
/// immutable to prevent bugs from accidental post-deserialization mutation.
///
/// Adjust naming patterns and folder paths to match your project.
void main() {

  // Entities are identified by their identity, not their attributes. They must
  // be immutable so their state cannot be altered outside their own boundary.
  // Mutable entities lead to subtle bugs when the same object is shared across
  // multiple BLoCs or widgets.
  testArchGroup('Domain entities — immutable value objects', [
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

  // Data models are DTOs created from API responses or database rows. Keeping
  // them immutable ensures that mapping them to domain entities is a pure
  // transformation with no side effects.
  testArchGroup('Data models — immutable DTOs', [
    ArchitectureRule(
      description: 'Data model classes must have all-final fields',
      severity: RuleSeverity.warning,
      selector: ClassSelector(folder: 'lib/data', namePattern: r'.*Model$'),
      predicate: HasAllFinalFieldsPredicate(),
    ),
    ArchitectureRule(
      description: 'Data models must not expose public mutable fields',
      severity: RuleSeverity.warning,
      selector: ClassSelector(folder: 'lib/data', namePattern: r'.*Model$'),
      predicate: HasNoPublicFieldsPredicate(),
    ),
  ]);
}
''';
