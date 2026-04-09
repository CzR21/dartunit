---
title: mustBeImmutable
description: Enforce that all instance fields in specified folders are final or const. Prevents accidental mutation of states, models, and value objects.
sidebar:
  order: 7
---

`mustBeImmutable` enforces that every instance field in every class within the specified folders is declared `final` or `const`. Mutable fields in state objects, models, and value objects are one of the most common sources of subtle, hard-to-diagnose bugs in Flutter applications.

---

## Why immutability matters in Dart and Flutter

### BLoC state must be immutable

The BLoC pattern relies on a central invariant: state is immutable. When the bloc emits a new state, BlocBuilder compares the previous and current states. If they are equal (`==` returns `true`), no rebuild happens. If they differ, the widget tree rebuilds.

When a state class has a mutable field, this invariant breaks silently:

```dart
// Dangerous: items is mutable
class CartState {
  List<CartItem> items;  // no final keyword

  CartState(this.items);
}
```

A developer writes:

```dart
// In the bloc
state.items.add(newItem);  // mutates the existing state in place
emit(state);               // emits the SAME object reference
```

The bloc emits the same object. The `==` check compares the object to itself — it is equal. `BlocBuilder` does not rebuild. The item was added to the list, but the UI shows the old item count. This is the exact scenario that `final` fields prevent.

With `final`:

```dart
class CartState {
  final List<CartItem> items;  // final: can't reassign the field
  CartState(this.items);
}
```

`state.items.add(newItem)` is still possible (the list itself is still mutable), but `state.items = newItem` is now a compile error. More importantly, the pattern forces developers to create new states:

```dart
emit(CartState([...state.items, newItem]));  // new object, new reference
```

Now `==` correctly identifies the two states as different and triggers a rebuild.

### `Equatable` comparisons depend on field values

The `equatable` package — almost universally used with BLoC — generates `==` and `hashCode` based on the fields returned by `props`. If a field is mutable and gets mutated, `equatable`'s hash code becomes stale: the object lives in a hash map under the old hash but its current state hashes to a different value. This causes the object to "disappear" from hash maps and sets.

Immutable fields prevent this category of bug entirely. If a field cannot be reassigned, the hash code derived from its value is stable for the lifetime of the object.

### `const` widgets require `const` constructors

Flutter's performance optimization for static widget subtrees relies on the `const` keyword. A `const` constructor requires all fields to be `final`. If a model class used as a widget property has mutable fields, you cannot create `const` instances of widgets that embed it, forgoing the optimization.

### `copyWith` pattern

Immutable classes commonly implement `copyWith` to produce modified copies:

```dart
class CartState {
  final List<CartItem> items;
  final bool isLoading;
  final String? error;

  const CartState({
    required this.items,
    this.isLoading = false,
    this.error,
  });

  CartState copyWith({
    List<CartItem>? items,
    bool? isLoading,
    String? error,
  }) {
    return CartState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
```

`copyWith` only makes sense on an immutable class. If fields were mutable, you could just assign to them directly — no copy needed. The presence of `copyWith` in a codebase is a signal that the class is supposed to be immutable, but without enforcement, the `final` keyword might be omitted during a rushed refactor.

---

## A concrete bug scenario

Consider a shopping cart application with this state class:

```dart
// Without mustBeImmutable, this compiles silently
class CartState extends Equatable {
  List<CartItem> items;        // NOT final — this is the bug
  double totalPrice;           // NOT final

  CartState({required this.items, required this.totalPrice});

  @override
  List<Object?> get props => [items, totalPrice];
}
```

The CartBloc:

```dart
class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(CartState(items: [], totalPrice: 0));

  on<AddItemEvent>((event, emit) {
    // Developer mutates the list thinking this will trigger a rebuild
    state.items.add(event.item);
    state.totalPrice += event.item.price;
    emit(state);  // emits the same object reference
  });
}
```

`BlocBuilder` receives the emit. It calls `state == previousState`. Because `Equatable` compares by value, and both `state` and `previousState` are the same object, they are equal. No rebuild. The cart appears frozen even though the data changed.

With `mustBeImmutable` targeting `lib/bloc/states/` (or wherever `CartState` lives), this compiles but DartUnit reports a violation before CI passes. The developer is forced to fix the state class before the code merges.

---

## The distinction between `final` and deeply immutable

