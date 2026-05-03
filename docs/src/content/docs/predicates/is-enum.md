---
title: isEnumType
description: Enforce that declarations in a folder are enums. Useful to keep enum-only folders clean and prevent accidental class or mixin declarations.
sidebar:
  order: 11
---

## What it does

`isEnumType()` passes when the declaration uses the `enum` keyword. It covers both basic enums and Dart's enhanced enums (enums with fields, constructors, and methods, introduced in Dart 2.17).

---

## What problem it solves

Projects often have a dedicated folder for enumerations — `lib/domain/enums/`, `lib/shared/types/`, or similar. Over time, developers may place non-enum declarations in those folders — a regular class, a typedef, or a helper function file — which breaks the organizational intent of the folder.

`isEnumType()` enforces that the folder stays clean: every declaration in it must be an actual enum.

A subtler use is validating naming conventions: if your team names certain classes with an `*Status` or `*Type` suffix, those should almost always be enums (not regular classes). `isEnumType()` can catch a case where a developer wrote `class CartStatus` instead of `enum CartStatus`.

---

## Syntax

```dart
expect(subject, isEnumType());
```

---

## Parameters

This matcher takes **no parameters**.

**Passes when:** the declaration uses the `enum` keyword.

---

## When to use

Use `isEnumType()` in two situations:

1. **Folder purity**: you have a dedicated enum folder and want to ensure only enums live there.
2. **Name-based convention**: classes ending with `Status`, `Type`, `Kind`, or `Mode` should be enums — enforce that the naming convention is backed by the actual declaration.

---

## Common use cases

- `lib/domain/enums/` folder must contain only enum declarations
- All declarations whose name ends with `Status` must be enums
- All declarations whose name ends with `Type` must be enums
- Feature state folders with `Mode` or `Kind` suffix must be enums

---

## Examples

### Enum folder must only contain enums

Ensure that nothing other than enums ends up in your enum folder:

```dart title="test_arch/enum_folder_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('The enums folder must contain only enum declarations', (selector) {
    expect(
      selector.classes(inFolder: 'lib/domain/enums'),
      isEnumType(),
    );
  });
}
```

---

### Status classes must be enums

If your team uses the `*Status` suffix to name status types, enforce that they're actual enums — not regular classes that pretend to be:

```dart title="test_arch/status_enum_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Declarations ending with Status must be enums', (selector) {
    expect(
      selector.classes(inFolder: 'lib', matchingPattern: r'.*Status$'),
      isEnumType(),
    );
  });
}
```

This catches a case like:

```dart
// lib/domain/entities/order_status.dart
class OrderStatus {             // ← violation: should be an enum
  static const String pending = 'pending';
  static const String shipped = 'shipped';
}
```

Which should be:

```dart
enum OrderStatus { pending, shipped, delivered }
```

---

### Combined enum type and naming checks

Pair enum type enforcement with naming conventions for the enum folder:

```dart title="test_arch/enum_full_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArchGroup('Enum folder rules', () {
    testArch('Enum folder must contain only enums', (selector) {
      expect(selector.classes(inFolder: 'lib/shared/enums'), isEnumType());
    });

    testArch('Enum declarations must use PascalCase naming', (selector) {
      expect(
        selector.classes(inFolder: 'lib/shared/enums'),
        nameMatchesPattern(r'^[A-Z][a-zA-Z]+$'),
      );
    });
  });
}
```

---

## Notes

- Dart enhanced enums (enums with methods and fields, Dart 2.17+) also pass `isEnumType()`.
- Combine with `nameEndsWith` if you want to enforce that all enums in a folder use a naming convention.

---

## Related matchers

- [`isConcreteClass`](/predicates/is-concrete-class/) — require concrete class declaration
- [`isMixinType`](/predicates/is-mixin/) — require mixin declaration
- [`isExtensionType`](/predicates/is-extension/) — require extension declaration
- [`nameEndsWith`](/predicates/name-ends-with/) — enforce suffix alongside type check
