---
title: isConcreteClass
description: Enforce that declarations are plain concrete classes — not abstract, not mixin, not enum, not extension. Used to validate implementation folders.
sidebar:
  order: 10
---

## What it does

`isConcreteClass()` passes when the declaration is a **plain concrete class** — written with only the `class` keyword, without `abstract`, `mixin`, `enum`, or `extension type` qualifiers.

This is more specific than just "not abstract". A mixin is not abstract, but it is also not a concrete class. An enum is not abstract, but it is not a concrete class either. `isConcreteClass()` checks for exactly a plain `class` declaration.

---

## What problem it solves

Folders that are meant to hold implementations should contain concrete classes and nothing else. If a `lib/data/repositories/` folder accidentally contains an abstract class, a mixin, or an enum, that signals a structural mistake — the file is in the wrong place.

`isConcreteClass()` ensures that implementation folders contain only the concrete classes they're supposed to contain.

---

## Syntax

```dart
expect(subject, isConcreteClass());
```

---

## Parameters

This matcher takes **no parameters**.

**Passes when:** the declaration is a plain `class Foo` without `abstract`, `mixin`, `enum`, or `extension type` qualifiers.

---

## When to use

Use `isConcreteClass()` for folders that should contain **implementations**, not contracts or types:

- `lib/data/repositories/` — concrete repository implementations
- `lib/data/datasources/` — concrete data source implementations
- `lib/domain/usecases/` — concrete use case implementations (if your team makes use cases concrete)
- `lib/data/models/` — concrete data model classes

Do not apply it to folders that intentionally contain abstract classes, enums, or mixins.

---

## Common use cases

- Repository implementation folder must contain only concrete classes (no abstract classes accidentally placed here)
- Use case folder must contain concrete use case implementations
- Data models must be concrete classes (not abstract)
- Implementation classes named `*Impl` must always be concrete

---

## Examples

### Implementation folder must be all-concrete

Ensure that the repository implementation folder does not accidentally contain abstract classes:

```dart title="test_arch/data_concrete_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Data repositories must be concrete classes', (arch) {
    expect(
      arch.classes(folder: 'lib/data/repositories'),
      isConcreteClass(),
    );
  });
}
```

---

### Impl-suffixed classes must be concrete

Any class ending with `Impl` is by definition an implementation — it should never be abstract:

```dart title="test_arch/impl_concrete_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Classes named *Impl must be concrete', (arch) {
    expect(
      arch.classes(namePattern: r'.*Impl$'),
      isConcreteClass(),
    );
  });
}
```

---

### Pair with isAbstractClass for a complete boundary

Enforce the complete contract — interfaces are abstract, implementations are concrete:

```dart title="test_arch/repository_structure_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArchGroup('Repository layer structure', () {
    testArch('Domain repositories (interfaces) must be abstract', (arch) {
      expect(arch.classes(folder: 'lib/domain/repositories'), isAbstractClass());
    });

    testArch('Data repositories (implementations) must be concrete', (arch) {
      expect(arch.classes(folder: 'lib/data/repositories'), isConcreteClass());
    });
  });
}
```

---

## Notes

- `isConcreteClass()` excludes mixins, enums, and extension types — not just abstract classes.
- A `final class` or `base class` (Dart 3 modifiers) will still pass as concrete if they don't use the `abstract` keyword.
- Combine with `implementsInterface` to ensure concrete classes also fulfill the expected contract.

---

## Related matchers

- [`isAbstractClass`](/predicates/is-abstract/) — require abstract class declaration
- [`isEnumType`](/predicates/is-enum/) — require enum declaration
- [`isMixinType`](/predicates/is-mixin/) — require mixin declaration
- [`implementsInterface`](/predicates/implements-interface/) — require implementing a specific interface
