---
title: annotationMustHavePreset
description: Enforce that every class in specified folders carries a required annotation. Prevent missing @injectable, @immutable, @freezed, or custom annotations at CI time.
sidebar:
  order: 13
---

`annotationMustHavePreset` enforces that every class in specified folders carries a particular annotation. It is a completeness check — it ensures no class silently misses a required annotation when it was supposed to have one. Common use cases include enforcing `@injectable` for dependency injection, `@immutable` for state and value objects, `@freezed` for generated sealed classes, and custom project-defined annotations for compliance tracking.

## Why Annotation Enforcement Matters

Annotations in Dart serve as machine-readable metadata that frameworks and tools act upon. When an annotation is missing, the framework silently skips the class, producing runtime failures instead of compile-time errors. `annotationMustHavePreset` converts these silent runtime failures into loud CI failures.

### The Dependency Injection Scenario

The most impactful use case is dependency injection (DI). Teams using `injectable` with `get_it` write classes like:

```dart
@injectable
class UserRepository implements IUserRepository {
  final ApiClient _apiClient;
  final LocalDatabase _db;

  UserRepository(this._apiClient, this._db);
}
```

The `@injectable` annotation triggers code generation. `build_runner` reads the annotation and generates registration code in `injection.config.dart`. When the app starts and calls `configureDependencies()`, `UserRepository` is registered with the DI container.

Now imagine a team of six developers adding new classes regularly. A developer creates a new `OrderService`:

```dart
// Forgot @injectable — happens more often than you'd think
class OrderService {
  final IOrderRepository _orderRepository;
  final IPaymentGateway _paymentGateway;

  OrderService(this._orderRepository, this._paymentGateway);
}
```

The code compiles. `build_runner` runs but doesn't generate registration for `OrderService` — there's no annotation to trigger it. Every other class in the app works fine. The problem only surfaces at runtime when another class tries to inject `OrderService`:

```
Unhandled Exception: StateError: Expected a value of type 'OrderService',
but got one of type 'Null'
```

This error appears in testing, staging, or — in the worst case — production. Finding its root cause requires understanding the DI container's resolution order. `annotationMustHavePreset` turns this into a build failure:

```
VIOLATION [error] annotationMustHavePreset[@injectable]
  File: lib/services/order_service.dart
  Class: OrderService
  Missing annotation: @injectable
  Reason: All classes in lib/services/ must carry @injectable
          to ensure they are registered with the DI container.
```

This is caught at CI time, before the code is ever deployed.

### The `@immutable` Pattern in Flutter

Flutter's BLoC pattern relies on immutable state. A `Bloc<Event, State>` emits new state objects rather than mutating existing ones. The `@immutable` annotation (from `package:meta/meta.dart`) signals this intent and enables static analysis tools to warn when a supposedly immutable class contains non-final fields.

```dart
@immutable
abstract class AuthState {
  const AuthState();
}

@immutable
class AuthAuthenticated extends AuthState {
  final User user;
  const AuthAuthenticated(this.user);
}

@immutable
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}
```

If a developer adds a new state class and forgets `@immutable`:

```dart
// Missing @immutable — static analysis won't catch this alone
class AuthLoading extends AuthState {
  const AuthLoading();
}
```

The code works fine in most cases. But if someone later adds a non-final field to `AuthLoading`, there is no warning that it violates the immutability contract the rest of the state hierarchy follows. `annotationMustHavePreset` ensures that `@immutable` is consistently present on all state classes, maintaining a uniform signal to both developers and tools.

### Preventing Silent Registration Failures Over Time

In any codebase that grows over time, "remember to add annotation X to every class in folder Y" is a convention that breaks down. Developers work under time pressure, conventions are not in code, and new team members don't know the rules. The combination of `annotationMustHavePreset` and CI enforcement means:

