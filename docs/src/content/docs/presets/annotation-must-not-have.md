---
title: annotationMustNotHave
description: Enforce that classes in specified folders do NOT carry certain annotations. Prevent domain entities from being annotated with infrastructure concerns like @JsonSerializable or @Entity.
sidebar:
  order: 14
---

`annotationMustNotHave` enforces that no class in specified folders carries a particular annotation. It is a boundary enforcement rule — it prevents annotation-implied dependencies and layer violations from creeping into folders where they do not belong. Common use cases include preventing `@JsonSerializable` from appearing in the domain layer, banning `@Entity` (ORM annotations) from domain entities, preventing `@visibleForTesting` from appearing on production service classes, and excluding `@injectable` from pure data model classes.

## The Annotation Boundary Problem

Annotations in Dart are not merely documentation. They are metadata that frameworks act upon, and they often carry strong implications about dependencies and architectural placement:

- **`@JsonSerializable`** (from `json_annotation`) implies that the class is part of the data serialization layer. Using it requires `json_annotation` in `pubspec.yaml` and runs `build_runner` code generation. A domain entity with `@JsonSerializable` is now coupled to JSON serialization infrastructure.

- **`@Entity`** (from ORM packages like `floor`, `drift`, or Isar) marks a class for database mapping. A domain class with `@Entity` is coupled to the database layer — it knows its own persistence schema, which violates the separation between domain logic and data storage.

- **`@injectable`** (from the `injectable` DI package) marks a class for dependency injection registration. Pure data model classes (value objects, DTOs, entities used only as data holders) should not be registered with DI — they are created with constructors, not injected. A data model annotated with `@injectable` will confuse the DI container.

- **`@visibleForTesting`** marks a member as accessible only from test code. If this annotation appears on a class in a production `lib/` folder (outside of test support utilities), it is a signal that the class was not properly designed for its context.

When these annotations appear where they shouldn't, they pull in inappropriate dependencies, reveal layer violations, and make the architecture harder to understand and maintain. `annotationMustNotHave` catches these violations at CI time, before they're merged into the main branch.

## How Annotations Imply Dependencies

Annotations that seem harmless on the surface can carry deep dependency implications. Consider the full chain triggered by `@JsonSerializable`:

1. `@JsonSerializable` requires `json_annotation` in `dependencies` or `dev_dependencies`.
2. Using it in the domain layer means `json_annotation` is a domain dependency.
3. `json_annotation` is an infrastructure concern — it is not a domain concept.
4. Domain tests now potentially require `build_runner` to have run before tests execute.
5. Other teams importing the domain layer also inherit the `json_annotation` dependency.
6. The domain layer's contract has expanded to include serialization concerns.

This is not a theoretical concern. It happens in real projects when developers reach for convenient serialization in domain code because "it's just an annotation." The annotation is small; the dependency it implies is not.

Similarly, `@Entity` from a database ORM implies:

1. A dependency on the ORM package in domain code.
2. The class's field names are tied to the database column schema (ORM annotations often use field names as column names by default).
3. Changing a field name to better reflect domain language requires a database migration.
4. Domain language is now constrained by storage concerns.

`annotationMustNotHave` makes these boundary violations visible and automatically enforced.

## The `@visibleForTesting` Production Code Problem

`@visibleForTesting` (from `package:meta/meta.dart`) is intended for members that would normally be private but need to be accessible in test code without being part of the public API. It is a deliberate design acknowledgment that a class has test-facing internals.

When `@visibleForTesting` appears on a class in a production `lib/` folder (not in a test support file), it typically means the class was extracted for testability but not properly designed:

```dart
// lib/services/payment_service.dart — PROBLEMATIC
@visibleForTesting
class PaymentGatewayAdapter {
  // This class exists only so tests can access it
  // But it's in the production lib/ folder
  ...
}
```

This is an anti-pattern. Either:
- The class should be private and properly encapsulated (tests should test the public interface).
- The class is a legitimate abstraction that should be public without `@visibleForTesting`.
- The class belongs in a test support library, not in `lib/`.

Banning `@visibleForTesting` from `lib/` (outside of specific test support directories) surfaces this design smell.

## Separation of Concerns Through Annotation Boundaries

Well-designed layers have distinct annotation vocabularies:

| Layer | Appropriate annotations | Inappropriate annotations |
|---|---|---|
| Domain entities | `@immutable`, `@sealed`, custom domain annotations | `@JsonSerializable`, `@Entity`, `@injectable`, `@HiveType` |
| Application / BLoC | `@immutable` (states), `@injectable` (services) | `@JsonSerializable`, `@Entity`, `@visibleForTesting` |
| Data / Infrastructure | `@JsonSerializable`, `@Entity`, `@HiveType` | `@immutable` (mutable data classes), `@visibleForTesting` |
| Presentation / UI | `@override` (build), navigation annotations | `@injectable`, `@Entity`, `@JsonSerializable` |

