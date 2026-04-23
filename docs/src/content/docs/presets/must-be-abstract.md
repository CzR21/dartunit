---
title: mustBeAbstract
description: Enforce that all classes in specified folders are declared abstract. Essential for ensuring interface/contract folders contain no concrete implementations.
sidebar:
  order: 6
---

`mustBeAbstract` enforces that every class declared inside the specified folders is marked with the `abstract` keyword. This rule is fundamental to any architecture that separates contracts from implementations — Clean Architecture, Ports and Adapters, BLoC with repository interfaces, or any pattern that relies on the Dependency Inversion Principle.

---

## The role of abstraction in architecture

### Dependency inversion: the core idea

The Dependency Inversion Principle (DIP) states:

1. High-level modules should not depend on low-level modules. Both should depend on abstractions.
2. Abstractions should not depend on details. Details should depend on abstractions.

In practice, this means your domain logic — use cases, business rules — should reference abstract contracts, not concrete implementations. The `CartBloc` should depend on `ICartRepository` (an abstract class), not on `CartRepositoryImpl` (the concrete HTTP-backed implementation).

This separation enables the architecture's most valuable properties:

**Testability**: you can write a `FakeCartRepository` that implements `ICartRepository` in memory, then inject it into `CartBloc` during tests. No HTTP calls, no database setup, no environment configuration. The test exercises the real business logic with a controlled data source.

**Swappability**: when requirements change and you need a new storage backend — say, migrating from REST to GraphQL — you write a new implementation of `ICartRepository` and swap it at the injection point. The `CartBloc`, the use cases, and the presentation layer are unchanged.

**Parallel development**: once the interface contract is defined, the team can build the `CartBloc` and `CartRepositoryImpl` in parallel. The bloc developer works against the interface. The repository developer implements the interface. Neither blocks the other.

### Why enforcement matters

The abstract-folder contract is the most commonly violated contract in Flutter projects under time pressure. The violation sequence looks like this:

