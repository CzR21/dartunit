---
title: namingFolderSuffixPreset
description: Enforce that every class in a folder ends with the folder's capitalized name as a suffix. Keeps naming consistent and predictable across the project.
sidebar:
  order: 4
---

`namingFolderSuffixPreset` enforces that every class defined inside a given folder ends with a suffix derived from that folder's name. Classes in `lib/repositories/` must end with `Repository`. Classes in `lib/services/` must end with `Service`. Classes in `lib/bloc/` must end with `Bloc`.

This is one of the most widely applicable naming rules because it requires zero configuration of the expected suffix — the folder path carries the convention.

---

## Why consistent naming matters

In a codebase with dozens of features and hundreds of classes, naming consistency is not aesthetic preference — it is a navigability contract between every developer on the team.

### Discoverability and IDE search

When naming is consistent, `Ctrl+T` (or `Cmd+T`) in an IDE becomes a reliable navigation tool. A developer looking for the authentication repository types `AuthRepo` and immediately sees `AuthRepository`. They don't need to know whether the author named it `AuthStore`, `AuthDataProvider`, `AuthDataService`, or `AuthRepositoryImpl`. The convention makes the name predictable before the developer even opens the file.

Without enforcement, the same codebase might have `AuthRepository`, `ProductDataStore`, `OrderDataProvider`, and `UserService` all serving the same architectural role — repository-layer data access — but discoverable only if you already know their names.

### Onboarding new developers

A new developer joining the team can read the convention once and immediately apply it across the entire codebase. When they see a file in `lib/blocs/`, they know without opening it that it contains a class ending in `Bloc`. When they need to create a new use case, they know it goes in `lib/usecases/` and the class name ends in `UseCase`.

Without enforcement, they must read existing code, observe inconsistencies, and make judgment calls about which inconsistency to follow. The rule eliminates this friction.

### Reducing cognitive load during code review

Reviewers reading a pull request can spot architectural violations at a glance. If a class named `CartValidator` appears in a file inside `lib/repositories/`, the naming rule makes the violation obvious. With inconsistent naming, the reviewer must read the class body and mentally categorize it before deciding whether it belongs.

### The mental model benefit

Consistent naming creates a tight mapping between folder structure and class identity. When you see a file at `lib/features/cart/bloc/cart_bloc.dart`, you know the primary class is `CartBloc`. When you see `lib/features/product/repositories/product_repository.dart`, you know the primary class is `ProductRepository`. This mapping is load-bearing: it means the file tree and the type system tell the same story.

---

## How the suffix is derived

The preset extracts the last path segment from the folder string and capitalizes its first letter. The rest of the segment is preserved as-is.

| Folder path | Last segment | Required suffix |
|---|---|---|
| `lib/bloc` | `bloc` | `Bloc` |
| `lib/blocs` | `blocs` | `Blocs` |
| `lib/repositories` | `repositories` | `Repositories` |
| `lib/services` | `services` | `Services` |
| `lib/datasources` | `datasources` | `Datasources` |
| `lib/usecases` | `usecases` | `Usecases` |
| `lib/domain/entities` | `entities` | `Entities` |
| `lib/data/mappers` | `mappers` | `Mappers` |
| `lib/features/cart/bloc` | `bloc` | `Bloc` |

**Important:** only the last path segment is used. The full path does not affect the expected suffix. `lib/features/cart/bloc` and `lib/features/order/bloc` both produce the suffix `Bloc`.

This also means that if you name your folder `lib/domain/repository` (singular), the suffix is `Repository`. If you name it `lib/domain/repositories` (plural), the suffix is `Repositories`. Plan your folder names accordingly, because the suffix follows the folder name exactly.

---

## Function signature

```dart
ArchitectureRule namingFolderSuffixPreset({
  required List<String> folders,
  RuleSeverity severity = RuleSeverity.warning,
  List<String> exceptions = const [],
})
```

## Parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `folders` | `List<String>` | required | Folder paths to enforce. The required suffix is derived from the last segment of each path, with its first character uppercased. |
| `severity` | `RuleSeverity` | `RuleSeverity.warning` | The severity level of violations. Use `RuleSeverity.error` to make violations fail CI. |
| `exceptions` | `List<String>` | `const []` | Exact class names that are exempt from the rule. These classes will not be checked, even if they are in the specified folders. |

