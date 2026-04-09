---
title: namingNamePattern
description: Enforce custom naming conventions with regex patterns. Use when folder-suffix naming isn't flexible enough for your project's conventions.
sidebar:
  order: 5
---

`namingNamePattern` enforces that every class in a specified folder has a name matching a custom regular expression. Where `namingFolderSuffix` derives the expected suffix from the folder name, this preset lets you supply any regex — prefixes, combined prefix+suffix rules, strict formats, or negative patterns.

---

## When folder-suffix naming is not enough

`namingFolderSuffix` covers the common case: everything in `lib/repositories/` ends with `Repository`. But many real-world conventions cannot be expressed as a simple suffix derived from the folder name.

### Interface prefix conventions

Some teams follow the `I`-prefix convention from C# and Java: all interfaces are named `IUserRepository`, `ICartService`, `IPaymentGateway`. The folder might be `lib/domain/repositories`, which would generate the suffix `Repositories`. That suffix doesn't match the intended `IUserRepository` naming. You need a pattern rule instead: `^I[A-Z][a-zA-Z]+$`.

### Abstract base class naming

Abstract base classes often carry an `Abstract` prefix: `AbstractRepository`, `AbstractUseCase`, `AbstractBloc`. These classes live in the same folder as the concrete interfaces they define, but they need a different naming rule.

### Feature-prefixed naming

In feature-first architectures, all classes within a feature are prefixed with the feature name. The `cart` feature might require all classes to start with `Cart`: `CartBloc`, `CartRepository`, `CartState`. The folder is `lib/features/cart/`, so no single folder-name suffix rule can express this constraint. You need `^Cart[A-Z].*`.

### Combined naming rules

Some conventions combine a prefix and suffix. All BLoC events in the `auth` feature are named `Auth...Event`: `AuthLoginEvent`, `AuthLogoutEvent`, `AuthRefreshEvent`. The pattern `^Auth.*Event$` expresses this precisely.

### Negative patterns

Occasionally you need to forbid a pattern rather than require one. No class in `lib/domain/` should end with `Impl` — implementations belong in the data layer. The negative lookahead pattern `^(?!.*Impl$).*` expresses this.

---

## Regex fundamentals for naming patterns

Dart uses the `RegExp` class, which follows ECMAScript regular expression syntax. The patterns you write in this preset are matched against the full class name.

### Anchoring

- `^` — matches the start of the string. Without it, the pattern can match anywhere in the name.
- `$` — matches the end of the string. Without it, the pattern can match a prefix of the name.

Always anchor your patterns unless you intentionally want substring matching:

```
r'Service'      # matches "AuthService", "ServiceLocator", "NotAServiceAnymore"
r'.*Service$'   # matches "AuthService", "UserService" — ends with Service
r'^I[A-Z].*$'   # matches "IUserRepository", "ICartService" — starts with I followed by uppercase
```

### Character classes and quantifiers

| Pattern | Meaning |
|---|---|
| `[A-Z]` | One uppercase ASCII letter |
| `[a-z]` | One lowercase ASCII letter |
| `[a-zA-Z]` | One ASCII letter, any case |
| `[a-zA-Z0-9]` | One alphanumeric ASCII character |
| `.*` | Zero or more of any character |
| `.+` | One or more of any character |
| `?` | Zero or one of the preceding |
| `{2,5}` | Between 2 and 5 of the preceding |

### Alternation

Use `|` inside a group to match either of two patterns:

```
r'.*(Bloc|Cubit)$'        # ends with Bloc OR Cubit
r'^(Abstract|Base)[A-Z]'  # starts with Abstract OR Base
```

### Negative lookahead

`(?!...)` asserts that what follows does not match. This is the standard way to express "must NOT contain/end with":

```
r'^(?!.*Impl$).*$'    # does not end with Impl
r'^(?!Abstract).*$'   # does not start with Abstract
```

---

## Function signature

```dart
void namingNamePattern({
  required String folder,
  required String pattern,
  RuleSeverity severity = RuleSeverity.warning,
  List<String> exceptions = const [],
})
```

## Parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `folder` | `String` | required | The folder path to apply this rule to. Matched as a substring of each file's path. |
| `pattern` | `String` | required | A Dart-compatible regular expression that every class name in the folder must match. |
| `severity` | `RuleSeverity` | `RuleSeverity.warning` | Violation severity. Use `RuleSeverity.error` to block CI on violations. |
| `exceptions` | `List<String>` | `const []` | Exact class names that are exempt from the pattern rule. |

---

## Examples

### Example 1 — Interface convention: `I` prefix

