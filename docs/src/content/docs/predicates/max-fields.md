---
title: hasMaxFields
description: Enforce that classes declare at most N instance fields. High field count signals God Objects or poor data modeling — classes that hold too much state.
sidebar:
  order: 21
---

## What it does

`hasMaxFields(max)` passes when the number of **instance fields** in the class is less than or equal to `max`. Static fields and class-level constants (`static const`) are **not counted** — only instance fields.

---

## What problem it solves

A class with too many fields is carrying too much state. This is the **God Object** anti-pattern: a class that stores everything, knows everything, and changes for unrelated reasons.

Symptoms of too many fields:
- The class is difficult to construct (its constructor has 15+ parameters)
- Testing is painful because you need to initialize many unrelated fields for each test case
- Adding a field to the class affects every piece of code that constructs it
- The class represents more than one logical concept (e.g., an entity with both user data AND session data)

`hasMaxFields()` sets a size limit that forces better data modeling. When you hit the limit, the natural response is to split the class — which usually reveals that you were mixing two separate concepts.

---

## Syntax

```dart
expect(subject, hasMaxFields(10));
```

---

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `max` | `int` | yes | Maximum allowed number of instance fields (inclusive). Static fields are not counted. |

---

## When to use

Different class types warrant different limits:

| Class type | Suggested limit |
|-----------|----------------|
| Value objects | 3–5 fields (focused, single concept) |
| Domain entities | 5–10 fields (core identity + attributes) |
| Data models (DTOs) | 10–15 fields (may mirror external API structure) |
| BLoC state classes | 5–8 fields (observable state properties) |
| General classes | 10–15 as a broad ceiling |

---

## Common use cases

- Value objects should be small — at most 3–5 fields
- Domain entities should not grow beyond 10 fields (split into sub-entities)
- BLoC state classes must be minimal — excessive state fields suggest missing intermediate states
- Data models (DTOs) may be larger but should still have a ceiling

---

## Examples

### Value objects must stay small

Value objects represent a single concept like `Money`, `Address`, or `DateRange`. They should be small and focused:

```dart title="test_arch/value_object_fields_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Value objects must have at most 5 fields', (selector) {
    expect(
      selector.classes(inFolder: 'lib/domain/value_objects'),
      hasMaxFields(5),
    );
  });
}
```

---

### Domain entities must not become God Objects

Entities can have more fields, but a limit prevents them from growing indefinitely:

```dart title="test_arch/entity_fields_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Domain entities must not declare more than 10 fields', (selector) {
    expect(
      selector.classes(inFolder: 'lib/domain/entities'),
      hasMaxFields(10),
    );
  });
}
```

---

### Combine field count with immutability

Use both `hasMaxFields` and `hasAllFinalFields` together to enforce that domain entities are both small and immutable:

```dart title="test_arch/entity_quality_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArchGroup('Domain entity quality rules', () {
    testArch('Domain entities must be immutable', (selector) {
      expect(selector.classes(inFolder: 'lib/domain/entities'), hasAllFinalFields());
    });

    testArch('Domain entities must not have more than 10 fields', (selector) {
      expect(selector.classes(inFolder: 'lib/domain/entities'), hasMaxFields(10));
    });
  });
}
```

---

## Notes

- Only **instance fields** are counted. Static fields (`static final`, `static const`) are excluded.
- `late final` fields count as instance fields.
- Combine with [`hasMinFields`](/predicates/min-fields/) in the same `testArch` to enforce a range.

---

## Related matchers

- [`hasMinFields`](/predicates/min-fields/) — enforce a minimum number of fields
- [`hasAllFinalFields`](/predicates/has-all-final-fields/) — enforce that all fields are final (immutability)
- [`hasMaxMethods`](/predicates/max-methods/) — enforce a maximum number of methods
- [`hasNoPublicFields`](/predicates/has-no-public-fields/) — enforce that all fields are private
