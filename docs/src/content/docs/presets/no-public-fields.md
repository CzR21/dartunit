---
title: noPublicFields
description: Enforce that classes expose no public instance fields. Protects encapsulation and ensures state changes go through controlled access points.
sidebar:
  order: 10
---

`noPublicFields` enforces that classes in the specified folders declare no public instance fields. All state must be accessed through methods, getters, or setters, preserving the class's ability to enforce its own invariants, emit change notifications, and control mutation.

## What is Encapsulation and Why Does It Matter?

Encapsulation is the principle that an object controls access to its own state. When a field is public, any code in the codebase can read and modify it freely — bypassing the class entirely. The class loses the ability to:

- **Enforce invariants.** A `ShoppingCart` class might need to ensure `total` is always equal to the sum of item prices. If `total` is a public field, any caller can set it to an arbitrary value without updating the item list. The class cannot protect this relationship.
- **Emit change notifications.** Flutter's `ChangeNotifier`, BLoC streams, and reactive state management all work by having the class signal when its state changes. If a field is public, external code can modify it directly without triggering any notification. The UI will not update.
- **Validate values.** A `UserProfile` might need to ensure that `username` is never empty and never contains special characters. A public field bypasses any validation. A setter can enforce both constraints before the assignment completes.
- **Track mutations for debugging or auditing.** If a field is public, any of thousands of callsites could have modified it. When a bug produces unexpected state, you cannot narrow down the source. A private field with a controlled setter can log every write, helping diagnose where the unexpected value came from.
- **Change the internal representation.** A class with a public `List<Item> items` field commits to using a `List` forever. If you later want to use a `LinkedHashSet` for O(1) deduplication, every callsite that called `.add()` or `.length` breaks. A private field with a controlled getter can change its internal type without affecting callers.

## The Data Bag Anti-Pattern

A class with only public fields is not an object — it is a data bag. A data bag has no behavior, no invariants, no encapsulation. It is merely a named struct. This is sometimes appropriate (pure data transfer objects, JSON response models), but it becomes a liability when the class is supposed to encapsulate behavior.

The distinction is:

```dart
// Data bag — acceptable for pure data transfer
class UserDto {
  String id;
  String name;
  String email;
}

// Service class — should NOT have public fields
class UserRepository {
  // BAD: external code can replace the cache without UserRepository knowing
  Map<String, User> cache = {};

  // BAD: external code can replace the HTTP client, bypassing DI
  http.Client httpClient = http.Client();
}
```

The `UserRepository` example is the problematic case. With public fields, external code can do:

```dart
userRepository.cache = {}; // Clears the cache silently
userRepository.httpClient = brokenClient; // Injects unexpected behavior
```

Neither operation goes through `UserRepository`'s logic. It has no opportunity to respond, validate, or notify.

## A Concrete Flutter Example

Consider a `CartService` class in a Flutter app:

```dart
// BEFORE: public field — broken reactivity
class CartService extends ChangeNotifier {
  List<Item> items = [];  // Public field

  double get total => items.fold(0, (sum, item) => sum + item.price);
}
```

A developer on the team writes:

```dart
cartService.items.add(newItem); // Direct mutation
```

This adds the item to the list but never calls `notifyListeners()`. The `CartService` has no idea the list was modified. Every widget listening to this `ChangeNotifier` never rebuilds. The cart appears empty to the user. The developer spends hours debugging a UI issue that is actually an encapsulation violation.

The fix is straightforward:

```dart
// AFTER: private field with controlled access
class CartService extends ChangeNotifier {
  final List<Item> _items = [];

  // Read-only view of the list
  List<Item> get items => List.unmodifiable(_items);

  void addItem(Item item) {
    _items.add(item);
    notifyListeners(); // Always called — impossible to forget
  }

  void removeItem(String itemId) {
    _items.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }
}
```

Now the notification is part of the mutation logic. It cannot be skipped. `noPublicFields` would have caught the original version before it reached code review.

## Public Fields vs. Public Getters

A common misunderstanding is that "no public fields" means "no public access to state." This is not the case. The rule targets direct field declarations, not computed properties.

```dart
// VIOLATION: public field
class OrderSummary {
  double taxRate = 0.08;  // Public field — anyone can set this
}

// COMPLIANT: public getter backed by private field
class OrderSummary {
  double _taxRate = 0.08;  // Private — controlled

  double get taxRate => _taxRate;  // Read-only public access

  set taxRate(double rate) {
    if (rate < 0 || rate > 1) throw ArgumentError('Invalid tax rate');
    _taxRate = rate;
  }
}
```

The getter and setter approach gives you:
- Validation logic in the setter
- The ability to compute the value lazily
- The ability to change the internal representation without breaking callers
- The ability to add logging, notifications, or side effects to reads or writes

## When This Rule Applies (and When It Doesn't)

`noPublicFields` is most important for classes that encapsulate behavior:

- **Services** — business logic, application use cases
- **BLoC / Cubit classes** — state management with event handling
- **Repositories** — data access coordination
- **Use cases / interactors** — single-purpose application logic
- **Domain entities with behavior** — value objects, aggregates with business rules