A team following the interface-prefix convention requires that every class in `lib/domain/repositories/` starts with `I` (uppercase) and is followed immediately by an uppercase letter (to prevent names like `Irepository`):

```dart title="test_arch/interface_naming_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() => namingNamePattern(
    folder: 'lib/domain/repositories',
    pattern: r'^I[A-Z][a-zA-Z]+$',
    severity: RuleSeverity.error,
    exceptions: [
      'RepositoryBase',  // shared base, exempt from the I-prefix rule
    ],
  ),
);
```

Valid class names under this rule:

```dart
class IUserRepository { ... }     // valid
class ICartRepository { ... }     // valid
class IPaymentGateway { ... }     // valid
```

Invalid:

```dart
class UserRepository { ... }      // violation: no I prefix
class Irepository { ... }         // violation: I not followed by uppercase
class IUser { ... }               // depends on team: single-word interface names
```

### Example 2 — Abstract base classes with `Abstract` prefix

A project places all abstract base classes in `lib/core/base/`. The convention requires them to start with `Abstract`:

```dart title="test_arch/base_class_naming_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() => namingNamePattern(
    folder: 'lib/core/base',
    pattern: r'^Abstract[A-Z][a-zA-Z]+$',
    severity: RuleSeverity.warning,
  ),
);
```

This enforces:

```dart
class AbstractRepository { ... }     // valid
class AbstractUseCase { ... }        // valid
class AbstractBloc { ... }           // valid

class BaseRepository { ... }         // violation: starts with Base, not Abstract
class Repository { ... }             // violation: no prefix at all
```

To allow both `Abstract` and `Base` as accepted prefixes, use alternation:

```dart
namingNamePattern(
  folder: 'lib/core/base',
  pattern: r'^(Abstract|Base)[A-Z][a-zA-Z]+$',
  severity: RuleSeverity.warning,
),
```

### Example 3 — Feature-prefixed naming

In a feature-first Flutter project, all classes inside the `cart` feature's bloc folder must start with `Cart` to make their feature ownership explicit:

```dart title="test_arch/cart_naming_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) {
  // Cart BLoC classes must start with Cart
  namingNamePattern(
      folder: 'lib/features/cart/bloc',
      pattern: r'^Cart[A-Z][a-zA-Z]*(Bloc|Event|State|Cubit)$',
      severity: RuleSeverity.error,
    ),
  );

  // Product BLoC classes must start with Product
  namingNamePattern(
      folder: 'lib/features/product/bloc',
      pattern: r'^Product[A-Z][a-zA-Z]*(Bloc|Event|State|Cubit)$',
      severity: RuleSeverity.error,
    ),
  );
}
```

This enforces:

```dart
// In lib/features/cart/bloc/
class CartBloc extends Bloc<CartEvent, CartState> { ... }       // valid
class CartLoadedState extends CartState { ... }                  // valid
class CartAddItemEvent extends CartEvent { ... }                 // valid

class AddItemEvent extends CartEvent { ... }                     // violation: no Cart prefix
class CartManager { ... }                                        // violation: no Bloc/Event/State/Cubit suffix
```

### Example 4 — Test double naming conventions

Test helpers — mocks, fakes, and stubs — are commonly placed in a shared `test/helpers/` directory. Enforcing consistent naming makes it immediately clear what kind of test double you are looking at:

```dart title="test_arch/test_double_naming_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) {
  // Mocks must start with Mock
  namingNamePattern(
      folder: 'test/mocks',
      pattern: r'^Mock[A-Z][a-zA-Z]+$',
      severity: RuleSeverity.warning,
    ),
  );

  // Fakes must start with Fake
  namingNamePattern(
      folder: 'test/fakes',
      pattern: r'^Fake[A-Z][a-zA-Z]+$',
      severity: RuleSeverity.warning,
    ),
  );

  // Stubs must start with Stub
  namingNamePattern(
      folder: 'test/stubs',
      pattern: r'^Stub[A-Z][a-zA-Z]+$',
      severity: RuleSeverity.warning,
    ),
  );
}
```

Alternatively, if all test doubles are in the same folder:

```dart title="test_arch/test_helpers_naming_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() => namingNamePattern(
    folder: 'test/helpers',
    pattern: r'^(Mock|Fake|Stub|Spy)[A-Z][a-zA-Z]+$',
    severity: RuleSeverity.warning,
    exceptions: [
      'InMemoryDatabase',  // in-memory implementation, not a test double per se
    ],
  ),
);
```

### Example 5 — Combined pattern: starts with `Abstract` OR ends with `Base`

Some teams use both `AbstractFoo` and `FooBase` conventions for base classes, depending on the module. Rather than two separate rules, a single alternation pattern covers both:

