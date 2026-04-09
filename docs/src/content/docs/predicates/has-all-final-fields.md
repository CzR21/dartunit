---
title: hasAllFinalFields
description: Enforce that all instance fields in a class are declared final or const. The standard way to enforce immutability in domain entities, value objects, and BLoC states.
sidebar:
  order: 24
---

## What it does

`hasAllFinalFields()` passes when **all instance fields** in the class have the `final` or `const` modifier. Static fields are excluded — only instance fields are checked.

A class with no instance fields at all passes vacuously (there are no fields to violate the rule).

---

## What problem it solves

Immutability is one of the most important properties in modern Dart/Flutter architecture:

- **BLoC states** must be immutable. If a state object is mutated after being emitted, the BLoC won't know about the change, and the UI won't rebuild. The entire reactivity model breaks.
- **Domain entities** should be immutable because they represent business facts. A `User` entity with a mutable `email` field can be modified from anywhere — making it impossible to track when and why the email changed.
- **Value objects** must be immutable by definition. A `Money` value object that can change its amount after construction is not a value object — it's a mutable record.

`hasAllFinalFields()` enforces immutability automatically. Any non-final field in a protected class is caught at build time.

---

## Syntax

```dart
expect(subject, hasAllFinalFields());
```

---

## Parameters

This matcher takes **no parameters**.

**Passes when:** all instance fields have the `final` or `const` modifier. `late final` fields also pass.

---

## When to use

Apply `hasAllFinalFields()` to classes that must be immutable by design:

- **BLoC state classes** (`*State`): immutability is required for correct BLoC behavior
- **Domain entities**: business facts shouldn't be mutable
- **Value objects**: immutable by definition
- **Event classes** (`*Event`): events are immutable records of something that happened
- **DTOs** (Data Transfer Objects): should be read-only after construction

---

## Common use cases

- BLoC state classes must have all final fields
- Domain entities must be immutable
- Value objects must have all final fields
- Event classes must be immutable records

---

## Examples

### BLoC states must be immutable

This is the most important use of `hasAllFinalFields()`. Mutable state in BLoC leads to hard-to-reproduce UI bugs:

```dart title="test_arch/state_immutable_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('BLoC state classes must have all final fields', (arch) {
    expect(
      arch.classes(folder: 'lib/bloc', namePattern: r'.*State$'),
      hasAllFinalFields(),
    );
  });
}
```

If a developer writes:

```dart
class CartState {
  List<CartItem> items;  // ← violation: not final
  bool isLoading;        // ← violation: not final

  CartState({required this.items, required this.isLoading});
}
```

DartUnit reports:

```
ERROR | BLoC state classes must have all final fields
      | lib/bloc/cart/cart_state.dart:2
      | Field "items" is not final
ERROR | BLoC state classes must have all final fields
      | lib/bloc/cart/cart_state.dart:3
      | Field "isLoading" is not final
```

---

### Domain entities and value objects

Apply immutability across the entire domain layer:

```dart title="test_arch/domain_immutable_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArchGroup('Domain layer must be immutable', () {
    testArch('Domain entities must have all final fields', (arch) {
      expect(arch.classes(folder: 'lib/domain/entities'), hasAllFinalFields());
    });

    testArch('Value objects must have all final fields', (arch) {
      expect(arch.classes(folder: 'lib/domain/value_objects'), hasAllFinalFields());
    });

    testArch('Event classes must have all final fields', (arch) {
      expect(
        arch.classes(folder: 'lib/bloc', namePattern: r'.*Event$'),
        hasAllFinalFields(),
      );
    });
  }, severity: RuleSeverity.error);
}
```

---

### Combined with field count

Enforce both immutability and size limits:

```dart title="test_arch/entity_quality_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Domain entities must be immutable and focused', (arch) {
    final entities = arch.classes(folder: 'lib/domain/entities');
    expect(entities, hasAllFinalFields());  // immutable
    expect(entities, hasMaxFields(10));     // focused
    expect(entities, hasMinFields(1));      // has substance
  });
}
```

---

## Notes

- `late final` fields are still considered `final` and **pass** this matcher.
- A class with zero instance fields passes vacuously.
- If you use `@immutable` from the `meta` package as an alternative, you can enforce it with [`hasAnnotation('immutable')`](/predicates/annotated-with/).

---

## Related matchers

- [`hasNoPublicFields`](/predicates/has-no-public-fields/) — enforce that all fields are private (encapsulation)
- [`hasMaxFields`](/predicates/max-fields/) — enforce a maximum number of fields
- [`hasMinFields`](/predicates/min-fields/) — enforce a minimum number of fields
- [`hasAnnotation`](/predicates/annotated-with/) — enforce `@immutable` annotation as an alternative
