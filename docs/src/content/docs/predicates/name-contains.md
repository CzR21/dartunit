---
title: nameContains
description: Enforce that class names contain a specific keyword anywhere in the name. Useful for feature-scoped naming conventions.
sidebar:
  order: 7
---

## What it does

`nameContains(substring)` passes when the class name **contains the given string at any position** — not just at the start or end. The comparison is case-sensitive.

---

## What problem it solves

Some naming conventions are about a keyword appearing anywhere in the name, not just as a prefix or suffix. In feature-based architectures, for example, all classes related to the cart feature should reference "Cart" somewhere in their name — it might be `CartBloc`, `CartRepository`, `GetCartUseCase`, or `AddToCartEvent`.

`nameContains` enforces these keyword-based conventions without restricting where the keyword appears.

---

## Syntax

```dart
expect(subject, nameContains('Keyword'));
```

---

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `substring` | `String` | yes | The string that must appear somewhere in the class name. Case-sensitive. Position in the name is not restricted. |

---

## When to use

Use `nameContains` when a keyword should appear anywhere in the name, not necessarily as a fixed prefix or suffix. Common cases:

- **Feature-scoped naming**: all classes in a feature folder must reference the feature name somewhere in their name (e.g., all cart classes contain `Cart`)
- **Keyword enforcement**: mapper classes must contain `Mapper`, transformer classes must contain `Transformer`
- **Banning test vocabulary in production**: production classes must not contain `Mock`, `Fake`, or `Test` anywhere in their name

---

## Common use cases

- All classes in `lib/features/cart` must contain `Cart` in their name
- Mapper classes in `lib/data/mappers` must contain `Mapper`
- Production classes must not contain `Mock` or `Fake` (to prevent test doubles from leaking)

---

## Examples

### Feature-scoped naming

In feature-based architectures, all classes within a feature folder should reference the feature name. This makes code navigation much easier — you can search for `Cart` and find all cart-related classes:

```dart title="test_arch/cart_naming_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Cart feature classes must reference Cart in their name', (arch) {
    expect(
      arch.classes(folder: 'lib/features/cart'),
      nameContains('Cart'),
    );
  });
}
```

This ensures that a class named `CheckoutHelper` inside the cart feature fails — it should be named `CartCheckoutHelper` or moved to a shared folder.

---

### Mapper naming convention

Enforce that all classes in the mapper folder actually have `Mapper` in their name (they could be `CartMapper`, `UserMapper`, `ProductToCartMapper`, etc.):

```dart title="test_arch/mapper_naming_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Mapper classes must contain Mapper in their name', (arch) {
    expect(
      arch.classes(folder: 'lib/data/mappers'),
      nameContains('Mapper'),
    );
  });
}
```

---

### Ban test vocabulary in production code

Ensure that no class with `Mock` or `Fake` in its name ends up in `lib/`. These should only exist in test files:

```dart title="test_arch/no_test_classes_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArchGroup('No test doubles in production code', () {
    testArch('Production classes must not contain Mock', (arch) {
      expect(
        arch.classes(folder: 'lib'),
        nameMatchesPattern(r'^(?!.*Mock).*$'),
      );
    });

    testArch('Production classes must not contain Fake', (arch) {
      expect(
        arch.classes(folder: 'lib'),
        nameMatchesPattern(r'^(?!.*Fake).*$'),
      );
    });
  }, severity: RuleSeverity.error);
}
```

---

## Notes

- The comparison is **case-sensitive**: `nameContains('Cart')` will not match `cart` or `CART`.
- For case-insensitive matching, use [`nameMatchesPattern`](/predicates/name-matches-pattern/) with the `(?i)` flag: `nameMatchesPattern(r'(?i)cart')`.
- To enforce that a keyword appears at a specific position (start or end), use [`nameStartsWith`](/predicates/name-starts-with/) or [`nameEndsWith`](/predicates/name-ends-with/) instead.

---

## Related matchers

- [`nameStartsWith`](/predicates/name-starts-with/) — enforce a prefix at the beginning
- [`nameEndsWith`](/predicates/name-ends-with/) — enforce a suffix at the end
- [`nameMatchesPattern`](/predicates/name-matches-pattern/) — full regex for complex patterns
