---
title: hasMinMethods
description: Enforce that classes declare at least N methods. Useful for catching empty shell classes or ensuring implementations fulfill their expected interface.
sidebar:
  order: 20
---

## What it does

`hasMinMethods(min)` passes when the number of **declared methods** in the class is greater than or equal to `min`. Constructors are **not counted** — only regular methods.

---

## What problem it solves

Empty or near-empty classes are often a sign of incomplete implementation — a placeholder class was created but never filled in. This happens when:

- A developer creates a use case class but only adds the class declaration without implementing the method
- A repository implementation is scaffolded but the actual data access methods are missing
- A class was stubbed during an early sprint and the real implementation was never added

`hasMinMethods()` catches these incomplete classes automatically. A use case class with zero methods isn't doing anything. A repository implementation with one method is likely missing CRUD operations.

---

## Syntax

```dart
expect(subject, hasMinMethods(1));
```

---

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `min` | `int` | yes | Minimum required number of methods (inclusive). Constructors are not counted. |

---

## When to use

Use `hasMinMethods()` to catch incomplete implementations:

- **Use cases**: must declare at least 1 method (the `call()` method)
- **Repository implementations**: must declare at least 3 methods (basic CRUD)
- **Services**: must declare at least 1 method (they should have a purpose)
- **Any implementation class**: must declare at least 1 method (a class with no methods is a shell)

Pair with [`hasMaxMethods`](/predicates/max-methods/) to enforce a valid range.

---

## Common use cases

- Use case classes must have at least 1 method (`call()`)
- Repository implementations must have at least 3 methods (CRUD minimum)
- Service classes must have at least 1 public method
- Any class in `lib/` must have at least 1 method (detect empty shells)

---

## Examples

### Use cases must have at least one method

A use case class with no methods is a stub that was never implemented:

```dart title="test_arch/usecase_methods_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Use case classes must have at least 1 method', (selector) {
    expect(
      selector.classes(inFolder: 'lib/domain/usecases'),
      hasMinMethods(1),
    );
  });
}
```

---

### Repository implementations must have at least 3 methods

A repository implementation covering the minimum CRUD operations (create, read, delete or similar) should have at least 3 methods:

```dart title="test_arch/repo_min_methods_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Repository implementations must have at least 3 methods', (selector) {
    expect(
      selector.classes(inFolder: 'lib/data/repositories', matchingPattern: r'.*Impl$'),
      hasMinMethods(3),
    );
  });
}
```

---

### Enforce a method count range with min and max

Combine `hasMinMethods` and `hasMaxMethods` in the same test using multiple `expect()` calls:

```dart title="test_arch/service_method_range_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Service classes must have between 1 and 15 methods', (selector) {
    final services = selector.classes(inFolder: 'lib/services');
    expect(services, hasMinMethods(1));   // must have a purpose
    expect(services, hasMaxMethods(15));  // must not be a God Class
  });
}
```

---

## Notes

- Constructors are **not counted**.
- A class with zero fields and zero methods is technically a valid Dart class, but it's almost certainly a mistake.
- Static methods count toward the total — if your classes use only static methods, verify whether DartUnit counts them.

---

## Related matchers

- [`hasMaxMethods`](/predicates/max-methods/) — enforce a maximum number of methods
- [`hasMethod`](/predicates/has-method/) — check for a specific method by name
- [`hasMinFields`](/predicates/min-fields/) — enforce a minimum number of fields
