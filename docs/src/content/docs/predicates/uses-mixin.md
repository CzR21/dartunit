---
title: usesMixin
description: Enforce that classes apply a specific mixin using the with keyword. Commonly used to require Equatable, JsonSerializable, or other shared behavior mixins.
sidebar:
  order: 16
---

## What it does

`usesMixin(mixinName)` passes when the class declaration contains `with MixinName`. The match is **exact and case-sensitive**. A class can apply multiple mixins — this matcher passes if any one of them matches.

Note: this is different from [`isMixinType`](/predicates/is-mixin/) — that matcher checks if a declaration *is* a mixin. `usesMixin` checks if a class *applies* a mixin.

---

## What problem it solves

Mixins are a Dart mechanism for injecting shared behavior into a class without inheritance. Many architecture patterns rely on specific mixins being applied consistently across a set of classes:

- **Value equality**: domain entities and state classes should use `EquatableMixin` so that `==` comparison works correctly.
- **Serialization**: data models should use `JsonSerializableMixin` to enable code generation.
- **Logging or observability**: services should use a `LoggableMixin` to consistently emit structured logs.

Without enforcement, developers may forget to apply the mixin, causing subtle bugs:
- A state class without `EquatableMixin` will cause unnecessary UI rebuilds in BLoC-based apps because `==` falls back to reference comparison.
- A data model without the serialization mixin will fail at runtime when the JSON encoder tries to call methods that don't exist.

---

## Syntax

```dart
expect(subject, usesMixin('MixinName'));
```

---

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `mixinName` | `String` | yes | The mixin name. Exact, case-sensitive match. A class can apply multiple mixins — passes if any one matches. |

---

## When to use

Use `usesMixin()` when a specific set of classes is required to apply a shared behavior mixin:

- BLoC state classes must apply `EquatableMixin` for correct equality semantics
- Domain entities must apply `EquatableMixin` for value comparison
- Data models must apply `JsonSerializableMixin` for JSON generation
- Services must apply a logging mixin for consistent observability

---

## Common use cases

- Domain entities must use `EquatableMixin`
- BLoC state classes must use `EquatableMixin`
- Data models must use `JsonSerializableMixin`
- Classes in a specific folder must apply a shared audit mixin

---

## Examples

### BLoC states must use Equatable

BLoC rebuilds the UI only when the state changes. For this to work, `==` comparison must return `true` for equal states. Without `Equatable`, every state emission triggers a rebuild because two states with identical values are considered different objects:

```dart title="test_arch/state_equatable_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('BLoC state classes must use EquatableMixin', (selector) {
    expect(
      selector.classes(inFolder: 'lib/bloc', matchingPattern: r'.*State$'),
      usesMixin('EquatableMixin'),
    );
  });
}
```

---

### Domain entities must use Equatable

Domain entities represent business concepts. Two entities with the same identity and fields should compare as equal. Without `EquatableMixin`, a use case comparing `entity1 == entity2` will always return `false` (reference comparison):

```dart title="test_arch/entity_equatable_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Domain entities must use EquatableMixin for value equality', (selector) {
    expect(
      selector.classes(inFolder: 'lib/domain/entities'),
      usesMixin('EquatableMixin'),
    );
  });
}
```

---

### Data models must use JSON mixin

Ensure all data model classes are set up for JSON serialization:

```dart title="test_arch/model_mixin_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Data models must apply JsonSerializableMixin', (selector) {
    expect(
      selector.classes(inFolder: 'lib/data/models'),
      usesMixin('JsonSerializableMixin'),
    );
  });
}
```

---

## Notes

- The match is **exact and case-sensitive**: `usesMixin('EquatableMixin')` will not match `Equatable`.
- A class can apply multiple mixins — the matcher passes if any one of them matches.
- To require a class to apply **multiple** specific mixins simultaneously, use multiple `expect()` calls in the same `testArch`.

---

## Related matchers

- [`isMixinType`](/predicates/is-mixin/) — check if the declaration *is* a mixin
- [`extendsClass`](/predicates/extends/) — require extending a specific class
- [`implementsInterface`](/predicates/implements-interface/) — require implementing a specific interface
- [`hasAllFinalFields`](/predicates/has-all-final-fields/) — combine with mixin to ensure immutability
