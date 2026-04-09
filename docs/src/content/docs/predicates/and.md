---
title: Combining matchers — AND
description: How to express "must satisfy condition A AND condition B" in DartUnit rules. Multiple expect() calls inside one testArch are automatically combined with AND.
sidebar:
  order: 29
---

## What it does

In DartUnit, the **AND** combination is expressed simply by calling `expect()` multiple times inside a single `testArch`. Every `expect()` call must pass — if any one fails, the test fails and all violations are reported.

There is no separate `and()` matcher in the test API. Multiple `expect()` calls are the idiomatic way to combine conditions.

---

## What problem it solves

Real architecture rules often involve multiple conditions at once:

- "Service classes must be injectable AND have no public fields AND not import from the UI layer"
- "Repository implementations must implement the repository interface AND be concrete AND depend on the domain layer"
- "BLoC state classes must have all final fields AND have at most 8 fields AND extend Equatable"

Expressing multiple conditions in a single `testArch` keeps related rules together, shares the same description in violation messages, and is more readable than splitting every condition into its own test.

---

## Syntax

```dart
testArch('Description of the combined rule', (arch) {
  final subject = arch.classes(folder: 'lib/some/folder');

  expect(subject, conditionA());
  expect(subject, conditionB());
  expect(subject, conditionC());
  // All must pass — if any fails, the test fails
});
```

Each `expect()` is independent. All violations from all `expect()` calls are collected and reported together.

---

## Examples

### Service class must satisfy multiple conditions

Services must be properly named, annotated for DI, encapsulated, and isolated from the UI:

```dart title="test_arch/service_rules_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Service classes must satisfy all structural rules', (arch) {
    final services = arch.classes(folder: 'lib/services');

    expect(services, nameEndsWith('Service'));
    expect(services, hasAnnotation('injectable'));
    expect(services, hasNoPublicFields());
    expect(services, doesNotDependOn('lib/presentation'));
  });
}
```

---

### Repository implementation contracts

Repository implementations must be concrete, implement their interface, depend on domain, and not import from UI:

```dart title="test_arch/data_repo_contracts_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Repository implementations must fulfill all contracts', (arch) {
    final repos = arch.classes(
      folder: 'lib/data/repositories',
      namePattern: r'.*Impl$',
    );

    expect(repos, isConcreteClass());
    expect(repos, implementsInterface('Repository'));
    expect(repos, dependsOn('lib/domain'));
    expect(repos, doesNotDependOn('lib/presentation'));
    expect(repos, doesNotDependOn('lib/bloc'));
  });
}
```

---

### Domain entity quality rules

Domain entities must be immutable, small, and isolated:

```dart title="test_arch/entity_quality_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Domain entities must be immutable and well-structured', (arch) {
    final entities = arch.classes(folder: 'lib/domain/entities');

    expect(entities, hasAllFinalFields());    // must be immutable
    expect(entities, hasMinFields(1));        // must carry state
    expect(entities, hasMaxFields(10));       // must not be God Objects
    expect(entities, hasMethod('copyWith'));  // must support immutable update
    expect(entities, doesNotDependOn('lib/data'));         // domain isolation
    expect(entities, doesNotDependOn('lib/presentation')); // domain isolation
  });
}
```

---

## Using testArchGroup for related rules

When you have many related conditions, organize them in a `testArchGroup`. Each `testArch` inside the group becomes a named rule, and violations are grouped by test name in the output:

```dart title="test_arch/full_architecture_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArchGroup('Clean Architecture rules', () {
    testArch('Domain entities are immutable and isolated', (arch) {
      final entities = arch.classes(folder: 'lib/domain/entities');
      expect(entities, hasAllFinalFields());
      expect(entities, doesNotDependOn('lib/data'));
    });

    testArch('Repository implementations are concrete and correct', (arch) {
      final repos = arch.classes(folder: 'lib/data/repositories', namePattern: r'.*Impl$');
      expect(repos, isConcreteClass());
      expect(repos, dependsOn('lib/domain'));
    });

    testArch('BLoC classes are encapsulated and focused', (arch) {
      final blocs = arch.classes(folder: 'lib/bloc', namePattern: r'.*Bloc$');
      expect(blocs, hasNoPublicFields());
      expect(blocs, hasMaxMethods(10));
    });
  }, severity: RuleSeverity.error);
}
```

---

## Related pages

- [OR conditions](/predicates/or/) — how to express "condition A OR condition B"
- [NOT conditions](/predicates/not/) — how to express "must NOT satisfy condition"
- [`testArch` API reference](/custom-rules/api/) — full `testArch` and `expect()` documentation
