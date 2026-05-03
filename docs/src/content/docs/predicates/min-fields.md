---
title: hasMinFields
description: Enforce that classes declare at least N instance fields. Useful for catching empty placeholder classes that were never filled in.
sidebar:
  order: 22
---

## What it does

`hasMinFields(min)` passes when the number of **instance fields** in the class is greater than or equal to `min`. Static fields are **not counted** — only instance fields.

---

## What problem it solves

An entity or model class with no fields is almost certainly a placeholder that was created but never completed. This can happen during rapid scaffolding sessions where class structures are created ahead of time and the fields are supposed to be added later — but "later" never comes.

`hasMinFields()` catches these incomplete classes automatically at build time.

A related problem: an entity class that represents a business concept (like a `User` or `Order`) but has no fields is not modeling anything. It's a class that exists on paper but has no substance. Requiring at least one field ensures that entity classes at minimum have an identifier.

---

## Syntax

```dart
expect(subject, hasMinFields(1));
```

---

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `min` | `int` | yes | Minimum required number of instance fields (inclusive). Static fields are not counted. |

---

## When to use

Use `hasMinFields()` to ensure that model and entity classes actually carry state:

- **Domain entities**: must have at least 1 field (at minimum, an `id`)
- **Data models**: must have at least 2 fields (otherwise they're not modeling anything meaningful)
- **Value objects**: must have at least 1 field (a value object with no value is meaningless)
- **BLoC state classes**: must have at least 1 field (the state needs to carry information)

---

## Examples

### Domain entities must have at least one field

An entity with no fields doesn't represent anything. At minimum it should have an `id`:

```dart title="test_arch/entity_min_fields_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Domain entities must have at least 1 field', (selector) {
    expect(
      selector.classes(inFolder: 'lib/domain/entities'),
      hasMinFields(1),
    );
  });
}
```

---

### Data models must be meaningful

A data model with only one field is barely useful. Require at least 2:

```dart title="test_arch/model_min_fields_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Data models must have at least 2 fields', (selector) {
    expect(
      selector.classes(inFolder: 'lib/data/models'),
      hasMinFields(2),
    );
  });
}
```

---

### Enforce a field count range

Combine `hasMinFields` and `hasMaxFields` in the same test with multiple `expect()` calls:

```dart title="test_arch/entity_field_range_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Domain entities must have between 1 and 10 fields', (selector) {
    final entities = selector.classes(inFolder: 'lib/domain/entities');
    expect(entities, hasMinFields(1));    // must carry state
    expect(entities, hasMaxFields(10));   // must not become God Objects
  });
}
```

---

## Notes

- Static fields are **not counted**.
- A class with only a constructor and no fields will fail `hasMinFields(1)` — this is usually the desired behavior.
- Pair with [`hasAllFinalFields`](/predicates/has-all-final-fields/) to ensure that the fields that exist are also immutable.

---

## Related matchers

- [`hasMaxFields`](/predicates/max-fields/) — enforce a maximum number of fields
- [`hasAllFinalFields`](/predicates/has-all-final-fields/) — enforce that all fields are final
- [`hasMinMethods`](/predicates/min-methods/) — enforce a minimum number of methods
