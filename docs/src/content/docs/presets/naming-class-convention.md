---
title: namingClassConvention
description: Enforce that every class in a folder ends with the folder's capitalized name as a suffix. Keeps naming consistent and predictable across the project.
sidebar:
  order: 4
---

`namingClassConvention` enforces that every class defined inside a given folder ends with a suffix derived from that folder's name. Classes in `lib/bloc/` must end with `Bloc`. Classes in `lib/service/` must end with `Service`. Classes in `lib/domain/repositories/` must end with `Repositories`.

This is one of the most widely applicable naming rules because it requires zero configuration of the expected suffix — the folder path carries the convention.

## Function signature

```dart
void namingClassConvention({
  required List<String> folders,
  String? namePattern,
  String? prefix,
  String? suffix,
  RuleSeverity severity = RuleSeverity.error,
  List<String> exceptions = const [],
  String projectRoot = '.',
})
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `folders` | `List<String>` | required | Folder paths to enforce. The required suffix is derived from the last segment of each path with its first character uppercased, unless overridden. |
| `namePattern` | `String?` | — | Raw regex applied to the class name. Overrides `prefix`/`suffix` when provided. |
| `prefix` | `String?` | — | Required class name prefix (e.g., `'I'` for interface convention). Combined with `suffix` when both are provided. |
| `suffix` | `String?` | — | Explicit class name suffix, overriding the auto-derived one. |
| `severity` | `RuleSeverity` | `RuleSeverity.error` | Severity of violations. |
| `exceptions` | `List<String>` | `const []` | Exact class names to exclude from the check. |

:::note[Mutual exclusivity]
`namePattern` and `prefix`/`suffix` are mutually exclusive. Use one or the other, not both.
:::

## How the suffix is derived

The preset extracts the last path segment from the folder string and capitalizes its first letter:

| Folder path | Derived suffix |
|-------------|----------------|
| `lib/bloc` | `Bloc` |
| `lib/service` | `Service` |
| `lib/services` | `Services` |
| `lib/repositories` | `Repositories` |
| `lib/domain/usecases` | `Usecases` |
| `lib/features/cart/bloc` | `Bloc` |

**Important:** only the last path segment is used. `lib/features/cart/bloc` produces the suffix `Bloc`, not `CartBloc`.

## Basic usage

```dart title="test_arch/naming_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() => namingClassConvention(
  folders: ['lib/bloc', 'lib/repository', 'lib/service'],
);
```

## Examples

### Example 1 — BLoC architecture

```dart title="test_arch/bloc_naming_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() => namingClassConvention(
  folders: [
    'lib/bloc',
    'lib/event',
    'lib/state',
    'lib/repository',
  ],
  severity: RuleSeverity.error,
  exceptions: [
    'BaseBloc',  // abstract base class, not a specific BLoC
    'AppState',  // top-level app state
  ],
);
```

**Valid class names:**
```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> { ... }   // ✓ ends with Bloc
abstract class AuthEvent { ... }                             // ✓ ends with Event
class AuthState { ... }                                      // ✓ ends with State
abstract class AuthRepository { ... }                        // ✓ ends with Repository
```

**Invalid class names:**
```dart
class AuthManager { ... }   // ✗ in lib/bloc/ but doesn't end with "Bloc"
class AuthService { ... }   // ✗ in lib/repository/ but doesn't end with "Repository"
```

### Example 2 — Clean Architecture

```dart title="test_arch/clean_arch_naming_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() => namingClassConvention(
  folders: [
    'lib/domain/usecase',
    'lib/domain/entity',
    'lib/domain/repository',
    'lib/data/datasource',
    'lib/data/model',
  ],
  severity: RuleSeverity.error,
  exceptions: [
    'BaseUseCase',      // abstract base in usecases folder
    'IUserRepository',  // follows interface-prefix convention
  ],
);
```

### Example 3 — Explicit suffix override

When the auto-derived suffix doesn't match your convention (e.g., BLoC classes should end with `Bloc` or `Cubit`):

```dart title="test_arch/bloc_naming_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() => namingClassConvention(
  folders: ['lib/bloc'],
  // Override: allow both Bloc and Cubit by using a regex pattern
  namePattern: r'.*(Bloc|Cubit)$',
  severity: RuleSeverity.error,
);
```

### Example 4 — Prefix convention for interfaces

For projects using an `I` prefix convention for repository interfaces:

```dart title="test_arch/interface_naming_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() => namingClassConvention(
  folders: ['lib/domain/repositories'],
  prefix: 'I',
  suffix: 'Repository',
  // Enforces: IUserRepository, IProductRepository, IAuthRepository
  severity: RuleSeverity.warning,
);
```

### Example 5 — Feature-based architecture

When using feature slices, apply naming conventions across all matching subfolders:

```dart title="test_arch/feature_naming_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  // All BLoC files in any feature — suffix 'Bloc'
  namingClassConvention(
    folders: [
      'lib/features/auth/bloc',
      'lib/features/product/bloc',
      'lib/features/cart/bloc',
    ],
    severity: RuleSeverity.error,
  );

  // All repositories in any feature — suffix 'Repository'
  namingClassConvention(
    folders: [
      'lib/features/auth/repository',
      'lib/features/product/repository',
      'lib/features/cart/repository',
    ],
    severity: RuleSeverity.error,
  );
}
```

## The exceptions parameter

Some classes legitimately cannot follow the folder suffix convention:

```dart title="test_arch/naming_with_exceptions_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() => namingClassConvention(
  folders: ['lib/bloc'],
  severity: RuleSeverity.error,
  exceptions: [
    'BaseBloc',      // abstract infrastructure class
    'RootBloc',      // app-level BLoC with a legacy name
    'LoggableMixin', // mixin that lives in bloc/ for proximity reasons
  ],
);
```

Exceptions are matched by exact class name, not by substring or regex.

## Why consistent naming matters

**Discoverability** — When naming is consistent, `Cmd+T` (Go to Type) in your IDE becomes a reliable navigation tool. A developer searching for the authentication repository types `AuthRepo` and immediately sees `AuthRepository`. Without enforcement, the same architectural role might be named `AuthStore`, `AuthDataProvider`, or `AuthDataService`.

**Onboarding** — A new developer can read the convention once and apply it across the entire codebase. When they see a file in `lib/bloc/`, they know without opening it that it contains a class ending in `Bloc`.

**Code review** — Reviewers can spot architectural violations at a glance. If a class named `CartValidator` appears inside `lib/repositories/`, the naming rule makes the violation obvious.

## Common gotchas

### The suffix comes from the immediate folder name only

`lib/features/cart/bloc` → suffix is `Bloc`, not `CartBloc`. Only the last path segment matters.

### Plural vs singular folder names

`lib/service` → suffix `Service`. `lib/services` → suffix `Services`. Choose one convention and apply it consistently.

### Subfolders are included by default

If you register `lib/bloc`, all files under `lib/bloc/auth/`, `lib/bloc/product/`, etc. are also checked. DartUnit uses substring path matching.

## Violation output

```
  ✗  Classes in "lib/bloc" must end with "Bloc"
       ✗ lib/bloc/auth_manager.dart [error] — "AuthManager" does not match .*Bloc$
       ✗ lib/bloc/session_handler.dart [error] — "SessionHandler" does not match .*Bloc$
```

## Related presets

| Preset | What it checks |
|--------|---------------|
| [`namingFileConvention`](/presets/naming-file-convention) | File names (not class names) inside a folder |
| [`mustBeAbstract`](/presets/must-be-abstract) | Pair with this to enforce abstract interfaces in naming-controlled folders |