---

## Examples

### Example 1 — BLoC architecture

A BLoC-based Flutter project typically has dedicated folders for blocs, events, states, and repositories. Each folder has a clear naming contract:

- `lib/bloc/` → every class ends with `Bloc`
- `lib/event/` → every class ends with `Event`
- `lib/state/` → every class ends with `State`
- `lib/repository/` → every class ends with `Repository`

```dart title="arch_test/bloc_naming_arch_test.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(
  args,
  namingFolderSuffixPreset(
    folders: [
      'lib/bloc',
      'lib/event',
      'lib/state',
      'lib/repository',
    ],
    severity: RuleSeverity.error,
    exceptions: [
      'BaseBloc',       // abstract base, doesn't represent a specific bloc
      'AppState',       // top-level app state, lives in the state folder by convention
    ],
  ),
);
```

With this rule in place, the following class names are **valid**:

```dart
// lib/bloc/auth_bloc.dart
class AuthBloc extends Bloc<AuthEvent, AuthState> { ... }

// lib/event/auth_event.dart
abstract class AuthEvent { ... }
class LoginRequested extends AuthEvent { ... }  // violation: does not end with Event
```

And the following are **invalid**:

```dart
// lib/bloc/auth_manager.dart
class AuthManager { ... }  // violation: does not end with "Bloc"

// lib/repository/auth_service.dart
class AuthService { ... }  // violation: does not end with "Repository"
```

### Example 2 — Clean Architecture

Clean Architecture separates the project into distinct layers, each with its own folder. Naming conventions reinforce these boundaries:

```dart title="arch_test/clean_arch_naming_arch_test.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(
  args,
  namingFolderSuffixPreset(
    folders: [
      'lib/domain/usecases',
      'lib/domain/entities',
      'lib/domain/repositories',
      'lib/data/datasources',
      'lib/data/models',
      'lib/data/repositories',
    ],
    severity: RuleSeverity.error,
    exceptions: [
      'IUserRepository',    // follows interface-prefix convention, exempt from suffix
      'BaseUseCase',        // abstract base in usecases folder
    ],
  ),
);
```

This enforces the following convention across layers:

| File | Expected class name |
|---|---|
| `lib/domain/usecases/get_user_usecase.dart` | `GetUserUsecases` or `GetUserUsecase`* |
| `lib/domain/entities/user_entity.dart` | `UserEntities` or `UserEntity`* |
| `lib/domain/repositories/user_repository.dart` | `UserRepositories` or `UserRepository`* |
| `lib/data/datasources/user_datasource.dart` | `UserDatasources` or `UserDatasource`* |

*Suffix is derived from the folder name. If your folder is `usecases` (plural), the suffix is `Usecases`. If it is `usecase` (singular), the suffix is `Usecase`. Choose singular folder names if you prefer singular suffixes.

### Example 3 — Service layer pattern

Projects using a traditional service-oriented architecture can enforce naming across service, factory, and validator folders:

```dart title="arch_test/service_layer_naming_arch_test.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(
  args,
  namingFolderSuffixPreset(
    folders: [
      'lib/services',
      'lib/factories',
      'lib/validators',
      'lib/handlers',
    ],
    severity: RuleSeverity.warning,
    exceptions: [
      'ServiceLocator',    // the service locator itself lives in lib/services by convention
      'ValidatorMixin',    // a mixin that doesn't represent a standalone validator
    ],
  ),
);
```

### Example 4 — Repository pattern with impl distinction

A common pattern is to keep repository interfaces in one folder and their implementations in a sibling folder:

```
lib/
  domain/
    repositories/       ← interfaces, suffix Repository
  data/
    repositories/       ← implementations, suffix Repository
      impl/             ← optional: suffix Impl
```

```dart title="arch_test/repository_naming_arch_test.dart"
import 'package:dartunit/dartunit.dart';

// Rule 1: all repository files (interfaces and implementations) end with Repository
void main(List<String> args) {
  archTest(
    args,
    namingFolderSuffixPreset(
      folders: [
        'lib/domain/repositories',
        'lib/data/repositories',
      ],
      severity: RuleSeverity.error,
    ),
  );

  // Rule 2: if there is an impl/ subfolder, classes there end with Impl
  archTest(
    args,
    namingFolderSuffixPreset(
      folders: [
        'lib/data/repositories/impl',
      ],
      severity: RuleSeverity.error,
    ),
  );
}
```

