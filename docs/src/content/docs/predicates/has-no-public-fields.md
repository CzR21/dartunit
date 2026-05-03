---
title: hasNoPublicFields
description: Enforce that all instance fields are private — every field name starts with underscore. The standard encapsulation rule for services, BLoC classes, and repositories.
sidebar:
  order: 25
---

## What it does

`hasNoPublicFields()` passes when there are **no instance fields whose names do not start with `_`**. In other words, every field must be private. Static fields are excluded from the check.

A class with no instance fields at all passes vacuously.

---

## What problem it solves

Public fields are one of the most common encapsulation violations in Dart. When a class exposes its internal state as public fields, any code anywhere in the application can read — and more dangerously, **write** — that state directly:

```dart
class CartBloc {
  List<CartItem> items = [];   // ← anyone can do cartBloc.items.clear()
  bool isLoading = false;      // ← anyone can set cartBloc.isLoading = true
}
```

This breaks encapsulation: the class loses control over its own state. Invariants can be violated from outside, state changes don't trigger events, and the class can't protect itself against misuse.

The correct pattern is to expose state through methods or getters, keeping the underlying fields private:

```dart
class CartBloc {
  List<CartItem> _items = [];   // ← private
  bool _isLoading = false;      // ← private

  List<CartItem> get items => List.unmodifiable(_items);  // ← controlled access
}
```

`hasNoPublicFields()` enforces this automatically.

---

## Syntax

```dart
expect(subject, hasNoPublicFields());
```

---

## Parameters

This matcher takes **no parameters**.

**Passes when:** no instance field name starts without `_`. Static fields are excluded.

---

## When to use

Apply `hasNoPublicFields()` to classes that manage internal state and should control access to it:

- **BLoC classes**: state should only be exposed through streams/state, not direct field access
- **Service classes**: internal data (caches, connections) should not be accessible from outside
- **Repository implementations**: internal data sources, caches, and HTTP clients should be private
- **Any class that manages state**: if a class has mutable state, it should be encapsulated

**Do not apply** to classes where public fields are intentional:
- **Value objects** and **DTOs** often have public `final` fields — that's their purpose (read-only data containers)
- **Data models** with `final` public fields are fine

---

## Common use cases

- BLoC classes must not expose public mutable fields
- Service classes must encapsulate their internal state
- Repository implementations must keep data sources private
- Any class managing a cache or connection must not expose it directly

---

## Examples

### BLoC classes must encapsulate state

BLoC classes should only expose state through the BLoC stream, not through direct field access:

```dart title="test_arch/bloc_encapsulation_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('BLoC classes must not expose public fields', (selector) {
    expect(
      selector.classes(inFolder: 'lib/bloc', matchingPattern: r'.*Bloc$'),
      hasNoPublicFields(),
    );
  });
}
```

---

### Service encapsulation

Services often hold internal resources (HTTP clients, database connections, caches) that should not be accessible from outside:

```dart title="test_arch/service_encapsulation_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Service classes must not expose public fields', (selector) {
    expect(
      selector.classes(inFolder: 'lib/services'),
      hasNoPublicFields(),
    );
  });
}
```

---

### Comprehensive encapsulation rules

Apply encapsulation requirements across all layers that manage state:

```dart title="test_arch/encapsulation_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArchGroup('Encapsulation rules', () {
    testArch('BLoC classes must not have public fields', (selector) {
      expect(selector.classes(inFolder: 'lib/bloc'), hasNoPublicFields());
    });

    testArch('Services must not have public fields', (selector) {
      expect(selector.classes(inFolder: 'lib/services'), hasNoPublicFields());
    });

    testArch('Repository implementations must not have public fields', (selector) {
      expect(
        selector.classes(inFolder: 'lib/data/repositories', matchingPattern: r'.*Impl$'),
        hasNoPublicFields(),
      );
    });
  }, severity: RuleSeverity.warning);
}
```

---

## Notes

- Public `final` fields (used in value objects or DTOs) also fail this check. Do not apply this rule to value objects or DTO classes where public read-only access is intentional.
- This rule checks field **names** — a field is considered public if its name does not start with `_`.
- Static fields are excluded from the check.

---

## Related matchers

- [`hasAllFinalFields`](/predicates/has-all-final-fields/) — enforce immutability (all fields must be final)
- [`hasNoPublicMethods`](/predicates/has-no-public-methods/) — enforce that all methods are private
- [`hasMaxFields`](/predicates/max-fields/) — enforce a maximum number of fields