1. The domain layer defines `abstract class CartRepository` in `lib/domain/repositories/`.
2. A developer under deadline pressure writes a quick implementation in `lib/domain/repositories/cart_repository_concrete.dart` — "just for now, I'll move it later."
3. A use case references the concrete implementation directly (because it's in the same folder and autocomplete finds it first).
4. The concrete implementation is never moved.
5. Six months later, the entire codebase directly depends on the concrete implementation. Mocking is impossible because the concrete class is wired everywhere.

`mustBeAbstract` closes this door completely. Any concrete class that appears in the interface folder is flagged immediately, before the first commit.

### Abstract classes enable multiple implementations

One abstract interface can have multiple concrete implementations co-existing in the codebase:

- `CartRepositoryImpl` — the real implementation, talks to the API
- `InMemoryCartRepository` — used in tests and onboarding demos
- `OfflineCartRepository` — used when the network is unavailable
- `ReadOnlyCartRepository` — used in a guest/preview mode

All of these implement the same `abstract class CartRepository`. The business logic layer never knows which one it is talking to. This flexibility is lost the moment a concrete class leaks into the abstract interface folder.

---

## The difference from Clean Architecture to BLoC architecture

### In Clean Architecture

The domain layer is the innermost circle. It defines repository interfaces, use case contracts, and entity types. All of these are abstract:

- `lib/domain/repositories/` — repository interfaces, all abstract
- `lib/domain/usecases/` — use case base class or interface, all abstract
- `lib/data/repositories/` — concrete implementations of the domain interfaces

The `mustBeAbstract` is applied to the domain layer's interface folders. The data layer's implementation folders are explicitly excluded.

### In BLoC architecture

BLoC projects often have a `lib/repository/` folder that holds repository interfaces and a separate folder (or the same folder with `_impl` suffix) for implementations. The interface folder should be all-abstract. The preset applies to the interface folder only.

### In Ports and Adapters (Hexagonal)

The "ports" are abstract interfaces. The "adapters" are concrete implementations. The port folder is all-abstract by definition. The preset enforces this definition mechanically.

---

## Function signature

```dart
void mustBeAbstract({
  required List<String> folders,
  RuleSeverity severity = RuleSeverity.error,
  List<String> exceptions = const [],
  String projectRoot = '.',
})
```

## Parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `folders` | `List<String>` | required | Folders where all classes must be declared `abstract`. Matched as substrings of file paths. |
| `severity` | `RuleSeverity` | `RuleSeverity.error` | Violation severity. Defaults to `error` because a concrete class in an interface folder is a structural violation, not a style issue. |
| `exceptions` | `List<String>` | `const []` | Exact class names exempt from the abstract requirement. |

---

## Examples

### Example 1 — Clean Architecture: domain repositories must be abstract

The canonical Clean Architecture use case: all classes in the domain repository folder define contracts that the data layer implements. No concrete class should ever appear here.

```dart title="test_arch/domain_abstract_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() => mustBeAbstract(
    folders: ['lib/domain/repositories'],
    severity: RuleSeverity.error,
  ),
);
```

This catches:

```dart
// lib/domain/repositories/cart_repository.dart

abstract class CartRepository {        // valid: abstract keyword present
  Future<List<CartItem>> getItems();
  Future<void> addItem(CartItem item);
}

class CartRepositoryImpl {             // violation: concrete class in domain/repositories
  // ...
}
```

The violation on `CartRepositoryImpl` is reported before any CI pipeline passes, ensuring the concrete class is moved to `lib/data/repositories/` where it belongs.

### Example 2 — Use case contracts: abstract use cases

Some teams define use case contracts in the domain layer with an abstract base class or interface, then place concrete use case implementations in the data or application layer. This pattern is common when use cases need to be mockable in widget tests:

```dart title="test_arch/usecase_abstract_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() => mustBeAbstract(
    folders: ['lib/domain/usecases'],
    severity: RuleSeverity.error,
    exceptions: [
      'UseCaseBase',      // the shared abstract base all use cases extend
    ],
  ),
);
```

With this rule, the domain use case folder contains only contracts:

```dart
// lib/domain/usecases/get_cart_usecase.dart
abstract class GetCartUseCase {           // valid
  Future<Cart> call(String userId);
}

// lib/domain/usecases/add_to_cart_usecase.dart
abstract class AddToCartUseCase {         // valid
  Future<void> call(String userId, CartItem item);
}
```

And implementations live elsewhere:

```dart
// lib/data/usecases/get_cart_usecase_impl.dart
class GetCartUseCaseImpl implements GetCartUseCase {  // valid: in data layer
  final CartRepository _repository;
  GetCartUseCaseImpl(this._repository);

  @override
  Future<Cart> call(String userId) => _repository.getCart(userId);
}
```

### Example 3 — Data sources: abstract data source interfaces

In Clean Architecture with explicit data source abstraction, the domain or data layer defines abstract data source interfaces that multiple implementations satisfy:

```dart title="test_arch/datasource_abstract_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() => mustBeAbstract(
    folders: ['lib/data/datasources/interfaces'],
    severity: RuleSeverity.error,
  ),
);
```

This enforces the project structure:

```
lib/
  data/
    datasources/
      interfaces/          ← abstract classes only (enforced by this rule)
        cart_remote_datasource.dart
        cart_local_datasource.dart
      remote/              ← concrete implementations
        cart_remote_datasource_impl.dart
      local/               ← concrete implementations
        cart_local_datasource_impl.dart
```

### Example 4 — Multiple abstract folders in one rule file

A complete architecture typically has several folders that must be all-abstract. Rather than one rule file per folder, combine them:

```dart title="test_arch/abstract_contracts_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) {
  // All interface/contract folders in the domain layer must be all-abstract
  mustBeAbstract(
      folders: [
        'lib/domain/repositories',
        'lib/domain/usecases',
        'lib/domain/services',
        'lib/domain/datasources',
      ],
      severity: RuleSeverity.error,
      exceptions: [
        'DomainService',      // marker base class, concrete by design
        'ValueObject',        // base value object, concrete
        'Entity',             // base entity, concrete
      ],
    ),
  );
}
```

This single rule file enforces the abstract constraint across the entire domain layer with one `mustBeAbstract` call. All violations in any of the four folders are reported under the same rule.

---

## The `exceptions` parameter

Not every class in an interface folder is itself an interface. Common legitimate exceptions:

### Value objects and entities

In some Clean Architecture implementations, the domain folder contains both abstract repository interfaces and concrete value objects or entities. A `Money` value object or a `UserId` entity lives in `lib/domain/` but is concrete — it has actual state and behavior.

```dart title="test_arch/domain_abstract_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() => mustBeAbstract(
    folders: ['lib/domain/repositories'],
    severity: RuleSeverity.error,
    exceptions: [
      'RepositoryException',   // concrete exception class for repository errors
    ],
  ),
);
```

### Shared base classes

An `abstract class BaseRepository` might itself be in the repositories folder as a shared base. Strictly speaking, it is abstract — it has the `abstract` keyword — so it will not trigger a violation. But if a team uses a `class RepositoryMixin with SomeMixin` that does not need the `abstract` keyword, it can be exempted.

### Exception classes

Error and exception classes associated with a layer often live near the interfaces they relate to. A `RepositoryException extends Exception` is concrete but logically belongs with the repository interfaces. Add it to `exceptions`.

---

## What the violation report looks like

When a concrete class is found in a folder governed by `mustBeAbstract`, DartUnit reports:

```
ERROR | All classes in lib/domain/repositories must be abstract
      | lib/domain/repositories/cart_repository_impl.dart:3
      | Class "CartRepositoryImpl" is not abstract

ERROR | All classes in lib/domain/repositories must be abstract
      | lib/domain/repositories/cart_repository_impl.dart:45
      | Class "CartRepositoryHelper" is not abstract
```

Each violation includes:
- The severity level
- The rule description, including the folder and the requirement
- The file path and line number where the non-abstract class is declared
- The class name

Multiple violations in the same file are reported individually, so every concrete class in a flagged folder is visible in a single run.

---

## Pairing with naming rules

`mustBeAbstract` becomes more powerful when combined with naming rules. The combination ensures that contract folders contain only abstract classes AND that those classes follow the expected naming convention:

```dart title="test_arch/domain_contracts_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) {
  // All domain repository classes must be abstract
  mustBeAbstract(
      folders: ['lib/domain/repositories'],
      severity: RuleSeverity.error,
    ),
  );

  // All domain repository classes must start with I (interface convention)
  namingClassConvention(
    folders: ['lib/domain/repositories'],
    prefix: 'I',
    severity: RuleSeverity.error,
  );
}
```

With both rules active, a class in `lib/domain/repositories/` must be both abstract and named with an `I` prefix. A class that is abstract but named `CartRepository` fails the naming rule. A class named `ICartRepository` but not abstract fails the abstract rule. Both rules must pass for the folder to be compliant.

---

## Common mistakes

### Applying to the wrong folder

The most common mistake is applying this rule to the implementation folder instead of the interface folder. Double-check that you are pointing at `lib/domain/repositories` (interfaces) rather than `lib/data/repositories` (implementations).

### Forgetting sealed classes

In Dart 3+, `sealed` classes are implicitly abstract. A sealed class in an interface folder will not trigger a violation because it cannot be instantiated directly.

### Mixins are not classes

Dart `mixin` declarations are not classes. If your interface folder contains `mixin CartRepositoryMixin`, it is not subject to the `abstract` requirement. Only `class` declarations are checked.

### Abstract classes with concrete methods

An `abstract class` can have concrete (implemented) methods in Dart. The presence of concrete methods does not make a class non-abstract. The rule only checks for the `abstract` keyword — it does not require the class to have all-abstract methods.

---

## Related presets

- [`namingClassConvention`](/presets/naming-class-convention/) — ensure interface classes also follow the correct suffix or prefix convention
- [`mustBeImmutable`](/presets/must-be-immutable/) — a complementary structural constraint for model and state folders