With this configuration:

```dart
// lib/domain/repositories/cart_repository.dart
abstract class CartRepository { ... }         // valid

// lib/data/repositories/cart_repository_impl.dart
class CartRepositoryImpl implements CartRepository { ... }  // valid in repositories/
                                                            // but if in impl/, must end with Impl
```

---

## The `exceptions` parameter

Some classes legitimately cannot follow the folder suffix convention:

- **Abstract base classes** that are inherited internally: `BaseBloc`, `AbstractRepository`. These are infrastructure classes, not domain classes. They live in the folder but are not subject to the same naming contract.
- **Mixins**: a `LoggableMixin` living in `lib/services/` provides logging behavior. It is not a service itself and need not end with `Service`.
- **Type aliases and extension classes**: `typedef CartItems = List<CartItem>` does not benefit from a suffix.
- **Generated code**: if you have generated files in a naming-controlled folder, the generator may not know your conventions. Add the generated class names to `exceptions` rather than fighting the generator.

```dart title="arch_test/naming_with_exceptions_arch_test.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(
  args,
  namingFolderSuffixPreset(
    folders: ['lib/bloc'],
    severity: RuleSeverity.error,
    exceptions: [
      'BaseBloc',        // abstract infrastructure class
      'RootBloc',        // app-level bloc with a legacy name
      'LoggableMixin',   // mixin lives in bloc/ for proximity reasons
    ],
  ),
);
```

Exceptions are matched by exact class name, not by substring or regex. If you need pattern-based exclusions, use `namingNamePatternPreset` with a custom regex instead.

---

## Violation output

When a class in a controlled folder does not end with the required suffix, DartUnit reports:

```
ERROR | Classes in lib/bloc must end with "Bloc"
      | lib/bloc/auth_manager.dart:3
      | Class "AuthManager" does not end with "Bloc"

ERROR | Classes in lib/repository must end with "Repository"
      | lib/repository/auth_service.dart:1
      | Class "AuthService" does not end with "Repository"
```

Each violation includes:
- The severity level (`WARNING`, `ERROR`, or `CRITICAL`)
- The rule description stating the folder and the expected suffix
- The exact file path and line number of the offending class declaration
- The class name that violated the rule

---

## Common gotchas

### The suffix comes from the immediate folder name, not the full path

This is the most frequent source of confusion. Consider:

```
lib/features/cart/bloc/cart_bloc.dart
```

The required suffix is `Bloc`, not `CartBloc` or `FeaturesBlocBloc`. Only the last segment of the folder path — `bloc` — is used. The full path is irrelevant to suffix derivation.

This means you can reuse the same folder name across feature slices and the same rule will cover all of them:

```dart
namingFolderSuffixPreset(
  folders: [
    'lib/features/cart/bloc',
    'lib/features/product/bloc',
    'lib/features/checkout/bloc',
  ],
  // all three enforce the "Bloc" suffix
)
```

Or more succinctly, if you use a substring-matched single entry:

```dart
namingFolderSuffixPreset(
  folders: ['lib/features'],  // matches every file under features/
  // ...
)
```

Wait — this does not work the way you might expect. The preset checks whether the file's folder ends with one of the listed folder paths. Providing `lib/features` would match every file under `lib/features/`, which would mean all feature classes must end with `Features`. Be precise about which subfolder you are targeting.

### Plural vs singular folder names

`lib/service` → suffix `Service`. `lib/services` → suffix `Services`. These are different. Choose one convention and apply it consistently. Most teams either use all-singular or all-plural. The preset does not normalize pluralization.

### Subfolders are separate

If you register `lib/bloc`, classes in `lib/bloc/auth/` are also checked — unless you explicitly register `lib/bloc/auth` separately. Files are matched by whether their path contains the registered folder string as a substring.

---

## Related presets

- [`namingNamePatternPreset`](/presets/naming-name-pattern/) — use when the convention cannot be described by the folder name alone (e.g., interface prefixes, combined prefix+suffix rules)
- [`mustBeAbstractPreset`](/presets/must-be-abstract/) — pair with this preset to enforce that interface folders contain only abstract classes with the right name
