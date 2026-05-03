---
title: isAbstractClass
description: Enforce that classes are declared abstract. Used to ensure that interface/contract folders contain no concrete implementations.
sidebar:
  order: 9
---

## What it does

`isAbstractClass()` passes when the class is declared with the `abstract` keyword — for example, `abstract class CartRepository` or `abstract interface class CartRepository`.

It does **not** require the class to have all-abstract methods. An abstract class in Dart can have concrete (implemented) methods. The matcher only checks for the presence of the `abstract` keyword on the class declaration.

---

## What problem it solves

In architectures that follow the Dependency Inversion Principle (Clean Architecture, Hexagonal, BLoC with repositories), certain folders are meant to contain only abstract contracts — interfaces that concrete implementations must satisfy.

The problem is that Dart does not enforce this at the language level. Any developer can add a concrete class to a "contracts" folder, and the compiler won't complain. Over time:

1. A concrete class gets added to `lib/domain/repositories/` "just temporarily"
2. Other code imports the concrete class directly (because autocomplete finds it first)
3. The concrete class never gets moved
4. Testing becomes impossible because you can't mock the concrete dependency

`isAbstractClass()` catches this at the moment a concrete class is added to a protected folder, before it becomes entangled in the codebase.

---

## Syntax

```dart
expect(subject, isAbstractClass());
```

---

## Parameters

This matcher takes **no parameters**.

**Passes when:** the class declaration includes the `abstract` keyword.

---

## When to use

Apply `isAbstractClass()` to folders that are meant to contain only contracts and interfaces:

- `lib/domain/repositories/` — repository interfaces
- `lib/domain/usecases/` — use case contracts (if your team defines abstract use cases)
- `lib/domain/services/` — service interfaces
- `lib/domain/contracts/` — any general contract folder

Do not apply it to folders that contain concrete implementations (`lib/data/repositories/`, `lib/bloc/`).

---

## Common use cases

- Domain repository folder must contain only abstract repository interfaces
- Domain service folder must contain only abstract service contracts
- A `contracts/` folder must be 100% abstract — no concrete classes allowed
- Enforce that `Impl` classes are never abstract (use the opposite: filter for `Impl` suffix and expect `isConcreteClass()`)

---

## Examples

### Domain repositories must be abstract

The canonical Clean Architecture rule — the domain layer defines repository contracts, never implementations:

```dart title="test_arch/domain_abstract_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Domain repositories must be declared abstract', (selector) {
    expect(
      selector.classes(inFolder: 'lib/domain/repositories'),
      isAbstractClass(),
    );
  });
}
```

If a developer adds `class CartRepositoryImpl` to `lib/domain/repositories/`:

```
ERROR | Domain repositories must be declared abstract
      | lib/domain/repositories/cart_repository_impl.dart:3
      | Class "CartRepositoryImpl" is not abstract
```

---

### Multiple abstract contract folders

Protect all contract folders at once using a group:

```dart title="test_arch/contracts_abstract_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArchGroup('Domain contract folders must be all-abstract', () {
    testArch('Repository interfaces must be abstract', (selector) {
      expect(selector.classes(inFolder: 'lib/domain/repositories'), isAbstractClass());
    });

    testArch('Use case contracts must be abstract', (selector) {
      expect(selector.classes(inFolder: 'lib/domain/usecases'), isAbstractClass());
    });

    testArch('Service contracts must be abstract', (selector) {
      expect(selector.classes(inFolder: 'lib/domain/services'), isAbstractClass());
    });
  }, severity: RuleSeverity.error);
}
```

---

### Combined with naming convention

Pair abstract enforcement with naming conventions for maximum consistency:

```dart title="test_arch/domain_contracts_full_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArchGroup('Domain repository contracts', () {
    testArch('Repository interfaces must be abstract', (selector) {
      expect(selector.classes(inFolder: 'lib/domain/repositories'), isAbstractClass());
    });

    testArch('Repository interfaces must follow naming convention', (selector) {
      expect(
        selector.classes(inFolder: 'lib/domain/repositories'),
        nameMatchesPattern(r'^[A-Z][a-zA-Z]+Repository$'),
      );
    });

    testArch('Repository interfaces must not import from data layer', (selector) {
      expect(selector.classes(inFolder: 'lib/domain/repositories'), doesNotDependOn('lib/data'));
    });
  });
}
```

---

## Notes

- In Dart 3+, `sealed` classes are implicitly abstract and will **pass** this matcher.
- `mixin` declarations are not classes and are not subject to this check.
- An abstract class can have concrete methods — the matcher only checks the `abstract` keyword, not method bodies.

---

## Related matchers

- [`isConcreteClass`](/predicates/is-concrete-class/) — require concrete (non-abstract) class
- [`implementsInterface`](/predicates/implements-interface/) — require implementing a specific interface
- [`nameEndsWith`](/predicates/name-ends-with/) — combine naming + structural checks
