---
title: isMixinType
description: Enforce that declarations in a folder are mixins. Useful to keep mixin-only folders clean and validate that Mixin-suffixed names are actual mixins.
sidebar:
  order: 12
---

## What it does

`isMixinType()` passes when the declaration uses the `mixin` keyword — for example, `mixin LoggerMixin` or `mixin class SerializableMixin`.

---

## What problem it solves

Mixins in Dart are a powerful mechanism for sharing behavior across unrelated classes. Projects often have a dedicated folder (`lib/core/mixins/`, `lib/shared/mixins/`) specifically for mixin declarations.

Without enforcement, a developer might accidentally place a regular class in the mixin folder, or name a class `SomethingMixin` without actually making it a mixin. The `isMixinType()` matcher catches both problems: it ensures that the mixin folder contains only mixin declarations, and that names ending with `Mixin` are backed by actual `mixin` declarations.

---

## Syntax

```dart
expect(subject, isMixinType());
```

---

## Parameters

This matcher takes **no parameters**.

**Passes when:** the declaration uses the `mixin` keyword.

---

## When to use

Use `isMixinType()` in two situations:

1. **Folder purity**: you have a dedicated mixin folder and want to ensure only mixins live there.
2. **Name-based convention**: declarations whose name ends with `Mixin` should be actual mixins.

---

## Common use cases

- `lib/core/mixins/` folder must contain only mixin declarations
- `lib/shared/behaviors/` folder must contain only mixins
- All declarations ending with `Mixin` must actually use the `mixin` keyword

---

## Examples

### Mixin folder must only contain mixins

Ensure your dedicated mixin folder stays clean:

```dart title="test_arch/mixin_folder_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('The mixins folder must contain only mixin declarations', (selector) {
    expect(
      selector.classes(inFolder: 'lib/core/mixins'),
      isMixinType(),
    );
  });
}
```

---

### Names ending with Mixin must be mixins

Enforce the naming-declaration consistency: if a declaration is named `*Mixin`, it must be a `mixin`:

```dart title="test_arch/mixin_naming_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Declarations ending with Mixin must use the mixin keyword', (selector) {
    expect(
      selector.classes(inFolder: 'lib', matchingPattern: r'.*Mixin$'),
      isMixinType(),
    );
  });
}
```

This catches:

```dart
// lib/shared/logger_mixin.dart
class LoggerMixin {            // ← violation: named Mixin but declared as class
  void log(String message) { ... }
}
```

Which should be:

```dart
mixin LoggerMixin {            // ← correct: declared as mixin
  void log(String message) { ... }
}
```

---

### Combined mixin folder rules

Pair type checking with naming and dependency rules:

```dart title="test_arch/mixin_full_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArchGroup('Mixin folder rules', () {
    testArch('Mixin folder must contain only mixins', (selector) {
      expect(selector.classes(inFolder: 'lib/core/mixins'), isMixinType());
    });

    testArch('Mixins must not import from UI layer', (selector) {
      expect(selector.classes(inFolder: 'lib/core/mixins'), doesNotDependOn('lib/presentation'));
    });

    testArch('Mixins must not depend on domain-specific code', (selector) {
      expect(selector.classes(inFolder: 'lib/core/mixins'), doesNotDependOn('lib/domain'));
    });
  });
}
```

---

## Notes

- Dart 3 introduced `mixin class`, which can be used both as a mixin and as a class. Check your DartUnit version's behavior for `mixin class` declarations.
- To enforce that a class **uses** a specific mixin (rather than declaring itself a mixin), use [`usesMixin`](/predicates/uses-mixin/) instead.

---

## Related matchers

- [`usesMixin`](/predicates/uses-mixin/) — check if a class applies a specific mixin with `with`
- [`isEnumType`](/predicates/is-enum/) — require enum declaration
- [`isExtensionType`](/predicates/is-extension/) — require extension declaration
- [`isAbstractClass`](/predicates/is-abstract/) — require abstract class