`mustBeImmutable` enforces `final` field declarations. This is **reference immutability**, not **deep immutability**. Understanding the distinction prevents false confidence.

### What `final` prevents

```dart
class CartState {
  final List<CartItem> items;
  CartState(this.items);
}

final state = CartState([]);
state.items = [CartItem('apple')];  // compile error: items is final
```

Field reassignment is impossible. The `items` field will always point to the same `List` object for the lifetime of the `CartState` instance.

### What `final` does NOT prevent

```dart
final state = CartState([]);
state.items.add(CartItem('apple'));  // compiles and runs: the List itself is mutable
```

The list is mutable. You can add to it, remove from it, and sort it. The `final` keyword only prevents `state.items` from being reassigned to a different list.

### Achieving deep immutability

For truly deep immutability, use:

- `const List` / `List.unmodifiable` for list fields
- `package:freezed` which generates deeply immutable data classes
- `package:built_value` for immutable value types
- `UnmodifiableListView` from `dart:collection` for read-only list exposure

`mustBeImmutable` is a necessary but not sufficient condition for deep immutability. It closes the most common mutation pathway (field reassignment) but does not protect against collection mutation. For full protection, pair it with a review practice or freezed-generated classes.

---

## The `@immutable` annotation approach vs this preset

Dart's `meta` package provides an `@immutable` annotation:

```dart
import 'package:meta/meta.dart';

@immutable
class CartState {
  final List<CartItem> items;  // analyzer warns if this is not final
  CartState(this.items);
}
```

When a class is annotated with `@immutable`, the Dart analyzer emits a warning if any instance field is not `final`. This is the "official" Dart approach to enforcing immutability.

The differences between `@immutable` and `mustBeImmutable`:

| Aspect | `@immutable` annotation | `mustBeImmutable` |
|---|---|---|
| Requires developer action | Yes — must add annotation to every class | No — rule applies to all classes in the folder |
| Scope | Per class | Per folder (all classes) |
| Enforcement | Analyzer warning (not always CI-blocking) | DartUnit severity (can be `error`, blocks CI) |
| Coverage | Only annotated classes | Every class in the folder, no exceptions unless listed |
| Visibility | In source code | In architecture test reports |

The two approaches are complementary, not mutually exclusive. You can use `mustBeImmutable` to catch any class in a state folder that forgot the `@immutable` annotation, while `@immutable` provides inline documentation of intent.

---

## Function signature

```dart
void mustBeImmutable({
  required List<String> folders,
  RuleSeverity severity = RuleSeverity.error,
  List<String> exceptions = const [],
})
```

## Parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `folders` | `List<String>` | required | Folders where all instance fields must be `final` or `const`. |
| `severity` | `RuleSeverity` | `RuleSeverity.error` | Violation severity. Defaults to `error` because a mutable field in a state class is a behavioral bug, not a style issue. |
| `exceptions` | `List<String>` | `const []` | Exact class names exempt from the immutability requirement. |

---

## Examples

### Example 1 — BLoC states must be immutable

The most common application. All state classes must have final fields:

```dart title="test_arch/bloc_immutability_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() => mustBeImmutable(
    folders: ['lib/bloc/states'],
    severity: RuleSeverity.error,
  ),
);
```

If your project puts states alongside blocs and events in a flat folder:

```dart title="test_arch/bloc_folder_immutability_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() => mustBeImmutable(
    folders: ['lib/bloc'],
    severity: RuleSeverity.error,
    exceptions: [
      'AppBloc',        // the root bloc has a stateful logger field
      'NavigationBloc', // navigation requires mutable history stack
    ],
  ),
);
```

### Example 2 — Domain entities and value objects

Domain entities and value objects represent core business concepts. Their identity and equality semantics depend on value, not reference — which presupposes immutability:

```dart title="test_arch/domain_immutability_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() => mustBeImmutable(
    folders: [
      'lib/domain/entities',
      'lib/domain/value_objects',
    ],
    severity: RuleSeverity.error,
    exceptions: [
      'AggregateRoot',   // aggregate root tracks domain events in a mutable list
    ],
  ),
);
```

Value objects — `Money`, `Email`, `PhoneNumber`, `DateRange` — must be immutable by definition. Two `Money` instances with the same currency and amount are equal; mutating one would corrupt the equality semantics.

