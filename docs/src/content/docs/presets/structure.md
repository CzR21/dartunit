---
title: Structure Presets
description: Presets for enforcing structural constraints — abstraction, immutability, and circular dependencies.
sidebar:
  order: 3
---

Structure presets enforce properties of class declarations: whether they are abstract, whether their fields are immutable, and whether the import graph is free of cycles.

---

## mustBeAbstract

Enforces that all classes in the specified folders are declared `abstract`.

### Function signature

```dart
ArchitectureRule mustBeAbstract({
  required List<String> folders,
  RuleSeverity severity = RuleSeverity.error,
  List<String> exceptions = const [],
})
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `folders` | `List<String>` | required | Folders where all classes must be abstract |
| `severity` | `RuleSeverity` | `RuleSeverity.error` | Violation severity |
| `exceptions` | `List<String>` | `[]` | Exact class names to exempt |

### Why use it

Repository interfaces, use case interfaces, and domain service contracts should always be abstract. Making this a rule prevents the team from accidentally creating concrete implementations in the wrong layer.

### Example — Domain repository interfaces

```dart title="test_arch/domain_abstractions_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(
  args,
  mustBeAbstract(
    folders: ['lib/domain/repositories'],
    severity: RuleSeverity.error,
  ),
);
```

### Example — Multiple contract folders

```dart title="test_arch/contracts_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(
  args,
  mustBeAbstract(
    folders: [
      'lib/domain/repositories',
      'lib/domain/usecases',
      'lib/domain/services',
    ],
    severity: RuleSeverity.error,
    exceptions: ['ConcreteRepositoryBase'],
  ),
);
```

### Correct vs incorrect

```dart
// lib/domain/repositories/user_repository.dart

// Correct — abstract interface
abstract class UserRepository {
  Future<User?> findById(String id);
  Future<void> save(User user);
}

// Violation — concrete class in domain/repositories
class UserRepository {
  Future<User?> findById(String id) async => null; // implementation belongs in data!
}
```

---

## mustBeImmutable

Enforces that all instance fields in classes in the specified folders are `final` or `const`.

### Function signature

```dart
ArchitectureRule mustBeImmutable({
  required List<String> folders,
  RuleSeverity severity = RuleSeverity.error,
  List<String> exceptions = const [],
})
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `folders` | `List<String>` | required | Folders where all class fields must be final/const |
| `severity` | `RuleSeverity` | `RuleSeverity.error` | Violation severity |
| `exceptions` | `List<String>` | `[]` | Exact class names to exempt |

### Why use it

Immutable domain entities cannot be accidentally modified after creation. They are easier to reason about, simpler to test, and safe to share across components without defensive copying.

### Example — Domain entities and value objects

```dart title="test_arch/immutability_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(
  args,
  mustBeImmutable(
    folders: [
      'lib/domain/entities',
      'lib/domain/value_objects',
    ],
    severity: RuleSeverity.error,
  ),
);
```

### Example — With exceptions for generated code

```dart title="test_arch/immutability_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(
  args,
  mustBeImmutable(
    folders: ['lib/domain/entities'],
    severity: RuleSeverity.error,
    exceptions: [
      'UserState',      // Freezed-generated class with internal mutable fields
      'AuthFormState',  // Form state needs mutable fields
    ],
  ),
);
```

### Correct vs incorrect

```dart
// lib/domain/entities/user.dart

// Correct — all fields are final
class User {
  final String id;
  final String name;
  final String email;

  const User({required this.id, required this.name, required this.email});
}

// Violation — non-final fields
class User {
  String id;    // violation: not final
  String name;  // violation: not final

  User({required this.id, required this.name});
}
```

---

## noCircularDependencies

Enforces that no class in the project is part of a circular import chain.

### Function signature

```dart
ArchitectureRule noCircularDependencies({
  RuleSeverity severity = RuleSeverity.critical,
})
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `severity` | `RuleSeverity` | `RuleSeverity.critical` | Violation severity. `critical` is strongly recommended. |

### Why use it

Circular dependencies cause maintenance problems, make testing significantly harder (breaking one file breaks all files in the cycle), and can cause runtime initialization errors.

### Example

```dart title="test_arch/no_cycles_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(
  args,
  noCircularDependencies(severity: RuleSeverity.critical),
);
```

### What a circular dependency looks like

```
lib/core/services/auth_service.dart
  → imports lib/core/services/user_service.dart
      → imports lib/core/services/token_service.dart
          → imports lib/core/services/auth_service.dart  ← cycle!
```

### Violation output

```
CRITICAL | No circular dependencies
         | lib/core/services/auth_service.dart:1
         | Circular dependency: auth_service.dart → user_service.dart → token_service.dart → auth_service.dart
```

:::caution[Use critical severity]
Circular dependencies are always problematic. Using `RuleSeverity.critical` ensures they are resolved immediately rather than accumulated over time.
:::
