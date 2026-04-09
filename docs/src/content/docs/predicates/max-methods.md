---
title: hasMaxMethods
description: Enforce that classes declare at most N methods. A high method count is a signal of a God Class — a class doing too many things at once.
sidebar:
  order: 19
---

## What it does

`hasMaxMethods(max)` passes when the number of **declared methods** in the class is less than or equal to `max`. Constructors (including named constructors and factory constructors) are **not counted** — only regular methods.

---

## What problem it solves

A class with too many methods is a **God Class** — it's doing too many things, knows too much, and is impossible to test in isolation. God Classes are one of the most common structural problems in growing codebases.

The problem compounds over time: a class starts with 5 methods, gets one more with each feature request, and before long it has 40+ methods and has become the center of the entire application. Refactoring it is terrifying because every other class depends on it.

`hasMaxMethods()` sets a hard limit that forces a structural conversation. When a class hits the limit, the developer must either:
- Split the class into two smaller, more focused classes
- Refactor the existing methods into helper classes
- Request a limit increase with a justification

Either outcome is better than silently growing a God Class.

---

## Syntax

```dart
expect(subject, hasMaxMethods(10));
```

---

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `max` | `int` | yes | Maximum allowed number of methods (inclusive). Constructors are not counted. |

---

## When to use

Use `hasMaxMethods()` to enforce the **Single Responsibility Principle** at the code level. Set different limits for different types of classes based on their expected complexity:

- **BLoC classes**: 10–15 methods (event handlers + private helpers)
- **Use cases**: 1–3 methods (they should do one thing)
- **Repository implementations**: 5–10 methods (CRUD + specialized queries)
- **Service classes**: 10–20 methods
- **General classes**: 20 methods as a broad ceiling

Tighter limits for simpler types (use cases, value objects) encourage better decomposition.

---

## Common use cases

- BLoC classes must have at most 10 methods (keep event handlers focused)
- Use case classes must have at most 3 methods (ideally just `call()` + helpers)
- General classes in `lib/` must have at most 20 methods (broad God Class detection)
- Value objects must have at most 5 methods (simple, focused types)

---

## Examples

### Limit method count in BLoC classes

BLoC classes that grow beyond 10 methods are usually handling too many events or embedding business logic that should be in use cases:

```dart title="test_arch/bloc_size_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('BLoC classes must have at most 10 methods', (arch) {
    expect(
      arch.classes(folder: 'lib/bloc', namePattern: r'.*Bloc$'),
      hasMaxMethods(10),
    );
  });
}
```

---

### Broad God Class detection

Apply a generous limit across the entire codebase to catch the most extreme cases:

```dart title="test_arch/god_class_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Classes must not exceed 20 methods (God Class detection)', (arch) {
    expect(
      arch.classes(folder: 'lib'),
      hasMaxMethods(20),
    );
  });
}
```

---

### Tight limits for simple types

Use cases should do exactly one thing. Value objects should be minimal. Enforce tight limits:

```dart title="test_arch/simple_types_size_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArchGroup('Simple types must stay small', () {
    testArch('Use cases must have at most 3 methods', (arch) {
      expect(
        arch.classes(folder: 'lib/domain/usecases'),
        hasMaxMethods(3),
      );
    });

    testArch('Value objects must have at most 5 methods', (arch) {
      expect(
        arch.classes(folder: 'lib/domain/value_objects'),
        hasMaxMethods(5),
      );
    });
  }, severity: RuleSeverity.warning);
}
```

---

## Notes

- Constructors (including named and factory) are **not counted**.
- Getters and setters may or may not be counted depending on your DartUnit version — check if getter-heavy classes are unexpectedly failing this rule.
- Combine with [`hasMinMethods`](/predicates/min-methods/) inside the same `testArch` with multiple `expect()` calls to enforce both a minimum and maximum.

---

## Related matchers

- [`hasMinMethods`](/predicates/min-methods/) — enforce a minimum number of methods
- [`hasMaxFields`](/predicates/max-fields/) — enforce a maximum number of fields
- [`hasMaxImports`](/predicates/max-imports/) — enforce a maximum number of imports
- [`hasMethod`](/predicates/has-method/) — check for a specific method by name