1. The rule is stated explicitly in the `arch_test/` directory (which is committed code).
2. Any PR that violates the rule fails CI automatically.
3. New team members learn the rule when they encounter a CI failure — with a clear, actionable message.

The annotation requirement becomes part of the codebase's definition of correctness, not merely a social convention.

## How DartUnit Checks Annotations

DartUnit checks annotations by name, without the `@` symbol. The check is case-sensitive and matches the annotation class name exactly.

- `annotation: 'injectable'` matches `@injectable` — it does NOT match `@Injectable` or `@INJECTABLE`.
- `annotation: 'immutable'` matches `@immutable` from `package:meta/meta.dart`.
- `annotation: 'freezed'` matches `@freezed` from `package:freezed_annotation/freezed_annotation.dart`.
- `annotation: 'JsonSerializable'` matches `@JsonSerializable` — capital J, capital S.

DartUnit checks the annotation declarations on the class itself, not on parent classes. If `@injectable` is required but only the parent class has it, the subclass will still be flagged.

For annotations with parameters (like `@JsonSerializable(explicitToJson: true)`), DartUnit matches only on the annotation name — parameters are not checked.

## Function Signature

```dart
ArchitectureRule annotationMustHavePreset({
  required List<String> folders,
  required String annotation,
  Severity severity = Severity.error,
  List<String> exceptions = const [],
})
```

## Parameters

### `folders`

**Type:** `List<String>` — required

The folders where every class must carry the specified annotation. All Dart files in these folders (and subdirectories) are checked. Any class lacking the annotation produces a violation.

```dart
folders: ['lib/services', 'lib/repositories'],
```

Specify folders precisely to avoid false positives. If `@injectable` is only required for service-layer classes, do not apply the rule to the entire `lib/` directory.

### `annotation`

**Type:** `String` — required

The annotation name to require, without the `@` prefix. Case-sensitive.

```dart
annotation: 'injectable',      // Requires @injectable
annotation: 'immutable',       // Requires @immutable
annotation: 'freezed',         // Requires @freezed
annotation: 'JsonSerializable', // Requires @JsonSerializable
annotation: 'reviewed',        // Requires @reviewed (custom annotation)
```

### `severity`

**Type:** `Severity` — default `Severity.error`

For annotation completeness checks in DI and immutability contexts, `Severity.error` is appropriate. A missing `@injectable` is a functional bug. A missing `@immutable` is a contract violation.

Use `Severity.warning` when introducing the rule to an existing codebase that has existing violations you haven't had time to fix yet.

### `exceptions`

**Type:** `List<String>` — default `[]`

Class names to exclude from the annotation requirement. Use this for:

- Abstract base classes that intentionally do not have the annotation (subclasses must have it)
- Mixin classes that are not registered independently
- Generated code base classes

```dart
exceptions: [
  'BaseRepository',     // Abstract — not registered directly
  'RepositoryMixin',    // Mixin — not instantiated directly
],
```

## Usage

```dart
// arch_test/injectable_check.dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(
  args,
  annotationMustHavePreset(
    folders: ['lib/services', 'lib/repositories'],
    annotation: 'injectable',
    severity: Severity.error,
  ),
);
```

Run:

```
dart run dartunit analyze
```

## Examples

### Example 1: All Classes in Injectable Folders Must Have `@injectable`

