---
title: noExternalPackagePreset
description: Forbid folders from importing specified external packages. Keep your domain and business logic layer free from framework and infrastructure dependencies.
sidebar:
  order: 12
---

`noExternalPackagePreset` forbids classes in specified folders from importing specific external packages. It returns `List<ArchitectureRule>` — one rule per forbidden package. Use this to enforce the Dependency Rule from Clean Architecture: inner layers (domain, application) must not depend on outer layers (Flutter framework, HTTP clients, database packages, state management frameworks).

## The Domain Layer Purity Problem

In a well-structured Flutter application, the domain layer contains the most valuable code: the business rules that define what the application actually does. Whether you call it "domain," "core," or "business logic," this layer should represent pure Dart — logic that can be understood, tested, and modified without any knowledge of Flutter, HTTP, databases, or UI.

When domain code imports infrastructure packages, several problems emerge:

**Testing becomes expensive.** If `UserRepository` imports `package:flutter/foundation.dart` for `@immutable`, then running domain tests requires a Flutter test environment. What would otherwise be millisecond-level pure Dart tests now require `flutter test` to run, involve platform channels, and may require mocking Flutter's binding layer. A test suite that takes 50ms grows to 5 seconds.

**If `OrderService` imports `package:dio/dio.dart` directly, swapping from Dio to http or a custom client requires modifying domain code.** The domain layer should be insulated from infrastructure decisions. Its dependencies should be abstractions (interfaces), not concrete implementations.

**If `AuthBloc` imports `package:hive/hive.dart`, moving from Hive to Isar requires changing BLoC code.** In Clean Architecture, changing the database is an infrastructure concern — it should not require touching application or domain code at all.

**Plugin dependencies require platform setup.** If domain code imports `package:shared_preferences/shared_preferences.dart`, you cannot run domain tests without initializing platform bindings (`TestWidgetsFlutterBinding`). Every test file that indirectly uses the domain layer must now set up Flutter's test environment.

## The Clean Architecture Dependency Rule

Clean Architecture defines layers arranged in concentric circles. The fundamental rule is:

> Source code dependencies must point only inward — toward higher-level policies.

In practice for a Flutter application:

```
[ Presentation ] → [ Application ] → [ Domain ] → [ Core abstractions ]
      ↓                  ↓
[ Infrastructure / Data layer ]
```

- The **domain layer** (entities, value objects, repository interfaces, domain services) must not import anything from outer layers.
- The **application layer** (use cases, BLoC, services) may import domain, but must not import presentation or infrastructure.
- The **infrastructure layer** (repositories, data sources, HTTP clients, database adapters) implements domain interfaces and may import any package it needs.
- The **presentation layer** (widgets, screens, navigation) imports application layer and Flutter.

`noExternalPackagePreset` makes this rule machine-verifiable. Instead of relying on code reviews to catch a developer who accidentally imports `dio` in a domain service, DartUnit enforces it automatically.

## The Practical Benefit: Fast Domain Tests

When the domain layer is kept pure, its tests run with:

```
dart test test/domain/
```

Not:

```
flutter test test/domain/
```

The difference is significant:

- `dart test` starts in under a second and runs tests in an isolated Dart VM.
- `flutter test` must initialize the Flutter engine, may require platform binaries to be available, and takes several seconds to start.

In a CI pipeline that runs hundreds of test files, this difference compounds. A domain test suite that takes 2 seconds with `dart test` might take 30 seconds with `flutter test` — for the same logic.

Beyond speed, `dart test` domain tests can be run in environments without Flutter installed, on Dart-only CI containers, or on server-side Dart (for shared business logic between mobile and backend).

## Return Type: `List<ArchitectureRule>`

`noExternalPackagePreset` returns `List<ArchitectureRule>` — one rule per forbidden package. This allows DartUnit to report violations from each forbidden package as a distinct rule, making the output easier to read and process.

```dart
// arch_test/domain_packages.dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) {
  final rules = noExternalPackagePreset(
    folders: ['lib/domain'],
    packages: ['flutter', 'dio', 'hive'],
  );

  for (final rule in rules) {
    archTest(args, rule);
  }
}
```

Or using a helper:

