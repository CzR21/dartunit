---
title: hasNoPublicMethods
description: Enforce that all methods are private — every method name starts with underscore. Used for fully internal implementation classes that should expose no public API.
sidebar:
  order: 26
---

## What it does

`hasNoPublicMethods()` passes when there are **no methods whose names do not start with `_`**. Constructors and overridden operators are typically excluded. A class with no methods at all passes vacuously.

---

## What problem it solves

`hasNoPublicMethods()` is a niche matcher — it's useful in specific architectural patterns where certain implementation classes are meant to be completely internal and should not expose any public API.

The typical use case is **internal helper classes** or **strategy implementations** that are only intended to be used by one specific collaborator. Making these classes expose a public API is risky: another developer may start using the class directly, bypassing the intended collaborator and creating unintended coupling.

By enforcing that all methods are private, you communicate clearly that the class is an implementation detail and should not be used directly.

---

## Syntax

```dart
expect(subject, hasNoPublicMethods());
```

---

## Parameters

This matcher takes **no parameters**.

**Passes when:** no method name starts without `_`. Constructors and overridden operators are typically excluded.

---

## When to use

This is an **uncommon matcher** — most classes should have at least some public methods. Use it only for classes that are deliberately designed to have no public API:

- Internal helper classes that delegate all work through private methods called by a single entry point
- Strategy implementation classes that should only be used through a factory or adapter
- Implementation-detail classes marked as `@internal` that should never be called directly

For most encapsulation needs, [`hasNoPublicFields`](/predicates/has-no-public-fields/) is more appropriate and more commonly used.

---

## Examples

### Fully internal utility classes

Internal processing classes that are meant to be used only through a specific orchestrator:

```dart title="test_arch/internal_class_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Internal classes must not expose a public API', (selector) {
    expect(
      selector.classes(inFolder: 'lib/internal'),
      hasNoPublicMethods(),
    );
  });
}
```

---

### Combined with hasNoPublicFields for complete privacy

For classes that should be completely opaque to the outside world:

```dart title="test_arch/private_strategy_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArchGroup('Strategy implementations must be fully private', () {
    testArch('Strategy classes must not expose public fields', (selector) {
      expect(selector.classes(inFolder: 'lib/internal/strategies'), hasNoPublicFields());
    });

    testArch('Strategy classes must not expose public methods', (selector) {
      expect(selector.classes(inFolder: 'lib/internal/strategies'), hasNoPublicMethods());
    });
  }, severity: RuleSeverity.info);
}
```

---

## Notes

- This matcher is **rarely the right choice** for regular application code. Most classes need some public methods — that's how they're useful.
- For general encapsulation, prefer [`hasNoPublicFields`](/predicates/has-no-public-fields/) (hiding state is usually more important than hiding methods).
- A class with no methods at all passes vacuously.

---

## Related matchers

- [`hasNoPublicFields`](/predicates/has-no-public-fields/) — enforce private fields (more commonly used)
- [`hasMethod`](/predicates/has-method/) — check for a specific method by name
- [`hasMaxMethods`](/predicates/max-methods/) — enforce a maximum number of methods
