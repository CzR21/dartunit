---
title: hasMethod
description: Enforce that a class declares a method with a specific name. Used to verify that classes fulfill interface contracts or follow behavioral conventions.
sidebar:
  order: 27
---

## What it does

`hasMethod(methodName)` passes when the class body contains **a method declaration with the exact given name**. The match is on the method name only — parameter signatures are not checked. A class with multiple overloaded methods of the same name still passes with any one of them.

---

## What problem it solves

Some class roles come with a behavioral contract that goes beyond the type system. For example:

- Use cases in Clean Architecture should expose a `call()` method — this is the convention that makes them callable as functions in Dart
- Repository implementations should have a `dispose()` method to clean up resources (streams, connections) when the repository is no longer needed
- Domain entities should expose a `copyWith()` method to create modified copies (the pattern used for immutable updates)

These conventions are easy to forget, especially for new team members. `hasMethod()` makes them enforceable rules rather than documentation that may or may not be read.

---

## Syntax

```dart
expect(subject, hasMethod('methodName'));
```

---

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `methodName` | `String` | yes | The exact name of the method that must be present. Case-sensitive. Matches by name only — parameter signature is not checked. |

---

## When to use

Use `hasMethod()` when classes in a folder are expected to fulfill a **behavioral contract** identified by a specific method name:

- Use cases must declare `call()` (Dart callable convention)
- Disposable resources must declare `dispose()`
- Immutable data classes should declare `copyWith()`
- Equatable entities must declare `props` getter (if using the `equatable` package without the mixin)
- Service classes should declare an `initialize()` method

---

## Common use cases

- Use case classes must declare a `call()` method
- Repository implementations must declare a `dispose()` method
- Domain entities should declare a `copyWith()` method
- BLoC classes should declare a `close()` override (if they manage resources)

---

## Examples

### Use cases must be callable

By convention, use cases in Dart expose their logic through `call()`, which allows them to be invoked like functions (`final result = await getCartUseCase(userId)`):

```dart title="test_arch/usecase_call_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Use case classes must declare a call() method', (arch) {
    expect(
      arch.classes(folder: 'lib/domain/usecases'),
      hasMethod('call'),
    );
  });
}
```

---

### Repository implementations must clean up resources

Repositories often hold open streams, HTTP connections, or database cursors. Enforce that they declare a `dispose()` method:

```dart title="test_arch/repo_dispose_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Repository implementations must declare a dispose() method', (arch) {
    expect(
      arch.classes(folder: 'lib/data/repositories', namePattern: r'.*Impl$'),
      hasMethod('dispose'),
    );
  });
}
```

---

### Entities must support copyWith

Immutable domain entities need a `copyWith()` method to create modified copies without mutating the original:

```dart title="test_arch/entity_copy_with_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Domain entities should declare a copyWith() method', (arch) {
    expect(
      arch.classes(folder: 'lib/domain/entities'),
      hasMethod('copyWith'),
    );
  });
}
```

---

### Checking one of several method names

If a class may satisfy the contract with one of several possible methods (e.g., `call` OR `execute`), run two separate tests — the architecture test fails only if both are absent. This is done by restructuring the rule:

```dart title="test_arch/usecase_flexible_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  // Check that use cases have at least one of: call() or execute()
  // Use nameMatchesPattern to split the selection
  testArchGroup('Use case entry point', () {
    testArch('Call-style use cases must have call()', (arch) {
      // Use cases following the call() convention
      expect(
        arch.classes(folder: 'lib/domain/usecases', namePattern: r'Get.*UseCase$'),
        hasMethod('call'),
      );
    });

    testArch('Execute-style use cases must have execute()', (arch) {
      // Use cases following the execute() convention
      expect(
        arch.classes(folder: 'lib/domain/usecases', namePattern: r'.*Interactor$'),
        hasMethod('execute'),
      );
    });
  });
}
```

---

## Notes

- The match is on the method **name only** — parameters and return types are not checked.
- If a class has no methods at all, it fails `hasMethod()` for any method name.
- The matcher checks for a method declaration in the class body — inherited methods (from a parent class) do not count.

---

## Related matchers

- [`hasMinMethods`](/predicates/min-methods/) — require a minimum number of methods
- [`hasMaxMethods`](/predicates/max-methods/) — enforce a maximum number of methods
- [`hasNoPublicMethods`](/predicates/has-no-public-methods/) — enforce all methods are private
- [`implementsInterface`](/predicates/implements-interface/) — require implementing a formal interface