```dart
// arch_test/domain_packages.dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) {
  archTestAll(args, noExternalPackagePreset(
    folders: ['lib/domain'],
    packages: ['flutter', 'dio', 'hive'],
  ));
}
```

## How Package Name Matching Works

The `packages` parameter takes a list of package name prefixes. A package name like `'flutter'` matches any import that starts with `package:flutter/`. For example:

- `'flutter'` matches `package:flutter/material.dart`, `package:flutter/widgets.dart`, `package:flutter/foundation.dart`, and all other `package:flutter/...` imports.
- `'dio'` matches `package:dio/dio.dart` and `package:dio/src/...`.
- `'hive'` matches `package:hive/hive.dart`.
- `'hive_flutter'` matches `package:hive_flutter/hive_flutter.dart` (note: `'hive'` does NOT match `'hive_flutter'` — matching is by prefix up to the `/`).

To ban both Hive and its Flutter adapter:

```dart
packages: ['hive', 'hive_flutter']
```

## Function Signature

```dart
List<ArchitectureRule> noExternalPackagePreset({
  required List<String> folders,
  required List<String> packages,
  Severity severity = Severity.error,
  List<String> exceptions = const [],
})
```

## Parameters

### `folders`

**Type:** `List<String>` — required

The folders where the import restriction applies. Typically the inner architectural layers: `lib/domain`, `lib/application`, `lib/core`.

Unlike most other presets where `folders` defaults to `[]` (global), `noExternalPackagePreset` requires folders to be specified explicitly. This avoids accidentally applying infrastructure restrictions to the infrastructure layer itself.

```dart
folders: ['lib/domain', 'lib/domain/entities', 'lib/domain/use_cases']
```

Subdirectories are included automatically. Specifying `'lib/domain'` covers all files recursively under that path.

### `packages`

**Type:** `List<String>` — required

A list of external package names to forbid. Each name is matched as a prefix against import statements. Only `package:` imports are checked — relative imports and `dart:` imports are not affected.

```dart
packages: ['flutter', 'dio', 'retrofit', 'hive', 'sqflite']
```

Specify as many packages as needed. Each package generates one `ArchitectureRule` in the returned list.

### `severity`

**Type:** `Severity` — default `Severity.error`

For dependency rule violations, `Severity.error` is strongly recommended. A domain class that imports Flutter is not merely a style issue — it fundamentally breaks the architectural guarantees the team is relying on. Make these violations blocking in CI.

### `exceptions`

**Type:** `List<String>` — default `[]`

File paths or class names to exclude from the package restriction. Use sparingly — if a file in the domain layer legitimately imports Flutter, that is usually a sign the file is misplaced, not that the rule needs an exception.

One legitimate use: a domain-level `@immutable` annotation import. If your domain value objects use `package:flutter/foundation.dart` solely for the `@immutable` annotation, and you cannot migrate to `package:meta/meta.dart` (which provides `@immutable` without Flutter), you may need to except those files.

However, note that `package:meta/meta.dart` provides `@immutable` and does not depend on Flutter. This is the correct solution — migrating from `package:flutter/foundation.dart` to `package:meta/meta.dart` for the annotation.

## Examples

### Example 1: Domain Must Not Import Flutter

The core constraint for Clean Architecture in Flutter. Domain code — entities, value objects, domain services, repository interfaces — must not depend on Flutter.

```dart
// arch_test/domain_no_flutter.dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) {
  final rules = noExternalPackagePreset(
    folders: ['lib/domain'],
    packages: ['flutter'],
    severity: Severity.error,
  );

  for (final rule in rules) {
    archTest(args, rule);
  }
}
```

This catches:

```dart
// VIOLATION: domain entity importing Flutter
import 'package:flutter/foundation.dart'; // @immutable is from flutter — violation

@immutable
class Money {
  final double amount;
  final String currency;
  const Money(this.amount, this.currency);
}
```

The fix: import `@immutable` from `package:meta/meta.dart` instead, which does not carry a Flutter dependency.

```dart
// COMPLIANT: using meta package instead
import 'package:meta/meta.dart'; // @immutable without Flutter dependency

@immutable
class Money {
  final double amount;
  final String currency;
  const Money(this.amount, this.currency);
}
```

### Example 2: Domain Must Not Import HTTP Packages