It is less critical (and may generate false positives) for:

- **Pure data transfer objects (DTOs)** — classes whose sole purpose is to carry data between layers. These are often better as immutable classes with all-`final` fields.
- **Database model classes** — some ORMs require public mutable fields for their reflection-based mapping.
- **Generated code** — `freezed`, `json_serializable`, and similar tools generate code that may not follow this pattern.
- **Test fixture classes** — test helpers sometimes use public fields for convenience.

The `folders` parameter allows you to target only the layers where encapsulation is critical.

## `final` Fields in Immutable Classes

An important nuance: `final` fields on immutable value objects are explicitly different from mutable public fields. A `final` field is set once at construction and never changed — this is the correct pattern for immutable data.

```dart
// Immutable value object — final fields are correct here
@immutable
class Money {
  final double amount;
  final String currency;

  const Money(this.amount, this.currency);

  Money operator +(Money other) {
    if (currency != other.currency) throw ArgumentError('Currency mismatch');
    return Money(amount + other.amount, currency);
  }
}
```

DartUnit's `noPublicFields` targets non-final public fields by default — the kind that represent mutable state that can be modified by external code. Pure `final` fields on immutable classes are not flagged.

## Function Signature

```dart
void noPublicFields({
  List<String> folders = const [],
  Severity severity = Severity.error,
  List<String> exceptions = const [],
})
```

## Parameters

### `folders`

**Type:** `List<String>` — default `[]`

The folders to apply this rule to. When empty, the rule applies globally to every Dart class. In most projects, you will want to target specific layers rather than the entire codebase, because models and DTOs legitimately use public fields.

```dart
noPublicFields(
  folders: ['lib/application', 'lib/services', 'lib/blocs'],
)
```

Subdirectories are included automatically. Specifying `'lib/features'` will check all files under `lib/features/auth/`, `lib/features/cart/`, etc.

### `severity`

**Type:** `Severity` — default `Severity.error`

Controls whether violations block CI (`Severity.error`) or only produce warnings (`Severity.warning`, `Severity.info`).

For encapsulation violations in service and BLoC classes, `Severity.error` is recommended. These violations represent design flaws that will cause bugs — reactivity failures, invalid state, impossible-to-debug mutations.

### `exceptions`

**Type:** `List<String>` — default `[]`

Class names excluded from the rule. Use this sparingly — typically only for generated classes or framework base classes you do not control.

```dart
noPublicFields(
  folders: ['lib/services'],
  exceptions: ['GeneratedTokenStorage', 'LegacySessionManager'],
)
```

## Usage

```dart
// test_arch/no_public_fields.dart
import 'package:dartunit/dartunit.dart';

void main() => noPublicFields(
    folders: ['lib/services', 'lib/blocs', 'lib/repositories'],
  ),
);
```

Run:

```
dart run dartunit analyze
```

## Examples

### Example 1: BLoC and Cubit Classes

BLoC and Cubit classes are the most critical targets for this rule. A BLoC with public fields defeats its entire purpose — the BLoC pattern exists to make state changes explicit and traceable. A public field bypasses both the event system and the state stream.

```dart
// test_arch/bloc_encapsulation.dart
import 'package:dartunit/dartunit.dart';

void main() => noPublicFields(
    folders: [
      'lib/blocs',
      'lib/cubits',
      'lib/features', // Feature-based BLoCs
    ],
    severity: Severity.error,
  ),
);
```

This catches patterns like:

```dart
// VIOLATION: public field in BLoC class
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  bool isAuthenticated = false;   // Mutable public field — VIOLATION
  String? currentUserId;          // Mutable public field — VIOLATION

  AuthBloc() : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
  }
}
```

The fields should be part of the immutable `AuthState`, not floating public fields on the BLoC itself.

### Example 2: Services and Repositories

Services and repositories coordinate business and data logic. Public fields on these classes expose implementation details that callers should never touch directly.

```dart
// test_arch/service_encapsulation.dart
import 'package:dartunit/dartunit.dart';

void main() => noPublicFields(
    folders: [
      'lib/services',
      'lib/repositories',
      'lib/data/remote',
      'lib/data/local',
    ],
    severity: Severity.error,
  ),
);
```

Sample violations this catches:

```dart
// VIOLATION: public fields in service class
class NotificationService {
  bool notificationsEnabled = true;  // VIOLATION — callers bypass enable/disable logic
  List<String> pendingNotifications = [];  // VIOLATION — callers bypass queue management

  void sendNotification(String message) {
    if (notificationsEnabled) {
      pendingNotifications.add(message);
      _processPending();
    }
  }
}
```

If a caller sets `notificationsEnabled = false` directly, the `sendNotification` method's internal logic that might persist the preference to disk or log the change will never run.

### Example 3: Domain Entities

Domain entities in a Clean Architecture project encapsulate business rules. If their fields are public, the business rules can be circumvented.