### Example 3 — API response models

Network response models are deserialized once and then read. They should never be mutated:

```dart title="test_arch/model_immutability_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() => mustBeImmutable(
    folders: ['lib/data/models'],
    severity: RuleSeverity.warning,
  ),
);
```

Using `RuleSeverity.warning` here is intentional: some teams allow mutable models for JSON serialization compatibility (some serialization libraries require mutable fields). A warning surfaces the issue without blocking CI.

### Example 4 — Combined: multiple model folders

A feature-first project with per-feature model folders:

```dart title="test_arch/all_models_immutability_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() => mustBeImmutable(
    folders: [
      'lib/features/cart/models',
      'lib/features/product/models',
      'lib/features/checkout/models',
      'lib/features/user/models',
      'lib/shared/models',
    ],
    severity: RuleSeverity.error,
    exceptions: [
      'FormState',      // form state is intentionally mutable during editing
      'DraftOrder',     // draft order accumulates items before submission
    ],
  ),
);
```

---

## How to pair with `HasAllFinalFieldsPredicate` for custom rules

If you need to write a custom rule — for example, immutability only for classes that also implement `Equatable`, or only for classes annotated with `@immutable` — you can build on the underlying predicate that `mustBeImmutable` uses internally.

Dartunit exposes predicates as building blocks for custom `ArchitectureRule` objects:

```dart title="test_arch/custom_equatable_immutability_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) {
  // Custom rule: classes that extend Equatable must have all-final fields
  final rule = ArchitectureRule(
    name: 'Equatable classes must be immutable',
    predicate: HasAllFinalFieldsPredicate(),
    selector: ClassesInFolderSelector('lib/domain')
      .and(ImplementsClassSelector('Equatable')),
    severity: RuleSeverity.error,
  );

  rule);
}
```

The `HasAllFinalFieldsPredicate` is the same predicate used internally by `mustBeImmutable`. Using it directly in a custom rule gives you full control over which classes are selected and how violations are reported.

---

## Violation output

When a class in a controlled folder has a non-final instance field, DartUnit reports:

```
ERROR | All instance fields in lib/bloc/states must be final or const
      | lib/bloc/states/cart_state.dart:5
      | Class "CartState" has mutable field "items" (List<CartItem>)

ERROR | All instance fields in lib/bloc/states must be final or const
      | lib/bloc/states/cart_state.dart:6
      | Class "CartState" has mutable field "totalPrice" (double)
```

Each mutable field is reported as a separate violation, so you can see all mutable fields in a class at a glance. The report includes:
- The severity level
- The rule description and folder
- The file path and line number (pointing to the field declaration)
- The class name, the field name, and the field type

---

## Common gotchas

### Static fields are not checked

`mustBeImmutable` only checks instance fields. `static` fields are excluded from the check because static fields are class-level, not instance-level, and are commonly mutable by design (caches, registries, lazy singletons).

```dart
class CartState {
  static int instanceCount = 0;  // static, not checked — mutable by design
  final List<CartItem> items;    // instance field, checked
  CartState(this.items) { instanceCount++; }
}
```

### `late final` fields

A `late final` field is mutable in the sense that it can be assigned once after declaration, but it is `final` — it can only be assigned once, and then it is immutable. DartUnit treats `late final` as satisfying the immutability requirement because the field is declared `final`.

### Computed properties are not fields

Dart getter methods (`get totalPrice => ...`) are not fields. They are not subject to the immutability rule. Only declared fields (`Type name;` or `Type name = value;`) are checked.

### Constructor parameters vs fields

The immutability rule checks field declarations, not constructor parameters. A constructor parameter without a corresponding `final` field declaration does not satisfy the requirement:

```dart
class CartState {
  List<CartItem> items;                    // field: NOT final — violation

  CartState({required final this.items}); // the `final` here is on the parameter,
                                           // not the field — still a violation
}
```

The field declaration must include `final`:

```dart
class CartState {
  final List<CartItem> items;              // field: final — valid

  CartState({required this.items});
}
```

---

## Related presets

- [`mustBeAbstract`](/presets/must-be-abstract/) — structural constraint for interface folders; pair with this preset for full domain layer enforcement
- [`namingFolderSuffix`](/presets/naming-folder-suffix/) — combine with this preset to ensure state classes are both named correctly and immutable
