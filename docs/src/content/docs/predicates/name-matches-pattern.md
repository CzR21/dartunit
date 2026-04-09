---
title: nameMatchesPattern
description: Enforce naming conventions using a full regular expression. The most flexible naming matcher — use when prefix/suffix/contains are not expressive enough.
sidebar:
  order: 8
---

## What it does

`nameMatchesPattern(pattern)` passes when the class name **matches the given regular expression**. It uses Dart's `RegExp` class internally and matches against the complete class name.

This is the most powerful naming matcher. Use it when you need to express rules that combine multiple conditions — such as "must start with a capital letter, followed by any characters, and end with `Bloc`" or "must start with `Abstract` OR `Base`".

---

## What problem it solves

Real naming conventions are often more complex than a simple prefix or suffix. For example:

- BLoC classes must follow PascalCase AND end with `Bloc` (e.g., `CartBloc`, not `cartBloc` or `Cart_Bloc`)
- Interface classes must start with `I` followed by a capital letter (e.g., `ICartRepository`, not `Irepository`)
- A class may be named with one of several acceptable suffixes (`Bloc` or `Cubit`)

`nameStartsWith`, `nameEndsWith`, and `nameContains` are limited to simple string checks. `nameMatchesPattern` gives you the full power of regular expressions to express any naming rule precisely.

---

## Syntax

```dart
expect(subject, nameMatchesPattern(r'^YourPattern$'));
```

---

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `pattern` | `String` | yes | A Dart regex string matched against the full class name. Case-sensitive by default. Use `(?i)` for case-insensitive matching. |

**Tip:** Always use anchors (`^` at the start, `$` at the end) to avoid partial matches. Without anchors, the pattern `Bloc` would also match `BlocHelper` since `Bloc` appears inside the name.

---

## When to use

Use `nameMatchesPattern` when you need to express naming rules that go beyond a simple prefix, suffix, or substring:

- **OR conditions**: class must end with `Bloc` OR `Cubit`
- **PascalCase enforcement**: class name must start with an uppercase letter
- **Combined rules**: must start with `Abstract` or `Base`, followed by an uppercase letter
- **Negative lookahead**: must NOT contain `Mock` or `Test` anywhere in the name
- **Complex patterns**: interface classes must follow `I[A-Z][a-zA-Z]+` (capital I followed by PascalCase)

---

## Common use cases

- BLoC classes must match `^[A-Z][a-zA-Z]+Bloc$` (PascalCase + Bloc suffix)
- State managers must end with `Bloc` OR `Cubit`
- Interfaces must match `^I[A-Z][a-zA-Z]+$` (I prefix + PascalCase)
- Entity classes must match `^[A-Z][a-zA-Z]+Entity$`

---

## Examples

### Strict BLoC naming convention

BLoC classes must be in PascalCase and end with `Bloc`. This rejects names like `cartBloc` (lowercase start) or `Cart_Bloc` (underscore):

```dart title="test_arch/bloc_naming_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('BLoC classes must follow PascalCase and end with Bloc', (arch) {
    expect(
      arch.classes(folder: 'lib/bloc', namePattern: r'.*Bloc$'),
      nameMatchesPattern(r'^[A-Z][a-zA-Z]+Bloc$'),
    );
  });
}
```

---

### OR condition — Bloc or Cubit

Your team uses both BLoC and Cubit. Express this as an OR condition using regex alternation:

```dart title="test_arch/state_manager_naming_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('State managers must end with Bloc or Cubit', (arch) {
    expect(
      arch.classes(folder: 'lib/bloc'),
      nameMatchesPattern(r'^[A-Z][a-zA-Z]+(Bloc|Cubit)$'),
    );
  });
}
```

---

### Interface naming convention

Interfaces must follow the `I` prefix convention with PascalCase: `ICartRepository`, `IAuthService` — NOT `Icart` or `iCart`:

```dart title="test_arch/interface_naming_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Interface classes must follow I + PascalCase naming', (arch) {
    expect(
      arch.classes(folder: 'lib/domain/contracts'),
      // I followed by an uppercase letter followed by more letters
      nameMatchesPattern(r'^I[A-Z][a-zA-Z]+$'),
    );
  });
}
```

---

### Comprehensive naming suite

A complete naming validation for a Clean Architecture project:

```dart title="test_arch/naming_suite_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArchGroup('Naming conventions', () {
    testArch('Domain repositories follow naming', (arch) {
      expect(
        arch.classes(folder: 'lib/domain/repositories'),
        nameMatchesPattern(r'^[A-Z][a-zA-Z]+Repository$'),
      );
    });

    testArch('Domain entities follow naming', (arch) {
      expect(
        arch.classes(folder: 'lib/domain/entities'),
        nameMatchesPattern(r'^[A-Z][a-zA-Z]+Entity$'),
      );
    });

    testArch('Use cases follow naming', (arch) {
      expect(
        arch.classes(folder: 'lib/domain/usecases'),
        nameMatchesPattern(r'^[A-Z][a-zA-Z]+(UseCase|Interactor)$'),
      );
    });

    testArch('Data models follow naming', (arch) {
      expect(
        arch.classes(folder: 'lib/data/models'),
        nameMatchesPattern(r'^[A-Z][a-zA-Z]+(Model|Dto)$'),
      );
    });
  });
}
```

---

## Regex quick reference

| Goal | Pattern |
|------|---------|
| PascalCase | `^[A-Z][a-zA-Z]+$` |
| Ends with Bloc or Cubit | `^.+(Bloc\|Cubit)$` |
| Starts with I + PascalCase | `^I[A-Z][a-zA-Z]+$` |
| Does NOT contain Mock | `^(?!.*Mock).*$` |
| Starts with Abstract or Base | `^(Abstract\|Base)[A-Z].*$` |
| Any PascalCase word + suffix | `^[A-Z][a-zA-Z]+Suffix$` |

---

## Notes

- The pattern is matched against the **class name only**, not the file path.
- Anchors (`^` and `$`) are strongly recommended to avoid partial matches.
- Use raw strings (`r'...'`) in Dart to avoid double-escaping backslashes.

---

## Related matchers

- [`nameStartsWith`](/predicates/name-starts-with/) — simpler prefix enforcement
- [`nameEndsWith`](/predicates/name-ends-with/) — simpler suffix enforcement
- [`nameContains`](/predicates/name-contains/) — simpler substring check
