---
title: extendsClass
description: Enforce that classes extend a specific parent class. Commonly used to ensure BLoC classes extend Bloc, events extend a base event, and states extend Equatable.
sidebar:
  order: 14
---

## What it does

`extendsClass(className)` passes when the class declaration contains `extends ClassName`. The match is **exact and case-sensitive**. Generic type parameters are ignored — `extendsClass('Bloc')` matches `class CartBloc extends Bloc<CartEvent, CartState>`.

---

## What problem it solves

In pattern-based architectures (BLoC, MVC, MVVM), classes within a pattern must extend the correct base class to participate correctly. For example:

- A `CartBloc` that extends `Bloc` gets the event handling infrastructure automatically
- A `CartBloc` that doesn't extend `Bloc` won't work with `BlocProvider` and the Flutter BLoC ecosystem
- An event class that doesn't extend the base `CartEvent` can't be dispatched to `CartBloc`

Without enforcement, a developer might create a class in the right folder with the right name but forget to extend the correct base class. The class looks right from the outside but behaves incorrectly — a subtle bug that may not be caught by normal tests.

`extendsClass()` makes the inheritance requirement explicit and automatically verified.

---

## Syntax

```dart
expect(subject, extendsClass('ClassName'));
```

---

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `className` | `String` | yes | The parent class name. Exact, case-sensitive match. Generic type parameters are ignored — `'Bloc'` matches `extends Bloc<CartEvent, CartState>`. |

---

## When to use

Use `extendsClass()` when a particular folder or class pattern has a required parent class:

- BLoC classes in `lib/bloc/` must extend `Bloc` or `Cubit`
- Event classes must extend their respective base event
- State classes must extend `Equatable` (for value equality)
- Custom exceptions must extend `AppException` or `Failure`
- Controllers must extend `GetxController` (if using GetX)

---

## Common use cases

- All classes ending with `Bloc` must extend `Bloc`
- All classes ending with `Cubit` must extend `Cubit`
- Event classes must extend the feature base event
- State classes must extend `Equatable`
- Custom failures must extend `Failure`

---

## Examples

### BLoC classes must extend Bloc

Ensure that classes named `*Bloc` actually extend the `Bloc` base class from the flutter_bloc package:

```dart title="test_arch/bloc_extends_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Bloc classes must extend Bloc', (selector) {
    expect(
      selector.classes(inFolder: 'lib/bloc', matchingPattern: r'.*Bloc$'),
      extendsClass('Bloc'),
    );
  });
}
```

---

### Event and state inheritance

Enforce the full BLoC event/state hierarchy:

```dart title="test_arch/bloc_hierarchy_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArchGroup('CartBloc hierarchy', () {
    testArch('Cart events must extend CartEvent', (selector) {
      expect(
        selector.classes(inFolder: 'lib/bloc/cart', matchingPattern: r'.*Event$'),
        extendsClass('CartEvent'),
      );
    });

    testArch('Cart states must extend CartState', (selector) {
      expect(
        selector.classes(inFolder: 'lib/bloc/cart', matchingPattern: r'.*State$'),
        extendsClass('CartState'),
      );
    });

    testArch('CartBloc must extend Bloc', (selector) {
      expect(
        selector.classes(inFolder: 'lib/bloc/cart', matchingPattern: r'^CartBloc$'),
        extendsClass('Bloc'),
      );
    });
  });
}
```

---

### State classes must extend Equatable

If your team uses `Equatable` for value equality in state classes, make it a verified rule:

```dart title="test_arch/state_equatable_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('BLoC state classes must extend Equatable', (selector) {
    expect(
      selector.classes(inFolder: 'lib/bloc', matchingPattern: r'.*State$'),
      extendsClass('Equatable'),
    );
  });
}
```

---

## Notes

- The match is **exact and case-sensitive**: `extendsClass('Bloc')` will not match `BlocBase`.
- **Generic type parameters are ignored**: `extendsClass('Bloc')` matches `extends Bloc<CartEvent, CartState>`.
- For classes that may extend one of several valid parents, use multiple `testArch` calls with different `namePattern` selectors, or use `nameMatchesPattern` with alternation on the selector.

---

## Related matchers

- [`implementsInterface`](/predicates/implements-interface/) — require implementing a specific interface
- [`usesMixin`](/predicates/uses-mixin/) — require applying a specific mixin
- [`isAbstractClass`](/predicates/is-abstract/) — require abstract class declaration
- [`isConcreteClass`](/predicates/is-concrete-class/) — require concrete class
