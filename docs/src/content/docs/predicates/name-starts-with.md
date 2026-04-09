---
title: nameStartsWith
description: Enforce that class names begin with a specific prefix. Commonly used for interface conventions like the "I" prefix.
sidebar:
  order: 5
---

## What it does

`nameStartsWith(prefix)` passes when the class name **begins with the exact given string**. The comparison is case-sensitive.

---

## What problem it solves

Naming conventions are a team communication tool. When a class starts with `I`, everyone immediately knows it's an interface. When a class starts with `Abstract`, everyone knows it's a base class. When a class starts with `Mock` or `Fake`, everyone knows it's a test double and shouldn't be in production code.

Without enforcement, conventions drift. Developers forget the prefix under deadline pressure. New team members don't know the convention. `nameStartsWith` makes naming conventions a hard rule instead of a soft guideline.

---

## Syntax

```dart
expect(subject, nameStartsWith('Prefix'));
```

---

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `prefix` | `String` | yes | The exact string the class name must begin with. Case-sensitive. |

---

## When to use

Use `nameStartsWith` when your team follows a **prefix convention** that identifies the role of a class at a glance. Common cases:

- **Interface prefix**: classes in a contracts folder must start with `I` (e.g., `ICartRepository`)
- **Abstract base prefix**: base classes must start with `Abstract` or `Base`
- **Test double detection**: classes starting with `Mock` or `Fake` must not appear in production code

For suffix conventions, use [`nameEndsWith`](/predicates/name-ends-with/) instead. For complex patterns that combine prefix + structure, use [`nameMatchesPattern`](/predicates/name-matches-pattern/) with a regex.

---

## Common use cases

- Interface contracts must start with `I` (e.g., `ICartRepository`, `IAuthService`)
- Abstract base classes must start with `Abstract` or `Base`
- Mock/Fake test doubles must not appear in `lib/` (ban `Mock`-prefixed classes in production)
- Event classes in a feature must start with the feature name

---

## Examples

### Interface prefix convention

Many teams prefix interface classes with `I` to make it immediately clear that a class is an abstract contract, not a concrete implementation:

```dart title="test_arch/interface_naming_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Interface classes must be prefixed with I', (arch) {
    expect(
      arch.classes(folder: 'lib/domain/contracts'),
      nameStartsWith('I'),
    );
  });
}
```

This ensures that `lib/domain/contracts/cart_repository.dart` must declare a class named `ICartRepository`, not just `CartRepository`.

---

### Ban test doubles from production code

Enforce that no mock or fake classes accidentally end up in `lib/` (they should only exist in test files):

```dart title="test_arch/no_test_doubles_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArchGroup('No test doubles in production code', () {
    testArch('No Mock-prefixed classes in lib/', (arch) {
      // Classes starting with Mock must not exist in lib/
      // If nameStartsWith('Mock') passes → violation
      // We select all classes and expect none to start with Mock
      expect(
        arch.classes(folder: 'lib'),
        nameMatchesPattern(r'^(?!Mock|Fake).*'),
      );
    });
  }, severity: RuleSeverity.error);
}
```

---

### Abstract base class prefix

Ensure that all base classes in a shared base folder follow the naming convention:

```dart title="test_arch/base_class_naming_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Abstract base classes must start with Base', (arch) {
    expect(
      arch.classes(folder: 'lib/core/base'),
      nameStartsWith('Base'),
    );
  });
}
```

---

## Notes

- The comparison is **case-sensitive**: `nameStartsWith('I')` will not match a class named `iCartRepository`.
- For multiple acceptable prefixes (e.g., `Abstract` OR `Base`), use [`nameMatchesPattern`](/predicates/name-matches-pattern/) with a regex alternation: `nameMatchesPattern(r'^(Abstract|Base).*')`.
- To ban a prefix (enforce that no class starts with something), combine with `nameMatchesPattern` and a negative lookahead.

---

## Related matchers

- [`nameEndsWith`](/predicates/name-ends-with/) — enforce a suffix convention
- [`nameContains`](/predicates/name-contains/) — require a keyword anywhere in the name
- [`nameMatchesPattern`](/predicates/name-matches-pattern/) — full regex for complex naming rules