`annotationMustNotHave` can enforce the "Inappropriate" column for each layer.

## The Asymmetry With `annotationMustHave`

The two annotation presets serve fundamentally different purposes:

**`annotationMustHave` — Completeness:**
"Every class in this folder must have annotation X. If any class is missing it, that is an error of omission — something was forgotten."

**`annotationMustNotHave` — Boundaries:**
"No class in this folder may have annotation Y. If any class has it, that is an error of commission — something was placed incorrectly or an inappropriate dependency was introduced."

Both presets can apply to the same folder with different annotations, creating a complete annotation policy:

```
lib/domain/entities/
  ✓ Must have: @immutable, @sealed
  ✗ Must not have: @JsonSerializable, @Entity, @injectable, @HiveType
```

## Function Signature

```dart
void annotationMustNotHave({
  required String annotation,
  required List<String> folders,
  RuleSeverity severity = RuleSeverity.error,
  List<String> exceptions = const [],
  String projectRoot = '.',
})
```

## Parameters

### `folders`

**Type:** `List<String>` — required

The folders where the annotation is forbidden. All classes in these folders (and subdirectories) are checked. Any class that carries the annotation produces a violation.

```dart
folders: ['lib/domain', 'lib/domain/entities'],
```

Be specific: targeting `'lib/domain'` applies the restriction to all subdirectories, including `lib/domain/entities`, `lib/domain/value_objects`, `lib/domain/services`, etc.

### `annotation`

**Type:** `String` — required

The annotation name to forbid, without the `@` prefix. Case-sensitive.

```dart
annotation: 'JsonSerializable',  // Forbids @JsonSerializable
annotation: 'Entity',            // Forbids @Entity
annotation: 'visibleForTesting', // Forbids @visibleForTesting
annotation: 'injectable',        // Forbids @injectable
annotation: 'HiveType',          // Forbids @HiveType (Hive ORM)
```

### `severity`

**Type:** `RuleSeverity` — default `RuleSeverity.error`

For boundary violations (domain layer importing infrastructure annotations), `RuleSeverity.error` is appropriate. These violations represent architectural missteps with concrete negative consequences. They should block CI immediately.

`RuleSeverity.warning` can be useful when first scanning an existing codebase to understand the scope of violations before making them blocking.

### `exceptions`

**Type:** `List<String>` — default `[]`

Class names excluded from the prohibition. Use this for legitimate exceptions — classes in the restricted folder that genuinely need the annotation for a specific, documented reason.

```dart
exceptions: [
  'EventLog',  // Domain event persisted directly — @Entity is intentional here
],
```

Document WHY each exception exists. Unexplained exceptions become permanent technical debt.

## Usage

```dart
// test_arch/domain_annotation_boundaries_arch_test.dart
import 'package:dartunit/dartunit.dart';

void main() => annotationMustNotHave(
  annotation: 'JsonSerializable',
  folders: ['lib/domain'],
  severity: RuleSeverity.error,
);
```

Run:

```
dart run dartunit analyze
```

## Examples

### Example 1: Domain Entities Must Not Have `@JsonSerializable`

The canonical use case. JSON serialization is a data layer concern — it describes how a class is represented in a wire format, which is an infrastructure detail irrelevant to domain logic.

```dart
// test_arch/domain_no_json_arch_test.dart
import 'package:dartunit/dartunit.dart';

void main() => annotationMustNotHave(
  annotation: 'JsonSerializable',
  folders: ['lib/domain', 'lib/domain/entities', 'lib/domain/value_objects'],
  severity: RuleSeverity.error,
);
```

This catches:

```dart
// VIOLATION: domain entity with JSON serialization annotation
import 'package:json_annotation/json_annotation.dart';

part 'product.g.dart';

@JsonSerializable()  // VIOLATION — infrastructure annotation in domain layer
class Product {
  final String id;
  final String name;
  final Money price;

  Product({required this.id, required this.name, required this.price});

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);
}
```

Violation message:

```
VIOLATION [error] annotationMustNotHave[@JsonSerializable]
  File: lib/domain/entities/product.dart
  Class: Product
  Forbidden annotation: @JsonSerializable
  Reason: lib/domain must not contain @JsonSerializable annotations.
          JSON serialization is a data layer concern.
          Create a ProductDto in lib/data/dtos/ with @JsonSerializable
          and a mapper that converts between ProductDto and Product.
```