```dart
// test_arch/domain_encapsulation.dart
import 'package:dartunit/dartunit.dart';

void main() => noPublicFields(
    folders: ['lib/domain/entities', 'lib/domain/value_objects'],
    severity: Severity.error,
  ),
);
```

A domain entity like `Order` should protect its state transitions:

```dart
// VIOLATION: public field on domain entity
class Order {
  OrderStatus status = OrderStatus.pending;  // VIOLATION — anyone can set this
  List<OrderItem> lineItems = [];            // VIOLATION — anyone can mutate this

  void confirm() {
    if (status != OrderStatus.pending) {
      throw StateError('Only pending orders can be confirmed');
    }
    status = OrderStatus.confirmed; // This guard can be bypassed!
  }
}
```

With public `status`, a caller can do `order.status = OrderStatus.confirmed` without going through the `confirm()` method, completely bypassing the state transition guard.

### Example 4: Excluding DTO and Data Model Folders

Data Transfer Objects and JSON response models legitimately use public fields because they are pure data containers passed between layers. Exclude these from the rule:

```dart
// test_arch/service_encapsulation.dart
import 'package:dartunit/dartunit.dart';

// Apply to all of lib/ EXCEPT data transfer and generated code
void main() => noPublicFields(
    // Target only the layers where encapsulation matters
    folders: [
      'lib/application',
      'lib/domain',
      'lib/blocs',
      'lib/services',
    ],
    // NOT targeting: lib/models, lib/dtos, lib/generated
    severity: Severity.error,
  ),
);
```

An alternative approach is to apply the rule globally and use `exceptions` for specific model classes:

```dart
// test_arch/global_encapsulation.dart
import 'package:dartunit/dartunit.dart';

void main() => noPublicFields(
    folders: [], // Global
    exceptions: [
      'UserDto',
      'ProductResponse',
      'CartItemModel',
      // ... other known data models
    ],
    severity: Severity.error,
  ),
);
```

The folder-based approach scales better as the project grows — you don't need to manually list every data model class.

## Violation Message Format

When a class has public instance fields in a targeted folder, DartUnit reports:

```
VIOLATION [error] noPublicFields
  File: lib/services/cart_service.dart
  Class: CartService
  Public fields found: items, discountCode, lastUpdated
  Recommendation: Make fields private and expose through getters/setters or methods.
```

Each field name is listed, making it easy to locate and fix each one.

## Pairing With `mustBeImmutable`

The `noPublicFields` and `mustBeImmutable` work together to cover two complementary patterns:

- **For service/logic classes:** `noPublicFields` ensures that all mutable state is accessed through controlled interfaces. These classes have private mutable fields and controlled access methods.

- **For value objects and state classes:** `mustBeImmutable` (or the `@immutable` annotation rule) ensures that data classes are fully immutable — all fields are `final`, and mutation produces a new instance via `copyWith`. These classes can have public `final` fields because `final` fields cannot be externally reassigned.

Together, they establish a clear pattern in the codebase:

```
Service/logic classes → private fields + methods/getters (noPublicFields)
Value objects/states → all-final fields + copyWith (mustBeImmutable)
```

This leaves no ambiguous middle ground where mutable public fields accumulate.

```dart
// test_arch/encapsulation.dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) {
  noPublicFields(
    folders: ['lib/services', 'lib/blocs', 'lib/repositories'],
    severity: Severity.error,
  ));
}
```

```dart
// test_arch/immutability.dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) {
  annotationMustHave(
    folders: ['lib/domain/value_objects', 'lib/blocs/states'],
    annotation: 'immutable',
    severity: Severity.error,
  ));
}
```

## Common Refactoring Patterns

When `noPublicFields` flags a violation, the fix depends on the field's role:

**Mutable flag field → private field + method pair:**
```dart
// Before (VIOLATION)
bool isSyncing = false;

// After (compliant)
bool _isSyncing = false;
bool get isSyncing => _isSyncing;
void _setSyncing(bool value) { _isSyncing = value; }
```

**Mutable collection → private collection + controlled mutation methods:**
```dart
// Before (VIOLATION)
List<Notification> notifications = [];

// After (compliant)
final List<Notification> _notifications = [];
List<Notification> get notifications => List.unmodifiable(_notifications);
void addNotification(Notification n) { _notifications.add(n); notifyListeners(); }
void clearNotifications() { _notifications.clear(); notifyListeners(); }
```

**Configuration field → constructor parameter + private final field:**
```dart
// Before (VIOLATION)
Duration timeout = const Duration(seconds: 30);

// After (compliant)
final Duration _timeout;
Duration get timeout => _timeout;
MyService({Duration timeout = const Duration(seconds: 30)}) : _timeout = timeout;
```

## Related Presets

- [`classSizeLimit`](/presets/class-size-limit) — Prevent classes from growing large enough that their public interface becomes unmanageable
- [`annotationMustHave`](/presets/annotation-must-have) — Enforce `@immutable` on value objects to complement encapsulation in service classes
- [`layerDependencyPreset`](/presets/layer) — Ensure that services stay in the correct layer and are not accessed by layers that should not depend on them
