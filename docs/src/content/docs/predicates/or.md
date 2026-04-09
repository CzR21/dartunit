---
title: Combining matchers — OR
description: How to express "must satisfy condition A OR condition B" in DartUnit rules. OR conditions on names use nameMatchesPattern with regex alternation.
sidebar:
  order: 30
---

## What it does

In DartUnit, the **OR** combination is expressed through **regex alternation** in `nameMatchesPattern()`. The pattern `r'.*(Bloc|Cubit)$'` means "must end with `Bloc` OR `Cubit`".

For structural OR conditions (e.g., "must implement InterfaceA OR InterfaceB"), use the `namePattern` parameter in `arch.classes()` to split the selection into separate rules.

---

## What problem it solves

Some rules need to accept multiple valid alternatives:

- A state manager class may be a `Bloc` or a `Cubit` — both are valid
- A use case may expose its entry point as `call()` or `execute()` — both conventions exist
- A repository implementation may implement `CartRepository` or `ICartRepository` — both naming conventions are in use

Forcing a single option when multiple are valid would make the rule reject legitimate code. OR conditions let you express flexibility without abandoning enforcement entirely.

---

## Syntax for naming OR conditions

For name-based OR, use `nameMatchesPattern` with regex alternation (`|`):

```dart
// Class must end with 'Bloc' OR 'Cubit'
expect(subject, nameMatchesPattern(r'.*(Bloc|Cubit)$'));

// Class must start with 'Abstract' OR 'Base'
expect(subject, nameMatchesPattern(r'^(Abstract|Base)[A-Z].*'));

// Class must match one of several patterns
expect(subject, nameMatchesPattern(r'^(Cart|Order|Payment)[A-Z].*'));
```

---

## Syntax for structural OR conditions

For structural OR (e.g., implements one interface OR another), use the `namePattern` parameter in `arch.classes()` to select each group separately and apply a specific rule to each:

```dart
testArchGroup('Use case entry points', () {
  testArch('Call-style use cases must have call()', (arch) {
    expect(
      arch.classes(folder: 'lib/usecases', namePattern: r'Get.*UseCase$'),
      hasMethod('call'),
    );
  });

  testArch('Execute-style interactors must have execute()', (arch) {
    expect(
      arch.classes(folder: 'lib/usecases', namePattern: r'.*Interactor$'),
      hasMethod('execute'),
    );
  });
});
```

---

## Examples

### State managers must be Bloc OR Cubit

```dart title="test_arch/state_manager_naming_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('State management classes must end with Bloc or Cubit', (arch) {
    expect(
      arch.classes(folder: 'lib/bloc'),
      nameMatchesPattern(r'^[A-Z][a-zA-Z]+(Bloc|Cubit)$'),
    );
  });
}
```

---

### Data model classes may end with Model OR Dto

```dart title="test_arch/model_naming_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Data classes must end with Model or Dto', (arch) {
    expect(
      arch.classes(folder: 'lib/data/models'),
      nameMatchesPattern(r'^[A-Z][a-zA-Z]+(Model|Dto)$'),
    );
  });
}
```

---

### Abstract base class may start with Abstract OR Base

```dart title="test_arch/base_naming_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Base classes must start with Abstract or Base', (arch) {
    expect(
      arch.classes(folder: 'lib/core/base'),
      nameMatchesPattern(r'^(Abstract|Base)[A-Z][a-zA-Z]+$'),
    );
  });
}
```

---

### Use cases may use call() OR execute()

Use `namePattern` to split into separate groups when the OR condition is structural (not a naming pattern):

```dart title="test_arch/usecase_entry_point_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArchGroup('Use case entry points', () {
    // Group 1: classes following the call() convention
    testArch('UseCase-named classes must have call()', (arch) {
      expect(
        arch.classes(folder: 'lib/domain/usecases', namePattern: r'.*UseCase$'),
        hasMethod('call'),
      );
    });

    // Group 2: classes following the execute() convention
    testArch('Interactor-named classes must have execute()', (arch) {
      expect(
        arch.classes(folder: 'lib/domain/usecases', namePattern: r'.*Interactor$'),
        hasMethod('execute'),
      );
    });
  });
}
```

---

## Regex alternation quick reference

| Goal | Pattern |
|------|---------|
| Ends with A or B | `r'.*(A\|B)$'` |
| Starts with A or B | `r'^(A\|B).*'` |
| Matches A or B exactly | `r'^(A\|B)$'` |
| Contains A or B | `r'.*(A\|B).*'` |

---

## Related pages

- [AND conditions](/predicates/and/) — how to express "condition A AND condition B"
- [NOT conditions](/predicates/not/) — how to express "must NOT satisfy condition"
- [`nameMatchesPattern`](/predicates/name-matches-pattern/) — full regex naming documentation