The correct architecture separates the domain entity from its serialized form:

```
lib/domain/entities/product.dart         → Product (pure domain, no JSON)
lib/data/dtos/product_dto.dart           → ProductDto (has @JsonSerializable)
lib/data/mappers/product_mapper.dart     → ProductMapper.toDomain(dto) / toDto(entity)
```

### Example 2: Domain Layer Must Not Have `@Entity` (ORM Annotations)

Database ORM annotations like `@Entity` (Floor), `@DataClassName` (Drift), `@HiveType` (Hive), or `@Collection` (Isar) all represent database schema definitions. Domain classes annotated with these are coupled to the specific database implementation.

```dart
// test_arch/domain_no_orm_arch_test.dart
import 'package:dartunit/dartunit.dart';

void main() {
  // Floor/Room-style @Entity
  annotationMustNotHave(
    annotation: 'Entity',
    folders: ['lib/domain'],
    severity: RuleSeverity.error,
  );

  // Hive @HiveType
  annotationMustNotHave(
    annotation: 'HiveType',
    folders: ['lib/domain'],
    severity: RuleSeverity.error,
  );

  // Isar @Collection
  annotationMustNotHave(
    annotation: 'collection',  // Isar uses lowercase
    folders: ['lib/domain'],
    severity: RuleSeverity.error,
  );

  // Drift @DataClassName
  annotationMustNotHave(
    annotation: 'DataClassName',
    folders: ['lib/domain'],
    severity: RuleSeverity.error,
  );
}
```

This catches:

```dart
// VIOLATION: domain class with ORM annotation
@Entity(tableName: 'users')  // VIOLATION — database schema in domain
class User {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String email;
  final String name;

  User({this.id, required this.email, required this.name});
}
```

The correct approach:

```
lib/domain/entities/user.dart                    → User (pure domain, no ORM)
lib/data/local/entities/user_entity.dart         → UserEntity (has @Entity)
lib/data/local/mappers/user_local_mapper.dart    → Converts between User and UserEntity
```

### Example 3: Production Classes Must Not Have `@visibleForTesting`

`@visibleForTesting` should not appear in production `lib/` code outside of explicitly designated test support files.

```dart
// test_arch/no_visible_for_testing_arch_test.dart
import 'package:dartunit/dartunit.dart';

void main() => annotationMustNotHave(
  annotation: 'visibleForTesting',
  folders: ['lib/services', 'lib/repositories', 'lib/domain', 'lib/blocs'],
  severity: RuleSeverity.error,
);
```

This catches:

```dart
// VIOLATION: production service class with @visibleForTesting
class PaymentService {
  final IPaymentGateway _gateway;

  PaymentService(this._gateway);

  Future<PaymentResult> processPayment(PaymentRequest request) async { ... }

  @visibleForTesting  // VIOLATION — production code shouldn't need this
  Future<void> resetRetryCount() async { ... }
}
```

The existence of `@visibleForTesting` here reveals that `resetRetryCount` is an internal method that tests need to call directly. This usually means either:
- The method should be made truly private and tested indirectly through the public interface.
- The class has too much responsibility and the retry logic should be extracted.

### Example 4: Core Models Must Not Have `@injectable`

Pure data classes — models, entities, value objects — should not be registered with the DI container. They are created with constructors and typically take no injected dependencies. Marking them `@injectable` is at best useless and at worst confusing (the DI container will try to satisfy their constructor dependencies, which are data, not services).

```dart
// test_arch/models_not_injectable_arch_test.dart
import 'package:dartunit/dartunit.dart';

void main() => annotationMustNotHave(
  annotation: 'injectable',
  folders: [
    'lib/domain/entities',
    'lib/domain/value_objects',
    'lib/data/models',
    'lib/data/dtos',
  ],
  severity: RuleSeverity.error,
);
```

This prevents:

```dart
// VIOLATION: data model marked as injectable
@injectable  // VIOLATION — data models are not DI-managed services
class UserProfile {
  final String userId;
  final String displayName;
  final String? avatarUrl;

  const UserProfile({
    required this.userId,
    required this.displayName,
    this.avatarUrl,
  });
}
```

The `@injectable` annotation on a data model like `UserProfile` is almost certainly a mistake — perhaps the developer copied a template from a service class without removing the annotation.

## Combining Both Presets: Complete Annotation Policies

`annotationMustHave` and `annotationMustNotHave` together define a complete annotation policy for a folder. Here is a real-world complete policy for a Clean Architecture Flutter project:

