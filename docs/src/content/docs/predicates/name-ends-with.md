---
title: nameEndsWith
description: Enforce that class names end with a specific suffix. The most common naming matcher — used for Repository, Bloc, Service, Impl, and similar conventions.
sidebar:
  order: 6
---

## What it does

`nameEndsWith(suffix)` passes when the class name **ends with the exact given string**. The comparison is case-sensitive.

---

## What problem it solves

Suffix conventions are the most common naming pattern in Dart/Flutter projects. `CartRepository`, `CartBloc`, `CartService`, `CartRepositoryImpl` — the suffix immediately tells you what role the class plays in the architecture.

Without enforcement, these conventions erode over time. A repository gets named `CartData` instead of `CartRepository`. A BLoC gets named `CartManager` instead of `CartBloc`. The architecture becomes harder to navigate because you can't identify class roles by name alone.

`nameEndsWith` makes suffix conventions a failing test rather than a guideline.

---

## Syntax

```dart
expect(subject, nameEndsWith('Suffix'));
```

---

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `suffix` | `String` | yes | The exact string the class name must end with. Case-sensitive. |

---

## When to use

Use `nameEndsWith` whenever your team has a **suffix convention** for a folder. Some common patterns:

| Folder | Expected suffix |
|--------|----------------|
| `lib/domain/repositories` | `Repository` |
| `lib/data/repositories` | `RepositoryImpl` or `Impl` |
| `lib/bloc` | `Bloc` or `Cubit` |
| `lib/domain/usecases` | `UseCase` |
| `lib/domain/entities` | `Entity` |
| `lib/data/models` | `Model` or `Dto` |
| `lib/services` | `Service` |

---

## Common use cases

- Repository interfaces must end with `Repository`
- Repository implementations must end with `Impl`
- BLoC classes must end with `Bloc` or `Cubit`
- Use case classes must end with `UseCase`
- Event classes must end with `Event`
- State classes must end with `State`

---

## Examples

### Repository suffix convention

All classes in the domain repository folder must end with `Repository` — this makes it immediately clear they define repository contracts:

```dart title="test_arch/repo_naming_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Domain repositories must end with Repository', (arch) {
    expect(
      arch.classes(folder: 'lib/domain/repositories'),
      nameEndsWith('Repository'),
    );
  });
}
```

---

### BLoC and Cubit naming

Your team uses both BLoC and Cubit. Both are valid — the rule should accept either suffix:

```dart title="test_arch/bloc_naming_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('State managers must end with Bloc or Cubit', (arch) {
    expect(
      arch.classes(folder: 'lib/bloc'),
      // For OR conditions with names, use nameMatchesPattern with regex alternation
      nameMatchesPattern(r'.*(Bloc|Cubit)$'),
    );
  });
}
```

---

### Full BLoC layer naming suite

A comprehensive test that checks all the BLoC-related naming conventions at once:

```dart title="test_arch/bloc_full_naming_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArchGroup('BLoC layer naming conventions', () {
    testArch('BLoC classes must end with Bloc', (arch) {
      expect(
        arch.classes(folder: 'lib/bloc', namePattern: r'.*Bloc$'),
        nameEndsWith('Bloc'),
      );
    });

    testArch('Event classes must end with Event', (arch) {
      expect(
        arch.classes(folder: 'lib/bloc', namePattern: r'.*Event$'),
        nameEndsWith('Event'),
      );
    });

    testArch('State classes must end with State', (arch) {
      expect(
        arch.classes(folder: 'lib/bloc', namePattern: r'.*State$'),
        nameEndsWith('State'),
      );
    });
  });
}
```

---

## Notes

- The comparison is **case-sensitive**: `nameEndsWith('Repository')` will not match `CartREPOSITORY`.
- For **multiple acceptable suffixes** (e.g., `Bloc` OR `Cubit`), use [`nameMatchesPattern`](/predicates/name-matches-pattern/) with a regex alternation: `nameMatchesPattern(r'.*(Bloc|Cubit)$')`.
- To combine suffix check with structural requirements, add multiple `expect()` calls in the same `testArch`.

---

## Related matchers

- [`nameStartsWith`](/predicates/name-starts-with/) — enforce a prefix convention
- [`nameContains`](/predicates/name-contains/) — require a keyword anywhere in the name
- [`nameMatchesPattern`](/predicates/name-matches-pattern/) — full regex for complex naming rules