The primary DI enforcement use case. Every class in the registered DI folders must have `@injectable` (or `@lazySingleton`, `@singleton`, etc. — note that each variant is a distinct annotation, so you would need separate rules for each, or use `@injectable` as your team's standard).

```dart
// arch_test/di_completeness.dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(
  args,
  annotationMustHavePreset(
    folders: [
      'lib/services',
      'lib/repositories',
      'lib/use_cases',
      'lib/data_sources',
    ],
    annotation: 'injectable',
    severity: Severity.error,
    exceptions: [
      // Abstract interfaces — not registered directly
      'IUserRepository',
      'IOrderService',
      'INotificationService',
      'BaseUseCase',           // Abstract base — subclasses must have @injectable
    ],
  ),
);
```

This ensures that every concrete class in these folders is explicitly opted into DI registration. If a new developer creates a service class and forgets `@injectable`, the CI check fails with:

```
VIOLATION [error] annotationMustHavePreset[@injectable]
  File: lib/services/recommendation_service.dart
  Class: RecommendationService
  Missing annotation: @injectable
  All classes in lib/services must carry @injectable to be registered
  with the dependency injection container.
```

### Example 2: All BLoC States Must Have `@immutable`

BLoC states represent snapshots of application state. They must be immutable — the BLoC emits new instances rather than mutating existing ones. Enforcing `@immutable` on all state classes provides a clear signal to developers and enables static analysis to catch accidental mutations.

```dart
// arch_test/bloc_state_immutability.dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(
  args,
  annotationMustHavePreset(
    folders: ['lib/blocs/states', 'lib/cubits/states'],
    annotation: 'immutable',
    severity: Severity.error,
    exceptions: [
      // Abstract sealed base states are immutable by convention
      // but may not have the annotation explicitly if all subclasses do
    ],
  ),
);
```

To extend this to all BLoC-related files (states, events, and the BLoC itself), use multiple rule files or a combined folders list:

```dart
// arch_test/bloc_immutability.dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(
  args,
  annotationMustHavePreset(
    // States AND events should be immutable
    folders: [
      'lib/blocs/states',
      'lib/blocs/events',
    ],
    annotation: 'immutable',
    severity: Severity.error,
  ),
);
```

A violation example:

```
VIOLATION [error] annotationMustHavePreset[@immutable]
  File: lib/blocs/states/payment_state.dart
  Class: PaymentProcessing
  Missing annotation: @immutable
  All state classes in lib/blocs/states must carry @immutable.
  States represent snapshots and must not be mutated after emission.
```

### Example 3: All Value Objects Must Have `@sealed`

Value objects in domain-driven design represent concepts without identity — money amounts, addresses, email addresses, phone numbers. They should be final (no subclassing), value-equal (equality by content, not reference), and immutable. The `@sealed` annotation prevents subclassing.

```dart
// arch_test/value_object_sealed.dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(
  args,
  annotationMustHavePreset(
    folders: ['lib/domain/value_objects'],
    annotation: 'sealed',
    severity: Severity.error,
    exceptions: [
      'ValueObject', // Abstract base class — not sealed itself, subclasses must be
    ],
  ),
);
```

This catches:

```dart
// VIOLATION: Missing @sealed on value object
class EmailAddress {
  final String value;

  EmailAddress(String raw) : value = _validate(raw);

  static String _validate(String email) {
    if (!email.contains('@')) throw ArgumentError('Invalid email');
    return email.toLowerCase();
  }
}
```

The fix:

```dart
// COMPLIANT: @sealed prevents subclassing
@sealed
class EmailAddress {
  final String value;

  EmailAddress(String raw) : value = _validate(raw);

  static String _validate(String email) {
    if (!email.contains('@')) throw ArgumentError('Invalid email');
    return email.toLowerCase();
  }
}
```

### Example 4: Custom `@reviewed` Annotation for Compliance

In regulated industries (healthcare, finance, legal tech), teams sometimes need to track which classes have been reviewed for compliance, security, or legal requirements. A custom annotation can serve as this marker, and `annotationMustHavePreset` enforces that no new class is deployed without a review.

First, define the annotation in your project:

```dart
// lib/core/annotations/reviewed.dart
class reviewed {
  final String reviewer;
  final String date;
  final String ticket;

  const reviewed({
    required this.reviewer,
    required this.date,
    required this.ticket,
  });
}
```

Then enforce it:

```dart
// arch_test/compliance_review.dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(
  args,
  annotationMustHavePreset(
    folders: [
      'lib/features/payment',   // Payment processing — requires review
      'lib/features/health',    // Health data — requires HIPAA review
      'lib/features/auth',      // Authentication — requires security review
    ],
    annotation: 'reviewed',
    severity: Severity.error,
  ),
);
```

Usage in code:

```dart
// COMPLIANT: reviewed annotation present
@reviewed(
  reviewer: 'alice@company.com',
  date: '2026-01-15',
  ticket: 'COMPLIANCE-847',
)
class PaymentProcessor {
  ...
}
```

A new class without `@reviewed` in these folders fails CI:

```
VIOLATION [error] annotationMustHavePreset[@reviewed]
  File: lib/features/payment/refund_service.dart
  Class: RefundService
  Missing annotation: @reviewed
  All classes in lib/features/payment must carry @reviewed.
  Submit a compliance review ticket and add the annotation before merging.
```

This makes compliance review a hard requirement rather than a post-deployment process.

## Pairing With `annotationMustNotHavePreset`

`annotationMustHavePreset` and `annotationMustNotHavePreset` address opposite concerns:

- **Must-have = completeness.** Every class in a folder must carry annotation X. Use this to ensure nothing is accidentally skipped (DI registration, immutability marking, compliance review).
- **Must-not-have = boundary enforcement.** No class in a folder may carry annotation Y. Use this to prevent annotation-implied dependencies from leaking into the wrong layer (see [`annotationMustNotHavePreset`](/presets/annotation-must-not-have)).

Combining both on the same folder creates precise annotation policies:

```dart
// arch_test/domain_state_annotations.dart
import 'package:dartunit/dartunit.dart';

// BLoC states must be @immutable and must NOT be @JsonSerializable
void main(List<String> args) {
  // Requirement: must have @immutable
  archTest(args, annotationMustHavePreset(
    folders: ['lib/blocs/states'],
    annotation: 'immutable',
    severity: Severity.error,
  ));

  // Boundary: must NOT have @JsonSerializable
  archTest(args, annotationMustNotHavePreset(
    folders: ['lib/blocs/states'],
    annotation: 'JsonSerializable',
    severity: Severity.error,
  ));
}
```

This establishes that BLoC state classes are always immutable and are never serialized directly to JSON (serialization is handled by DTO mappers in the data layer, not by the states themselves).

## Using Multiple `annotationMustHavePreset` Calls

You can combine multiple annotation requirements for the same folder in a single rule file by calling `archTest` multiple times:

```dart
// arch_test/domain_entity_annotations.dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) {
  // Domain entities must be immutable
  archTest(args, annotationMustHavePreset(
    folders: ['lib/domain/entities'],
    annotation: 'immutable',
    severity: Severity.error,
  ));

  // Domain entities must be sealed (no subclassing outside domain)
  archTest(args, annotationMustHavePreset(
    folders: ['lib/domain/entities'],
    annotation: 'sealed',
    severity: Severity.error,
    exceptions: [
      'Entity',       // Abstract base class
      'AggregateRoot', // Abstract aggregate root
    ],
  ));
}
```

## Violation Message Format

When a class in a targeted folder lacks the required annotation:

```
VIOLATION [error] annotationMustHavePreset[@injectable]
  File: lib/repositories/product_repository.dart
  Class: ProductRepository
  Missing annotation: @injectable
  Required by: All classes in lib/repositories must carry @injectable.
```

The message includes the file, the class name, the missing annotation, and the rule description, giving developers all the information they need to fix the issue immediately.

## Related Presets

- [`annotationMustNotHavePreset`](/presets/annotation-must-not-have) — Enforce that classes do NOT carry certain annotations (boundary enforcement)
- [`noPublicFieldsPreset`](/presets/no-public-fields) — Enforce encapsulation rules that complement `@immutable` requirements
- [`noExternalPackagePreset`](/presets/no-external-package) — Prevent annotation-implied dependencies from leaking into wrong layers