```dart
// test_arch/annotation_policies_arch_test.dart
import 'package:dartunit/dartunit.dart';

void main() {
  // ==================================================
  // DOMAIN ENTITIES
  // Must: @immutable
  // Must not: @JsonSerializable, @Entity, @HiveType, @injectable
  // ==================================================

  annotationMustHave(
    annotation: 'immutable',
    folders: ['lib/domain/entities'],
    severity: RuleSeverity.error,
    exceptions: ['Entity', 'AggregateRoot'], // Abstract base classes
  );

  annotationMustNotHave(
    annotation: 'JsonSerializable',
    folders: ['lib/domain/entities'],
    severity: RuleSeverity.error,
  );

  annotationMustNotHave(
    annotation: 'Entity',
    folders: ['lib/domain/entities'],
    severity: RuleSeverity.error,
  );

  annotationMustNotHave(
    annotation: 'injectable',
    folders: ['lib/domain/entities'],
    severity: RuleSeverity.error,
  );

  // ==================================================
  // BLOC STATES
  // Must: @immutable
  // Must not: @JsonSerializable, @injectable
  // ==================================================

  annotationMustHave(
    annotation: 'immutable',
    folders: ['lib/blocs/states'],
    severity: RuleSeverity.error,
  );

  annotationMustNotHave(
    annotation: 'JsonSerializable',
    folders: ['lib/blocs/states'],
    severity: RuleSeverity.error,
  );

  annotationMustNotHave(
    annotation: 'injectable',
    folders: ['lib/blocs/states'],
    severity: RuleSeverity.error,
  );

  // ==================================================
  // SERVICES (application layer)
  // Must: @injectable (or @lazySingleton)
  // Must not: @Entity, @JsonSerializable, @visibleForTesting
  // ==================================================

  annotationMustHave(
    annotation: 'injectable',
    folders: ['lib/services'],
    severity: RuleSeverity.error,
    exceptions: ['BaseService', 'IService'],
  );

  annotationMustNotHave(
    annotation: 'Entity',
    folders: ['lib/services'],
    severity: RuleSeverity.error,
  );

  annotationMustNotHave(
    annotation: 'visibleForTesting',
    folders: ['lib/services'],
    severity: RuleSeverity.error,
  );
}
```

This single rule file expresses the complete annotation contract for three architectural layers and enforces it automatically in CI.

## Violation Message Format

When a class in a targeted folder carries the forbidden annotation:

```
VIOLATION [error] annotationMustNotHave[@JsonSerializable]
  File: lib/domain/entities/order.dart
  Class: Order
  Forbidden annotation: @JsonSerializable
  Reason: lib/domain/entities must not contain @JsonSerializable.
          JSON serialization is an infrastructure concern.
          Create an OrderDto in lib/data/dtos/ with @JsonSerializable
          and a mapper class to convert between Order and OrderDto.
```

The violation message identifies the file, the class, the forbidden annotation, and — when a descriptive reason is provided — explains what to do instead. Well-written violations are self-documenting: a developer new to the project can fix the issue without additional context.

## When to Use Exceptions

Exceptions should be rare and explicitly justified. Good reasons to add an exception:

1. **The class is temporarily misplaced** and there is a tracked migration task to move it. Add the exception with an inline comment linking to the issue.
2. **The class is a special case that the rule didn't anticipate** and the team has agreed it is genuinely correct. Document the reasoning.
3. **The class is generated code** that you cannot easily modify.

Bad reasons to add an exception:
- "It was already there and it would be too much work to fix." — Fix it, or it will accumulate.
- "We're not sure if this is a real violation." — Investigate and determine whether the architecture is correctly set up.
- "The rule is wrong for this folder." — Adjust the rule's `folders` parameter rather than adding per-class exceptions.

Each exception in the list is a documented gap in your architectural boundary. Minimize them.

## Organizational Pattern: Layer-Specific Rule Files

Organize your boundary rules by layer for clarity and maintainability:

```
test_arch/
  boundaries/
    domain_boundaries.dart       # What domain may and may not have
    application_boundaries.dart  # What application layer may and may not have
    data_boundaries.dart         # What data layer may and may not have
    presentation_boundaries.dart # What UI layer may and may not have
```

Each file becomes a specification document for its layer's architectural contract, readable by humans and enforced by machines.

## Related Presets

- [`annotationMustHave`](/presets/annotation-must-have) — Enforce required annotations (completeness checks)
- [`noExternalPackage`](/presets/no-external-package) — Prevent importing annotation-implying packages in the wrong layers
- [`noPublicFields`](/presets/no-public-fields) — Complement annotation boundaries with structural encapsulation rules
- [`layeredArchitecture`](/presets/layered-architecture) — Enforce import boundaries between project layers
