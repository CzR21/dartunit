---
title: isExtensionType
description: Enforce that declarations in a folder are extensions. Covers unnamed extensions, named extensions, and Dart 3 extension types.
sidebar:
  order: 13
---

## What it does

`isExtensionType()` passes when the declaration uses the `extension` keyword. This covers:

- **Unnamed extensions**: `extension on String { ... }`
- **Named extensions**: `extension StringExtension on String { ... }`
- **Dart 3 extension types**: `extension type UserId(int _) { ... }`

---

## What problem it solves

Many projects have a dedicated folder for extension methods (`lib/core/extensions/`, `lib/shared/extensions/`). These folders should contain only `extension` declarations. Without enforcement, other types of declarations may accidentally end up there — breaking the organizational intent.

Additionally, declarations whose names end with `Extension` should be actual extensions, not regular classes that just happen to have that suffix in their name.

---

## Syntax

```dart
expect(subject, isExtensionType());
```

---

## Parameters

This matcher takes **no parameters**.

**Passes when:** the declaration uses the `extension` keyword.

---

## When to use

Use `isExtensionType()` in two situations:

1. **Folder purity**: you have a dedicated extensions folder and want to ensure only extension declarations live there.
2. **Name-based convention**: declarations whose name ends with `Extension` should be actual extensions.

---

## Common use cases

- `lib/core/extensions/` must contain only extension declarations
- `lib/shared/extensions/` must contain only extensions
- Declarations ending with `Extension` must use the `extension` keyword

---

## Examples

### Extensions folder must only contain extensions

Enforce that your extension folder stays clean and organized:

```dart title="test_arch/extension_folder_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('The extensions folder must contain only extension declarations', (selector) {
    expect(
      selector.classes(inFolder: 'lib/core/extensions'),
      isExtensionType(),
    );
  });
}
```

---

### Names ending with Extension must be extensions

Ensure naming-declaration consistency:

```dart title="test_arch/extension_naming_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Declarations ending with Extension must use the extension keyword', (selector) {
    expect(
      selector.classes(inFolder: 'lib', matchingPattern: r'.*Extension$'),
      isExtensionType(),
    );
  });
}
```

---

### Extension folder rules combined

A complete validation for the extensions folder:

```dart title="test_arch/extension_full_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArchGroup('Extension folder rules', () {
    testArch('Extensions folder must contain only extensions', (selector) {
      expect(selector.classes(inFolder: 'lib/core/extensions'), isExtensionType());
    });

    testArch('Extensions must not depend on domain-specific classes', (selector) {
      expect(
        selector.classes(inFolder: 'lib/core/extensions'),
        doesNotDependOn('lib/domain'),
      );
    });

    testArch('Extensions must not depend on UI code', (selector) {
      expect(
        selector.classes(inFolder: 'lib/core/extensions'),
        doesNotDependOn('lib/presentation'),
      );
    });
  });
}
```

---

## Notes

- Both unnamed and named extensions are matched. Dart 3 extension types (`extension type MyId(int _)`) are also matched.
- If your team uses extension types as value types (e.g., `extension type UserId(int _)`), you can combine `isExtensionType()` with naming conventions.

---

## Related matchers

- [`isMixinType`](/predicates/is-mixin/) — require mixin declaration
- [`isEnumType`](/predicates/is-enum/) — require enum declaration
- [`isConcreteClass`](/predicates/is-concrete-class/) — require concrete class
- [`nameEndsWith`](/predicates/name-ends-with/) — enforce suffix alongside type check