```dart title="test_arch/base_naming_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() => namingNamePattern(
    folder: 'lib/core',
    pattern: r'^(Abstract[A-Z][a-zA-Z]+|[A-Z][a-zA-Z]+Base)$',
    severity: RuleSeverity.warning,
    exceptions: [
      'CoreModule',       // module registration class, not a base class
      'CoreConstants',    // constants class, not a base class
    ],
  ),
);
```

This accepts `AbstractRepository`, `AbstractBloc`, `RepositoryBase`, `BlocBase`, but rejects `UserRepository`, `BlocHelper`, or anything that does not match the expected base-class convention.

---

## Tips for writing readable architecture patterns

### Use raw strings

Always prefix regex patterns with `r` to avoid double-escaping backslashes:

```dart
// Bad: double escaping required, hard to read
pattern: '^I[A-Z][a-zA-Z]+\\$'

// Good: raw string, no double escaping needed
pattern: r'^I[A-Z][a-zA-Z]+$'
```

### Name your patterns in a comment

A regex alone can be cryptic for the next developer reading the rule file. Add a comment stating what the pattern means in plain language:

```dart
namingNamePattern(
  folder: 'lib/domain/repositories',
  // Must start with I followed by uppercase: IUserRepository, ICartService
  pattern: r'^I[A-Z][a-zA-Z]+$',
  severity: RuleSeverity.error,
),
```

### Test patterns before committing

Use [regex101.com](https://regex101.com) with the ECMAScript flavor to test your patterns against sample class names before writing the rule. This is especially useful for alternation and negative lookahead patterns.

### Prefer anchored patterns

Always use `^` and `$` anchors unless you genuinely want substring matching. An unanchored pattern `r'Service'` will match `ServiceLocator`, `UserServiceHelper`, and `IService`, which is rarely the intent. The anchored `r'^[A-Z][a-zA-Z]+Service$'` matches only classes whose name ends with `Service`.

---

## How to escape special characters

If a class name convention includes characters that are special in regex, they must be escaped with a backslash:

| Character | Meaning in regex | Escaped literal |
|---|---|---|
| `.` | Any character | `\.` |
| `*` | Zero or more | `\*` |
| `+` | One or more | `\+` |
| `?` | Zero or one | `\?` |
| `(` `)` | Grouping | `\(` `\)` |
| `[` `]` | Character class | `\[` `\]` |
| `{` `}` | Quantifier | `\{` `\}` |
| `^` | Start anchor or negation in `[]` | `\^` |
| `$` | End anchor | `\$` |
| `\|` | Alternation | `\|` |

In practice, Dart class names only contain letters, digits, and underscores (`_`), none of which require escaping. You are unlikely to need escaped literals in naming rules.

---

## Common patterns reference

| Use case | Pattern |
|---|---|
| Ends with `Repository` | `r'^[A-Z][a-zA-Z]+Repository$'` |
| Ends with `Bloc` or `Cubit` | `r'^[A-Z][a-zA-Z]*(Bloc\|Cubit)$'` |
| Starts with `I` (interface prefix) | `r'^I[A-Z][a-zA-Z]+$'` |
| Starts with `Abstract` | `r'^Abstract[A-Z][a-zA-Z]+$'` |
| Starts with `Mock`, `Fake`, or `Stub` | `r'^(Mock\|Fake\|Stub)[A-Z][a-zA-Z]+$'` |
| Starts with `Cart` and ends with `Bloc` | `r'^Cart[A-Z][a-zA-Z]*Bloc$'` |
| Does not end with `Impl` | `r'^(?!.*Impl$).*$'` |
| PascalCase, any name | `r'^[A-Z][a-zA-Z0-9]+$'` |
| Contains `Mapper` anywhere | `r'^[A-Z][a-zA-Z]*Mapper[a-zA-Z]*$'` |

---

## Violation output

When a class name does not match the required pattern, DartUnit reports:

```
WARNING | Classes in lib/domain/repositories must match pattern "^I[A-Z][a-zA-Z]+$"
        | lib/domain/repositories/user_repository.dart:1
        | Class "UserRepository" does not match pattern "^I[A-Z][a-zA-Z]+$"
```

The violation message includes:
- The folder that the rule targets
- The pattern that was not matched
- The file path and line number
- The exact class name that failed

---

## Related presets

- [`namingFolderSuffix`](/presets/naming-folder-suffix/) — simpler approach when the convention is just a suffix derived from the folder name
- [`mustBeAbstract`](/presets/must-be-abstract/) — combine with this preset to enforce that interface-prefixed classes are also declared `abstract`
