---
title: implementsInterface
description: Enforce that classes implement a specific interface. Used to ensure that implementation classes properly fulfill their declared contracts.
sidebar:
  order: 15
---

## What it does

`implementsInterface(interfaceName)` passes when the class declaration contains `implements InterfaceName`. The match is **exact and case-sensitive**. A class can implement multiple interfaces — this matcher passes if any one of them matches. Generic type arguments are ignored.

---

## What problem it solves

In Clean Architecture and similar patterns, concrete implementation classes are supposed to implement the abstract contracts defined in the domain layer. For example, `CartRepositoryImpl` (in `lib/data/repositories/`) should implement `CartRepository` (from `lib/domain/repositories/`).

Without enforcement, a developer might:
- Create `CartRepositoryImpl` and forget to add `implements CartRepository`
- Use a different interface name by mistake
- Bypass the interface entirely and just write the class independently

When `CartRepositoryImpl` doesn't implement `CartRepository`, it can't be injected anywhere a `CartRepository` is expected — which causes runtime errors that could have been caught at architecture test time.

`implementsInterface()` enforces the contract linkage automatically.

---

## Syntax

```dart
expect(subject, implementsInterface('InterfaceName'));
```

---

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `interfaceName` | `String` | yes | The interface name. Exact, case-sensitive match. Generic type arguments are ignored. A class can implement multiple interfaces — passes if any matches. |

---

## When to use

Use `implementsInterface()` when concrete implementation classes are required to fulfill a specific abstract contract:

- `*RepositoryImpl` classes must implement `Repository`
- `*DataSourceImpl` classes must implement the corresponding data source interface
- `*ServiceImpl` classes must implement `Service`
- Use case implementations must implement `UseCase`

---

## Common use cases

- Data repository implementations must implement their domain repository interface
- Data source implementations must implement their abstract data source
- All use case classes must implement the `UseCase` interface
- Adapter classes in hexagonal architecture must implement the corresponding port

---

## Examples

### Repository implementations must implement their interface

Ensure that all classes in the data repository folder implement a repository interface from the domain layer:

```dart title="test_arch/repo_implements_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Data repositories must implement a Repository interface', (selector) {
    expect(
      selector.classes(inFolder: 'lib/data/repositories', matchingPattern: r'.*Impl$'),
      implementsInterface('Repository'),
    );
  });
}
```

This ensures that `CartRepositoryImpl` has `implements CartRepository` in its declaration.

---

### Use cases must implement UseCase

If your team defines a shared `UseCase` interface, enforce that every use case class implements it:

```dart title="test_arch/usecase_implements_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Use case classes must implement the UseCase interface', (selector) {
    expect(
      selector.classes(inFolder: 'lib/domain/usecases'),
      implementsInterface('UseCase'),
    );
  });
}
```

---

### Full implementation contract validation

Combine interface implementation with naming and import rules for a complete structural check:

```dart title="test_arch/data_repo_full_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArchGroup('Data repository contracts', () {
    testArch('Data repos must implement domain repository', (selector) {
      expect(
        selector.classes(inFolder: 'lib/data/repositories', matchingPattern: r'.*Impl$'),
        implementsInterface('Repository'),
      );
    });

    testArch('Data repos must depend on domain', (selector) {
      expect(
        selector.classes(inFolder: 'lib/data/repositories', matchingPattern: r'.*Impl$'),
        dependsOn('lib/domain'),
      );
    });

    testArch('Data repos must be concrete classes', (selector) {
      expect(
        selector.classes(inFolder: 'lib/data/repositories', matchingPattern: r'.*Impl$'),
        isConcreteClass(),
      );
    });
  });
}
```

---

## Notes

- The match is **exact and case-sensitive**: `implementsInterface('Repository')` will not match `CartRepository` (the full name). It matches `implements CartRepository` because `CartRepository` contains `Repository` — wait, actually it matches the full interface name. `implementsInterface('CartRepository')` matches `implements CartRepository` exactly. Use the full interface name, not a substring.
- Generic type arguments are ignored: `implementsInterface('Repository')` matches `implements Repository<Cart>`.
- A class can implement multiple interfaces — the matcher passes if any one of them matches.

---

## Related matchers

- [`extendsClass`](/predicates/extends/) — require extending a specific class
- [`usesMixin`](/predicates/uses-mixin/) — require applying a specific mixin
- [`isConcreteClass`](/predicates/is-concrete-class/) — require concrete class declaration
- [`isAbstractClass`](/predicates/is-abstract/) — require abstract class declaration