HTTP packages represent the infrastructure layer. Domain code that imports them is tightly coupled to the specific HTTP client implementation.

```dart
// arch_test/domain_no_http.dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) {
  final rules = noExternalPackagePreset(
    folders: ['lib/domain'],
    packages: [
      'dio',
      'http',
      'retrofit',
      'chopper',
    ],
    severity: Severity.error,
  );

  for (final rule in rules) {
    archTest(args, rule);
  }
}
```

Domain code should depend on abstract interfaces:

```dart
// COMPLIANT: domain depends on an abstract interface
abstract class IUserRepository {
  Future<User> findById(String id);
  Future<void> save(User user);
}

// NOT compliant: domain depends on a concrete HTTP implementation
// VIOLATION
import 'package:dio/dio.dart';

class UserRepository {
  final Dio _dio;  // Domain code importing Dio — architectural violation
  ...
}
```

The `UserRepository` implementation belongs in `lib/infrastructure` or `lib/data`, where it can freely import Dio.

### Example 3: Use Case Layer Must Not Import Database Packages

Use cases (application layer) orchestrate domain operations. They should not know about the specific database used to persist data — that is an infrastructure concern.

```dart
// arch_test/application_no_db.dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) {
  final rules = noExternalPackagePreset(
    folders: ['lib/application', 'lib/use_cases'],
    packages: [
      'sqflite',
      'drift',
      'hive',
      'hive_flutter',
      'isar',
      'objectbox',
      'sembast',
    ],
    severity: Severity.error,
  );

  for (final rule in rules) {
    archTest(args, rule);
  }
}
```

A use case that imports Drift (a local database package) is tied to that database. Migrating to Isar requires rewriting the use case, which should only concern orchestration logic, not storage implementation.

### Example 4: Models Must Not Import State Management Packages

Data models represent data structures. They should not depend on state management packages — that would mean a model class knows how it is managed in the application, coupling data structure to application architecture.

```dart
// arch_test/models_no_state_management.dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) {
  final rules = noExternalPackagePreset(
    folders: ['lib/domain/models', 'lib/data/models'],
    packages: [
      'flutter_bloc',
      'bloc',
      'provider',
      'riverpod',
      'flutter_riverpod',
      'get',
      'mobx',
      'redux',
    ],
    severity: Severity.error,
  );

  for (final rule in rules) {
    archTest(args, rule);
  }
}
```

A model class that imports `flutter_bloc` or `provider` is no longer a pure data structure — it has taken on concerns about how it is observed in the UI layer.

### Example 5: Combined Domain Restrictions — Multiple Packages at Once

In practice, you want to enforce all domain isolation rules in a single, comprehensive rule file. Combine all forbidden packages:

```dart
// arch_test/domain_isolation.dart
import 'package:dartunit/dartunit.dart';

// The domain layer must be pure Dart — no framework, HTTP, database,
// platform, or state management dependencies.
void main(List<String> args) {
  final rules = noExternalPackagePreset(
    folders: [
      'lib/domain',
      'lib/domain/entities',
      'lib/domain/value_objects',
      'lib/domain/repositories',   // Abstract interfaces
      'lib/domain/services',        // Domain services
      'lib/domain/exceptions',
    ],
    packages: [
      // Flutter framework
      'flutter',

      // HTTP clients
      'dio',
      'http',
      'retrofit',
      'chopper',

      // Local databases
      'sqflite',
      'drift',
      'hive',
      'hive_flutter',
      'isar',
      'objectbox',
      'sembast',
      'floor',

      // State management
      'flutter_bloc',
      'bloc',
      'provider',
      'riverpod',
      'flutter_riverpod',
      'get',
      'mobx',
      'redux',

      // Platform plugins
      'shared_preferences',
      'path_provider',
      'url_launcher',
      'image_picker',
      'camera',
      'location',
      'firebase_core',
      'firebase_auth',
      'cloud_firestore',

      // Serialization (JSON serialization belongs in data layer)
      'json_annotation',
    ],
    severity: Severity.error,
  );

  for (final rule in rules) {
    archTest(args, rule);
  }
}
```

This comprehensive list ensures the domain layer has truly zero infrastructure dependencies. When DartUnit runs this in CI, any developer who accidentally imports a forbidden package gets an immediate, clear error:

```
VIOLATION [error] noExternalPackagePreset[flutter]
  File: lib/domain/services/payment_service.dart
  Line 3: import 'package:flutter/foundation.dart';
  Package: flutter
  Reason: Domain layer (lib/domain) must not import package:flutter.
          Domain code must be pure Dart to enable fast unit testing
          and framework independence. Use package:meta/meta.dart
          for @immutable instead of package:flutter/foundation.dart.
```

### Example 6: Application Layer Restrictions (Less Strict Than Domain)

The application layer (use cases, BLoC, application services) has slightly looser constraints. It may depend on BLoC/provider for state management but should not import Flutter widgets or infrastructure packages:

```dart
// arch_test/application_isolation.dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) {
  final rules = noExternalPackagePreset(
    folders: ['lib/application', 'lib/blocs', 'lib/use_cases'],
    packages: [
      // No Flutter widgets in application layer
      'flutter',

      // No direct HTTP in application layer
      'dio',
      'http',
      'retrofit',

      // No direct database access in application layer
      'sqflite',
      'drift',
      'hive',
      'isar',

      // No Firebase SDK directly in application layer
      // (use repository abstractions)
      'cloud_firestore',
      'firebase_auth',
      'firebase_storage',
    ],
    severity: Severity.error,
    exceptions: [
      'lib/blocs/navigation_bloc.dart', // NavigationBloc uses Flutter's Navigator
    ],
  );

  for (final rule in rules) {
    archTest(args, rule);
  }
}
```

## Violation Message Format

When a forbidden import is detected:

```
VIOLATION [error] noExternalPackagePreset[dio]
  File: lib/domain/repositories/product_repository_impl.dart
  Line 4: import 'package:dio/dio.dart';
  Package: dio
  Folder: lib/domain
  Reason: Files in lib/domain must not import package:dio.
          HTTP clients are infrastructure concerns.
          Depend on abstract repository interfaces instead.
```

Each rule in the returned list generates violations independently. A file that imports both `dio` and `flutter` in a restricted folder will generate two separate violations — one per forbidden package — making it clear exactly which imports to remove.

## Structuring Multiple Rule Files

For large projects, organize package restriction rules by layer:

```
arch_test/
  domain_isolation.dart       # Domain layer package restrictions
  application_isolation.dart  # Application layer restrictions
  presentation_rules.dart     # Presentation layer rules
  global_hygiene.dart         # Cross-layer checks
```

Each file is a standalone Dart program run independently by DartUnit. This organization makes it easy to understand and maintain the architectural rules without one large file containing everything.

## Pairing With Layer Dependency Rules

`noExternalPackagePreset` and `layerDependencyPreset` are complementary:

- `layerDependencyPreset` controls which **project layers** can import which other project layers (e.g., presentation may import application, but not domain directly).
- `noExternalPackagePreset` controls which **external packages** can be imported by which layers.

Together, they form a complete dependency boundary that covers both internal and external dependencies.

```dart
// arch_test/domain_boundaries.dart — controls project-internal imports
import 'package:dartunit/dartunit.dart';

void main(List<String> args) {
  archTest(args, layerDependencyPreset(
    layers: {
      'domain': [],                         // Domain imports nothing from this project
      'application': ['domain'],            // Application may import domain
      'infrastructure': ['domain'],          // Infrastructure implements domain interfaces
      'presentation': ['application'],       // Presentation imports application
    },
  ));
}
```

```dart
// arch_test/domain_external.dart — controls external package imports
import 'package:dartunit/dartunit.dart';

void main(List<String> args) {
  archTestAll(args, noExternalPackagePreset(
    folders: ['lib/domain'],
    packages: ['flutter', 'dio', 'hive', 'shared_preferences'],
    severity: Severity.error,
  ));
}
```

## Related Presets

- [`layerDependencyPreset`](/presets/layer) — Control imports between project layers (internal dependencies)
- [`noBannedCallsPreset`](/presets/no-banned-calls) — Ban specific textual patterns including direct method calls
- [`annotationMustNotHavePreset`](/presets/annotation-must-not-have) — Prevent infrastructure-specific annotations from appearing in the domain layer
