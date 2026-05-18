---
title: Predicates Reference
description: Complete reference for all 31 built-in predicates. Each predicate defines a positive condition — use NotPredicate to invert.
sidebar:
  order: 1
---

All predicates implement the `Predicate` interface and follow the **positive condition model**: a predicate describes the condition that a compliant element satisfies. When the condition is met, the predicate **passes**. When you need to enforce the _absence_ of a condition, wrap the predicate in `NotPredicate`.

In rule files, predicates are used indirectly through arch matchers in `testArch`/`testArchGroup`:

```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Domain must not depend on data', (selector) {
    expect(
      selector.classes(inFolder: 'lib/domain'),
      doesNotDependOn('lib/data'),  // wraps NotPredicate(DependOnFolderPredicate('lib/data'))
    );
  });
}
```

For advanced composition (e.g., custom rule loaders), predicates can be instantiated directly and composed with three **convenience methods**:

```dart
predicate.not()           // equivalent to NotPredicate(predicate)
predicate.and(other)      // equivalent to AndPredicate([predicate, other])
predicate.or(other)       // equivalent to OrPredicate([predicate, other])
```

---

## Group 1 — Dependency Predicates

### DependOnFolderPredicate

Passes if the class has at least one import whose path contains the given folder string.

**Constructor**
```dart
DependOnFolderPredicate(String folder)
```

**Parameters**
| Parameter | Type | Description |
|-----------|------|-------------|
| `folder` | `String` | Substring matched against each import path in the file |

**Passes when:** the class file contains at least one `import` directive whose path includes `folder` as a substring.

**Example — BLoC must import from repository folder**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('BLoC classes must depend on the repository layer', (selector) {
    expect(
      selector.classes(inFolder: 'lib/bloc', matching: r'.*Bloc$'),
      dependsOn('lib/domain/repositories'),
    );
  });
}
```

**Example — domain must NOT import from presentation (with NotPredicate)**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Domain layer must not import from the presentation layer', (selector) {
    expect(
      selector.classes(inFolder: 'lib/domain'),
      doesNotDependOn('lib/presentation'),
    );
  });
}
```

**Example — data repositories must import from domain**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Repository implementations must depend on the domain layer', (selector) {
    expect(
      selector.classes(inFolder: 'lib/data/repositories', matching: r'.*Impl$'),
      dependsOn('lib/domain'),
    );
  });
}
```

**Notes:** The match is a simple substring check on the full import path string. A folder value of `'lib/domain'` will match `'../../lib/domain/repositories/user_repository.dart'` and any other path containing that substring. To enforce that a class must _not_ import from a folder, always wrap with `NotPredicate` (or call `.not()`).

---

### DependOnPackagePredicate

Passes if the class imports from the specified external package.

**Constructor**
```dart
DependOnPackagePredicate(String package)
```

**Parameters**
| Parameter | Type | Description |
|-----------|------|-------------|
| `package` | `String` | Package name matched as a substring of the import path (without the `package:` prefix) |

**Passes when:** the class file contains at least one `import 'package:<package>/...'` directive whose path contains `package` as a substring.

**Example — presentation layer must use flutter_bloc**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Presentation widgets must use flutter_bloc for state management', (selector) {
    expect(
      selector.classes(inFolder: 'lib/presentation/pages'),
      dependsOnPackage('flutter_bloc'),
    );
  });
}
```

**Example — domain must NOT import Flutter (with NotPredicate)**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Domain layer must not depend on Flutter', (selector) {
    expect(
      selector.classes(inFolder: 'lib/domain'),
      doesNotDependOnPackage('flutter'),
    );
  });
}
```

**Example — domain must NOT use Dio (with NotPredicate)**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Domain layer must not use HTTP client packages', (selector) {
    expect(
      selector.classes(inFolder: 'lib/domain'),
      doesNotDependOnPackage('dio'),
    );
  });
}
```

**Notes:** The package name is matched as a substring, so `'flutter'` matches both `flutter` and `flutter_bloc`. If you need an exact package match, use a more specific string such as `'package:flutter/'` would require `DependOnPackagePredicate` to operate on the raw import — use `NameMatchesPatternPredicate` combined with `FileContentMatchesPredicate` for fine-grained control. This predicate only inspects `package:` imports, not relative `'../...'` imports.

---

### OnlyDependOnFoldersPredicate

Passes if every import in the class comes from one of the explicitly allowed folders (or from Dart/Flutter SDK).

**Constructor**
```dart
OnlyDependOnFoldersPredicate(List<String> allowedFolders)
```

**Parameters**
| Parameter | Type | Description |
|-----------|------|-------------|
| `allowedFolders` | `List<String>` | Whitelist of folder path substrings; any import not matching at least one entry is a violation |

**Passes when:** every import directive in the file either matches at least one entry in `allowedFolders` (substring match), or is a Dart/Flutter SDK import. A single import outside the whitelist causes the predicate to fail.

**Example — domain can only depend on itself and shared utilities**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Domain layer may only import from itself and shared core', (selector) {
    expect(
      selector.classes(inFolder: 'lib/domain'),
      onlyDependsOnFolders(['lib/domain', 'lib/shared', 'lib/core']),
    );
  });
}
```

**Example — utility classes can only import from Dart core paths**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Utility classes must not import from any application layer', (selector) {
    expect(
      selector.classes(inFolder: 'lib/utils'),
      onlyDependsOnFolders(['lib/utils']),
    );
  });
}
```

**Example — data layer strict boundaries**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Data layer may only depend on domain and its own folders', (selector) {
    expect(
      selector.classes(inFolder: 'lib/data'),
      onlyDependsOnFolders(['lib/data', 'lib/domain']),
    );
  });
}
```

**Notes:** This predicate is stricter than `DependOnFolderPredicate` — it checks _all_ imports, not just one. Dart standard library imports (`dart:core`, `dart:async`, etc.) and Flutter SDK imports are always allowed regardless of the whitelist. Consider pairing with `NotPredicate(HasCircularDependencyPredicate())` to cover both import scope and cycle detection.

---

### HasCircularDependencyPredicate

Passes if the class is part of a circular import chain.

**Constructor**
```dart
HasCircularDependencyPredicate()
```

**Parameters**

This predicate takes no parameters.

**Passes when:** the file participates in a dependency cycle — for example, A imports B, B imports C, and C imports A. All files in the cycle are flagged.

**Example — no circular dependencies in the entire project (with NotPredicate)**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('No circular dependencies are allowed anywhere in lib/', (selector) {
    expect(
      selector.classes(inFolder: 'lib'),
      hasNoCircularDependencies(),
    );
  });
}
```

**Example — enforce no cycles scoped to domain**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Domain layer must have no circular dependencies', (selector) {
    expect(
      selector.classes(inFolder: 'lib/domain'),
      hasNoCircularDependencies(),
    );
  });
}
```

**Notes:** This predicate is almost always used with `NotPredicate` — the positive form (`HasCircularDependencyPredicate()` without wrapping) would _require_ a cycle, which is rarely desired. If you want a ready-made rule, use the built-in `noCircularDependenciesPreset()`. Cycle detection is performed across the full import graph, so even indirect cycles (chains of three or more files) are detected.

---

## Group 2 — Naming Predicates

### NameStartsWithPredicate

Passes if the class name starts with the given prefix.

**Constructor**
```dart
NameStartsWithPredicate(String prefix)
```

**Parameters**
| Parameter | Type | Description |
|-----------|------|-------------|
| `prefix` | `String` | The exact string the class name must begin with (case-sensitive) |

**Passes when:** `className.startsWith(prefix)` is true.

**Example — interfaces must start with 'I'**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Interface classes in contracts/ must be prefixed with I', (selector) {
    expect(
      selector.classes(inFolder: 'lib/domain/contracts'),
      haveNameStartingWith('I'),
    );
  });
}
```

**Example — abstract base classes must start with 'Abstract'**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Abstract base classes must be prefixed with Abstract', (selector) {
    expect(
      selector.classes(inFolder: 'lib/core/base'),
      haveNameStartingWith('Abstract'),
    );
  });
}
```

**Example — mock classes in test must start with 'Mock' (with NotPredicate to prevent leaking)**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Classes starting with Mock must not appear in lib/', (selector) {
    expect(
      selector.classes(inFolder: 'lib'),
      doNotHaveNameStartingWith('Mock'),
    );
  });
}
```

**Notes:** The comparison is case-sensitive. For more complex patterns — such as requiring a prefix followed by an uppercase letter — use `NameMatchesPatternPredicate` with a regex like `r'^Abstract[A-Z].*'`.

---

### NameEndsWithPredicate

Passes if the class name ends with the given suffix.

**Constructor**
```dart
NameEndsWithPredicate(String suffix)
```

**Parameters**
| Parameter | Type | Description |
|-----------|------|-------------|
| `suffix` | `String` | The exact string the class name must end with (case-sensitive) |

**Passes when:** `className.endsWith(suffix)` is true.

**Example — repository classes must end with 'Repository'**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('All classes in domain/repositories must end with Repository', (selector) {
    expect(
      selector.classes(inFolder: 'lib/domain/repositories'),
      haveNameEndingWith('Repository'),
    );
  });
}
```

**Example — test doubles must not end with 'Service' in production folders (with NotPredicate)**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Classes ending with FakeService must not appear in lib/', (selector) {
    expect(
      selector.classes(inFolder: 'lib', matching: r'^Fake.*'),
      doNotHaveNameEndingWith('Service'),
    );
  });
}
```

**Example — state management classes may end with Bloc or Cubit (with OrPredicate)**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('State management classes must end with Bloc or Cubit', (selector) {
    expect(
      selector.classes(inFolder: 'lib/bloc'),
      haveNameEndingWith('Bloc').or(haveNameEndingWith('Cubit')),
    );
  });
}
```

**Notes:** The comparison is case-sensitive. Combine with `OrPredicate` when multiple suffixes are acceptable (see example above). For suffix + additional structural constraints, combine with `AndPredicate`.

---

### NameContainsPredicate

Passes if the class name contains the given substring.

**Constructor**
```dart
NameContainsPredicate(String substring)
```

**Parameters**
| Parameter | Type | Description |
|-----------|------|-------------|
| `substring` | `String` | The substring that must appear somewhere in the class name (case-sensitive) |

**Passes when:** `className.contains(substring)` is true.

**Example — feature-scoped cart classes must contain 'Cart'**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('All classes in the cart feature must reference Cart in their name', (selector) {
    expect(
      selector.classes(inFolder: 'lib/features/cart'),
      haveNameContaining('Cart'),
    );
  });
}
```

**Example — production classes must not contain 'Mock' (with NotPredicate)**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Production classes must not contain Mock in their name', (selector) {
    expect(
      selector.classes(inFolder: 'lib'),
      doNotHaveNameContaining('Mock'),
    );
  });
}
```

**Example — mapper classes must contain 'Mapper'**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Classes in data/mappers must contain Mapper in their name', (selector) {
    expect(
      selector.classes(inFolder: 'lib/data/mappers'),
      haveNameContaining('Mapper'),
    );
  });
}
```

**Notes:** Unlike `NameStartsWithPredicate` and `NameEndsWithPredicate`, this predicate matches at any position in the name. It is case-sensitive. For case-insensitive matching, use `NameMatchesPatternPredicate` with the `(?i)` flag in your regex.

---

### NameMatchesPatternPredicate

Passes if the class name matches the given regular expression pattern.

**Constructor**
```dart
NameMatchesPatternPredicate(String pattern)
```

**Parameters**
| Parameter | Type | Description |
|-----------|------|-------------|
| `pattern` | `String` | A Dart regex string matched against the full class name. Case-sensitive by default. Use `(?i)` for case-insensitive matching. |

**Passes when:** `RegExp(pattern).hasMatch(className)` is true against the complete class name.

**Example — BLoC classes must follow strict naming convention**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('BLoC classes must match ^[A-Z][a-zA-Z]+Bloc$', (selector) {
    expect(
      selector.classes(inFolder: 'lib/bloc'),
      haveNameMatchingPattern(r'^[A-Z][a-zA-Z]+Bloc$'),
    );
  });
}
```

**Example — abstract base classes must start with Abstract or Base**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Abstract base classes must start with Abstract or Base', (selector) {
    expect(
      selector.classes(inFolder: 'lib/core/base'),
      haveNameMatchingPattern(r'^(Abstract|Base)[A-Z].*'),
    );
  });
}
```

**Example — entity classes must follow PascalCase followed by Entity**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Domain entities must match the ^[A-Z][a-zA-Z]+Entity$ pattern', (selector) {
    expect(
      selector.classes(inFolder: 'lib/domain/entities'),
      haveNameMatchingPattern(r'^[A-Z][a-zA-Z]+Entity$'),
    );
  });
}
```

**Notes:** This is the most flexible naming predicate. It uses Dart's `RegExp` class internally. The pattern is matched against the class name only — not the file path. If you need to match against file paths, use `FileContentMatchesPredicate` with an appropriate pattern. Anchors (`^` and `$`) are recommended to avoid partial matches.

---

## Group 3 — Type Structure Predicates

### IsAbstractPredicate

Passes if the class is declared `abstract`.

**Constructor**
```dart
IsAbstractPredicate()
```

**Parameters**

This predicate takes no parameters.

**Passes when:** the class declaration includes the `abstract` keyword (e.g., `abstract class Foo` or `abstract interface class Foo`).

**Example — all classes in contracts/ must be abstract**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('All classes in domain/contracts must be declared abstract', (selector) {
    expect(
      selector.classes(inFolder: 'lib/domain/contracts'),
      beAbstract(),
    );
  });
}
```

**Example — repository interfaces must be abstract**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Repository interfaces must be declared abstract', (selector) {
    expect(
      selector.classes(inFolder: 'lib/domain/repositories', matching: r'^(?!.*Impl).*Repository$'),
      beAbstract(),
    );
  });
}
```

**Example — implementations must NOT be abstract (with NotPredicate)**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Repository implementations must not be abstract', (selector) {
    expect(
      selector.classes(inFolder: 'lib/data/repositories', matching: r'.*Impl$'),
      notBeAbstract(),
    );
  });
}
```

**Notes:** Abstract classes in Dart can still have concrete method implementations. This predicate checks only the `abstract` keyword on the class declaration, not whether all methods are abstract. Combine with `ImplementsPredicate` or `ExtendsPredicate` to enforce inheritance structure alongside abstractness.

---

### IsConcreteClassPredicate

Passes if the class is a regular concrete class — not abstract, not a mixin, not an enum, and not an extension type.

**Constructor**
```dart
IsConcreteClassPredicate()
```

**Parameters**

This predicate takes no parameters.

**Passes when:** the declaration is a plain `class` keyword without `abstract`, `mixin`, `enum`, or `extension type` qualifiers.

**Example — implementations folder must contain only concrete classes**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Repository implementations must be concrete classes', (selector) {
    expect(
      selector.classes(inFolder: 'lib/data/repositories', matching: r'.*Impl$'),
      beConcrete(),
    );
  });
}
```

**Example — use case classes must be concrete**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Use cases must be concrete classes, not abstract', (selector) {
    expect(
      selector.classes(inFolder: 'lib/domain/usecases'),
      beConcrete(),
    );
  });
}
```

**Notes:** This predicate is the logical complement of `IsAbstractPredicate` for regular classes, but it also excludes mixins, enums, and extensions. It is most useful when enforcing that a folder meant for implementations does not accidentally contain abstract types or other constructs. Combine with `ImplementsPredicate` to ensure concrete classes also fulfill an interface contract.

---

### IsEnumPredicate

Passes if the declaration is an `enum`.

**Constructor**
```dart
IsEnumPredicate()
```

**Parameters**

This predicate takes no parameters.

**Passes when:** the declaration uses the `enum` keyword.

**Example — enums/ folder must contain only enums**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Everything in lib/domain/enums must be an enum', (selector) {
    expect(
      selector.classes(inFolder: 'lib/domain/enums'),
      beEnum(),
    );
  });
}
```

**Example — status classes must be enums**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Classes ending with Status must be declared as enums', (selector) {
    expect(
      selector.classes(inFolder: 'lib', matching: r'.*Status$'),
      beEnum(),
    );
  });
}
```

**Notes:** Dart enhanced enums (enums with methods and fields) are also matched by this predicate. Combine with `NameEndsWithPredicate` if you want to enforce that all enum declarations in a folder follow a naming convention.

---

### IsMixinPredicate

Passes if the declaration is a `mixin`.

**Constructor**
```dart
IsMixinPredicate()
```

**Parameters**

This predicate takes no parameters.

**Passes when:** the declaration uses the `mixin` keyword.

**Example — mixins/ folder must contain only mixins**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Everything in lib/core/mixins must be a mixin', (selector) {
    expect(
      selector.classes(inFolder: 'lib/core/mixins'),
      beMixin(),
    );
  });
}
```

**Example — mixin-named classes must actually be mixins**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Classes ending with Mixin must be declared as mixins', (selector) {
    expect(
      selector.classes(inFolder: 'lib', matching: r'.*Mixin$'),
      beMixin(),
    );
  });
}
```

**Notes:** Dart 3 introduced `mixin class`, which is both a mixin and a class. Check whether your version of DartUnit treats `mixin class` as matching `IsMixinPredicate` — consult the changelog if this is relevant to your codebase.

---

### IsExtensionPredicate

Passes if the declaration is an `extension` or `extension type`.

**Constructor**
```dart
IsExtensionPredicate()
```

**Parameters**

This predicate takes no parameters.

**Passes when:** the declaration uses the `extension` keyword.

**Example — extensions/ folder must contain only extensions**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Everything in lib/core/extensions must be an extension', (selector) {
    expect(
      selector.classes(inFolder: 'lib/core/extensions'),
      beExtension(),
    );
  });
}
```

**Example — extension-named types must be extensions**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Declarations ending with Extension must use the extension keyword', (selector) {
    expect(
      selector.classes(inFolder: 'lib', matching: r'.*Extension$'),
      beExtension(),
    );
  });
}
```

**Notes:** This predicate covers both unnamed extensions (`extension on String`) and named extensions (`extension StringExtension on String`), as well as Dart 3 extension types (`extension type MyId(int _)`). Use it to enforce that a dedicated folder contains only extension declarations.

---

### ExtendsPredicate

Passes if the class extends the specified type.

**Constructor**
```dart
ExtendsPredicate(String type)
```

**Parameters**
| Parameter | Type | Description |
|-----------|------|-------------|
| `type` | `String` | The parent class name (exact match, case-sensitive) |

**Passes when:** the class declaration contains `extends <type>` and the type name matches exactly.

**Example — all event classes must extend the base event**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('All cart event classes must extend CartEvent', (selector) {
    expect(
      selector.classes(inFolder: 'lib/bloc/cart', matching: r'.*Event$'),
      extend('CartEvent'),
    );
  });
}
```

**Example — BLoC classes must extend Bloc**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Classes ending with Bloc must extend Bloc', (selector) {
    expect(
      selector.classes(inFolder: 'lib/bloc', matching: r'.*Bloc$'),
      extend('Bloc'),
    );
  });
}
```

**Example — BLoC state classes must extend Equatable**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('BLoC state classes must extend Equatable for equality', (selector) {
    expect(
      selector.classes(inFolder: 'lib/bloc', matching: r'.*State$'),
      extend('Equatable'),
    );
  });
}
```

**Notes:** The match is exact and case-sensitive — `ExtendsPredicate('Bloc')` will not match `BlocBase`. Generic type parameters are ignored, so `ExtendsPredicate('Bloc')` matches `class CartBloc extends Bloc<CartEvent, CartState>`. Combine with `OrPredicate` if a class may extend one of several valid parents.

---

### ImplementsPredicate

Passes if the class implements the specified interface.

**Constructor**
```dart
ImplementsPredicate(String type)
```

**Parameters**
| Parameter | Type | Description |
|-----------|------|-------------|
| `type` | `String` | The interface name (exact match, case-sensitive) |

**Passes when:** the class declaration contains `implements <type>` (or implements a list that includes `<type>`) and the type name matches exactly.

**Example — data repositories must implement their domain interface**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Repository implementations must implement a Repository interface', (selector) {
    expect(
      selector.classes(inFolder: 'lib/data/repositories', matching: r'.*Impl$'),
      implement('Repository'),
    );
  });
}
```

**Example — domain entities must NOT implement Serializable (with NotPredicate)**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Domain entities must not implement Serializable', (selector) {
    expect(
      selector.classes(inFolder: 'lib/domain/entities'),
      notImplement('Serializable'),
    );
  });
}
```

**Example — use cases must implement UseCase**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Use case classes must implement the UseCase interface', (selector) {
    expect(
      selector.classes(inFolder: 'lib/domain/usecases'),
      implement('UseCase'),
    );
  });
}
```

**Notes:** Like `ExtendsPredicate`, the match is exact and case-sensitive, but generic type arguments are ignored. A class can implement multiple interfaces — this predicate passes if any one of them matches. Combine with `AndPredicate` to require a class to implement multiple interfaces simultaneously.

---

### UsesMixinPredicate

Passes if the class uses or applies the specified mixin.

**Constructor**
```dart
UsesMixinPredicate(String mixin)
```

**Parameters**
| Parameter | Type | Description |
|-----------|------|-------------|
| `mixin` | `String` | The mixin name (exact match, case-sensitive) |

**Passes when:** the class declaration contains `with <mixin>` and the mixin name matches exactly.

**Example — domain entities must use EquatableMixin**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Domain entities must use EquatableMixin for value equality', (selector) {
    expect(
      selector.classes(inFolder: 'lib/domain/entities'),
      useMixin('EquatableMixin'),
    );
  });
}
```

**Example — model classes must use JsonSerializableMixin**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Data models must apply JsonSerializableMixin', (selector) {
    expect(
      selector.classes(inFolder: 'lib/data/models'),
      useMixin('JsonSerializableMixin'),
    );
  });
}
```

**Notes:** A class can apply multiple mixins — the predicate passes if any one of them matches the given name. The match is exact and case-sensitive. Combine with `AndPredicate` to require the use of multiple specific mixins.

---

## Group 4 — Annotation Predicates

### AnnotatedWithPredicate

Passes if the class carries the specified annotation.

**Constructor**
```dart
AnnotatedWithPredicate(String annotation)
```

**Parameters**
| Parameter | Type | Description |
|-----------|------|-------------|
| `annotation` | `String` | Annotation name **without** the `@` symbol (e.g., `'injectable'`, not `'@injectable'`) |

**Passes when:** the class has a `@<annotation>` annotation attached to its declaration.

**Example — injectable services must carry @injectable**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Services must be registered with the DI container via @injectable', (selector) {
    expect(
      selector.classes(inFolder: 'lib/services'),
      beAnnotatedWith('injectable'),
    );
  });
}
```

**Example — domain classes must NOT carry @JsonSerializable (with NotPredicate)**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Domain classes must not have @JsonSerializable', (selector) {
    expect(
      selector.classes(inFolder: 'lib/domain'),
      notBeAnnotatedWith('JsonSerializable'),
    );
  });
}
```

**Example — REST data sources must carry @RestApi**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Classes in data/datasources must be annotated with @RestApi', (selector) {
    expect(
      selector.classes(inFolder: 'lib/data/datasources'),
      beAnnotatedWith('RestApi'),
    );
  });
}
```

**Notes:** Do not include the `@` symbol in the annotation name parameter. The match is exact against the annotation identifier — `'injectable'` will not match `'lazySingleton'` even though both come from the same package. To require one of several possible annotations, wrap multiple `AnnotatedWithPredicate` instances in an `OrPredicate`.

---

### NotAnnotatedWithPredicate

Passes if the class does **not** carry the specified annotation. This is a built-in "must not" predicate — no wrapping in `NotPredicate` is necessary.

**Constructor**
```dart
NotAnnotatedWithPredicate(String annotation)
```

**Parameters**
| Parameter | Type | Description |
|-----------|------|-------------|
| `annotation` | `String` | Annotation name **without** the `@` symbol |

**Passes when:** the class does not have `@<annotation>` in its declaration.

**Example — production classes must not be annotated with @visibleForTesting**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Production classes in lib/ must not be annotated with @visibleForTesting', (selector) {
    expect(
      selector.classes(inFolder: 'lib'),
      notBeAnnotatedWith('visibleForTesting'),
    );
  });
}
```

**Example — domain entities must not have @HiveType**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Domain entities must not carry persistence annotations such as @HiveType', (selector) {
    expect(
      selector.classes(inFolder: 'lib/domain/entities'),
      notBeAnnotatedWith('HiveType'),
    );
  });
}
```

**Notes:** `NotAnnotatedWithPredicate('X')` is exactly equivalent to `NotPredicate(AnnotatedWithPredicate('X'))`. Prefer `NotAnnotatedWithPredicate` for clarity when the sole intent is to ban an annotation. When you need to ban an annotation as part of a compound rule, using `NotPredicate(AnnotatedWithPredicate(...))` inside an `AndPredicate` is equally valid.

---

## Group 5 — Metrics Predicates

### MaxMethodsPredicate

Passes if the class declares at most `max` methods.

**Constructor**
```dart
MaxMethodsPredicate(int max)
```

**Parameters**
| Parameter | Type | Description |
|-----------|------|-------------|
| `max` | `int` | Maximum allowed method count (inclusive). Constructors are not counted. |

**Passes when:** the number of declared methods (excluding constructors) is less than or equal to `max`.

**Example — BLoC classes must have at most 10 methods**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('BLoC classes must declare at most 10 methods to stay focused', (selector) {
    expect(
      selector.classes(inFolder: 'lib/bloc', matching: r'.*Bloc$'),
      haveAtMostMethods(10),
    );
  });
}
```

**Example — general class size limit**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Classes in lib/ must not exceed 20 methods', (selector) {
    expect(
      selector.classes(inFolder: 'lib'),
      haveAtMostMethods(20),
    );
  });
}
```

**Example — value objects should have at most 5 methods**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Value objects must be simple — at most 5 methods', (selector) {
    expect(
      selector.classes(inFolder: 'lib/domain/value_objects'),
      haveAtMostMethods(5),
    );
  });
}
```

**Notes:** Constructors (including named constructors and factory constructors) are excluded from the count. Getters and setters are typically counted as methods — verify this behavior for your version of DartUnit if you have getter-heavy classes. For the reverse constraint (a minimum number of methods), use `MinMethodsPredicate`.

---

### MinMethodsPredicate

Passes if the class declares at least `min` methods.

**Constructor**
```dart
MinMethodsPredicate(int min)
```

**Parameters**
| Parameter | Type | Description |
|-----------|------|-------------|
| `min` | `int` | Minimum required method count (inclusive). Constructors are not counted. |

**Passes when:** the number of declared methods (excluding constructors) is greater than or equal to `min`.

**Example — repository implementations must declare at least 3 methods (CRUD)**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Repository implementations must declare at least 3 methods for CRUD', (selector) {
    expect(
      selector.classes(inFolder: 'lib/data/repositories', matching: r'.*Impl$'),
      haveAtLeastMethods(3),
    );
  });
}
```

**Example — use cases must declare at least one method**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Use case classes must declare at least one method', (selector) {
    expect(
      selector.classes(inFolder: 'lib/domain/usecases'),
      haveAtLeastMethods(1),
    );
  });
}
```

**Notes:** This predicate is useful for catching empty or placeholder classes. Combine `MinMethodsPredicate` and `MaxMethodsPredicate` inside an `AndPredicate` to enforce a specific method count range.

---

### MaxFieldsPredicate

Passes if the class declares at most `max` instance fields.

**Constructor**
```dart
MaxFieldsPredicate(int max)
```

**Parameters**
| Parameter | Type | Description |
|-----------|------|-------------|
| `max` | `int` | Maximum allowed field count (inclusive). Static fields are not counted. |

**Passes when:** the number of declared instance fields is less than or equal to `max`.

**Example — value objects should have at most 5 fields**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Value objects should be simple — at most 5 fields', (selector) {
    expect(
      selector.classes(inFolder: 'lib/domain/value_objects'),
      haveAtMostFields(5),
    );
  });
}
```

**Example — entities must not become God objects**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Domain entities must not declare more than 10 fields', (selector) {
    expect(
      selector.classes(inFolder: 'lib/domain/entities'),
      haveAtMostFields(10),
    );
  });
}
```

**Notes:** Static fields and class-level constants are excluded from the count. Only instance fields (whether `final`, `late`, or mutable) are counted. Combine with `HasAllFinalFieldsPredicate` to enforce both field count and immutability simultaneously.

---

### MinFieldsPredicate

Passes if the class declares at least `min` instance fields.

**Constructor**
```dart
MinFieldsPredicate(int min)
```

**Parameters**
| Parameter | Type | Description |
|-----------|------|-------------|
| `min` | `int` | Minimum required field count (inclusive). Static fields are not counted. |

**Passes when:** the number of declared instance fields is greater than or equal to `min`.

**Example — entities must have at least one field (an id)**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Domain entities must declare at least 1 field (e.g., an id)', (selector) {
    expect(
      selector.classes(inFolder: 'lib/domain/entities'),
      haveAtLeastFields(1),
    );
  });
}
```

**Example — data models must have at least 2 fields**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Data models must declare at least 2 fields', (selector) {
    expect(
      selector.classes(inFolder: 'lib/data/models'),
      haveAtLeastFields(2),
    );
  });
}
```

**Notes:** This predicate helps catch empty shell classes that were created but never filled in. Static fields are excluded. Combine `MinFieldsPredicate` and `MaxFieldsPredicate` inside an `AndPredicate` to specify an acceptable range.

---

### MaxImportsPredicate

Passes if the class file has at most `max` import directives.

**Constructor**
```dart
MaxImportsPredicate(int max)
```

**Parameters**
| Parameter | Type | Description |
|-----------|------|-------------|
| `max` | `int` | Maximum allowed number of import directives in the file (inclusive) |

**Passes when:** the total number of `import` statements in the file is less than or equal to `max`. Both package imports and relative imports are counted.

**Example — domain entities should have at most 3 imports (low coupling)**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Domain entities must have at most 3 imports to keep coupling low', (selector) {
    expect(
      selector.classes(inFolder: 'lib/domain/entities'),
      haveAtMostImports(3),
    );
  });
}
```

**Example — high import count flags God Classes**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Classes with more than 15 imports are likely God Classes', (selector) {
    expect(
      selector.classes(inFolder: 'lib'),
      haveAtMostImports(15),
    );
  });
}
```

**Example — use case files should stay focused (at most 5 imports)**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Use case files must not exceed 5 imports', (selector) {
    expect(
      selector.classes(inFolder: 'lib/domain/usecases'),
      haveAtMostImports(5),
    );
  });
}
```

**Notes:** All `import` directives in the file are counted, including `dart:` and `package:` imports, as well as relative path imports. A high import count is a strong signal of poor separation of concerns. Combine with `OnlyDependOnFoldersPredicate` to enforce both import count and import scope.

---

## Group 6 — Quality and Structure Predicates

### HasAllFinalFieldsPredicate

Passes if every instance field in the class is declared `final` or `const`.

**Constructor**
```dart
HasAllFinalFieldsPredicate()
```

**Parameters**

This predicate takes no parameters.

**Passes when:** all instance fields have the `final` or `const` modifier. Static fields are excluded from the check.

**Example — BLoC states must be fully immutable**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('BLoC state classes must have all final fields for immutability', (selector) {
    expect(
      selector.classes(inFolder: 'lib/bloc', matching: r'.*State$'),
      haveAllFinalFields(),
    );
  });
}
```

**Example — domain entities must be immutable**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Domain entities must be immutable — all fields must be final', (selector) {
    expect(
      selector.classes(inFolder: 'lib/domain/entities'),
      haveAllFinalFields(),
    );
  });
}
```

**Example — value objects must be immutable**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Value objects must have all final fields', (selector) {
    expect(
      selector.classes(inFolder: 'lib/domain/value_objects'),
      haveAllFinalFields(),
    );
  });
}
```

**Notes:** `late final` fields are still considered `final` and pass this predicate. A class with zero fields passes vacuously. Combine with `MaxFieldsPredicate` to enforce both immutability and a field count ceiling. To require immutability via annotation instead, use `AnnotatedWithPredicate('immutable')` (from the `meta` package).

---

### HasNoPublicFieldsPredicate

Passes if the class has no public instance fields — i.e., every field name starts with an underscore.

**Constructor**
```dart
HasNoPublicFieldsPredicate()
```

**Parameters**

This predicate takes no parameters.

**Passes when:** there are no instance fields whose names do not start with `_`. Static fields are excluded.

**Example — services must not expose internal state**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Service classes must not expose public fields — use methods instead', (selector) {
    expect(
      selector.classes(inFolder: 'lib/services'),
      haveNoPublicFields(),
    );
  });
}
```

**Example — BLoC classes must not expose public fields**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('BLoC classes must not expose public fields', (selector) {
    expect(
      selector.classes(inFolder: 'lib/bloc'),
      haveNoPublicFields(),
    );
  });
}
```

**Notes:** This predicate enforces encapsulation by requiring all mutable state to be private. Public `final` fields (used in value objects or DTOs) also fail this check — if public final fields are intentional, do not apply this predicate to those classes. A class with no instance fields at all passes vacuously.

---

### HasNoPublicMethodsPredicate

Passes if the class has no public methods — i.e., every method name starts with an underscore.

**Constructor**
```dart
HasNoPublicMethodsPredicate()
```

**Parameters**

This predicate takes no parameters.

**Passes when:** there are no methods whose names do not start with `_`. Constructors and overridden operators are typically excluded.

**Example — internal utility classes should have no public API**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Classes in lib/internal must expose no public methods', (selector) {
    expect(
      selector.classes(inFolder: 'lib/internal'),
      haveNoPublicMethods(),
    );
  });
}
```

**Example — helper classes in a sealed module should be fully private**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Helper classes must not expose a public API', (selector) {
    expect(
      selector.classes(inFolder: 'lib/helpers', matching: r'.*Helper$'),
      haveNoPublicMethods(),
    );
  });
}
```

**Notes:** This predicate is relatively uncommon — classes with no public methods are the exception rather than the rule. It is most useful for enforcing that certain implementation-detail classes remain completely internal. A class with no methods at all passes vacuously.

---

### HasMethodPredicate

Passes if the class declares a method with the exact given name.

**Constructor**
```dart
HasMethodPredicate(String methodName)
```

**Parameters**
| Parameter | Type | Description |
|-----------|------|-------------|
| `methodName` | `String` | Exact name of the method that must be present (case-sensitive) |

**Passes when:** the class body contains a method declaration with the name equal to `methodName`.

**Example — repository implementations must declare a 'dispose' method**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Repository implementations must declare a dispose() method for cleanup', (selector) {
    expect(
      selector.classes(inFolder: 'lib/data/repositories', matching: r'.*Impl$'),
      haveMethod('dispose'),
    );
  });
}
```

**Example — use cases must declare a 'call' method**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Use case classes must declare a call() method as their primary entry point', (selector) {
    expect(
      selector.classes(inFolder: 'lib/domain/usecases'),
      haveMethod('call'),
    );
  });
}
```

**Example — entities should expose a copyWith method**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Domain entities should declare a copyWith() method', (selector) {
    expect(
      selector.classes(inFolder: 'lib/domain/entities'),
      haveMethod('copyWith'),
    );
  });
}
```

**Notes:** The match is on the method _name_ only, not the signature. Overloads and methods with different parameter lists are all matched by the same name. To require one of several method names, wrap multiple `HasMethodPredicate` instances in an `OrPredicate`.

---

### FileContentMatchesPredicate

Passes if the file's raw source content matches the given regular expression pattern. **Must be used with `FileSelector`**, not `ClassSelector`.

**Constructor**
```dart
FileContentMatchesPredicate(String pattern, {String? description})
```

**Parameters**
| Parameter | Type | Description |
|-----------|------|-------------|
| `pattern` | `String` | Dart regex matched against the full raw text of the file |
| `description` | `String?` | Optional human-readable label used in violation messages to describe what the pattern detects |

**Passes when:** the file's content contains at least one match for `pattern`. Typically used with `NotPredicate` to ban patterns.

**Example — no print() calls in production code (with NotPredicate)**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('No print() calls allowed in production code', (selector) {
    expect(
      selector.files(inFolder: 'lib'),
      notMatchContent(r'print\s*\('),
    );
  });
}
```

**Example — no hardcoded URLs (with NotPredicate)**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Hardcoded HTTP URLs must not appear in production code', (selector) {
    expect(
      selector.files(inFolder: 'lib'),
      notMatchContent(r'https?://[^\s\'"]+'),
    );
  });
}
```

**Example — no TODO comments in production code (with NotPredicate)**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('TODO comments must not remain in production code', (selector) {
    expect(
      selector.files(inFolder: 'lib'),
      notMatchContent(r'//\s*TODO'),
    );
  });
}
```

**Notes:** This is the only predicate that operates at the _file_ level rather than the _class_ level — it must be paired with `FileSelector`. The regex is matched against the entire raw file content as a single string, so multiline patterns and `^`/`$` anchors behave accordingly. The `description` parameter enriches the violation message and is especially useful when the regex is complex.

---

## Group 7 — Composite Predicates

### NotPredicate

Logical negation: passes when the inner predicate _fails_, and fails when the inner predicate _passes_.

**Constructor**
```dart
NotPredicate(Predicate inner)
```

**Parameters**
| Parameter | Type | Description |
|-----------|------|-------------|
| `inner` | `Predicate` | The predicate whose result is negated |

**Passes when:** `inner` fails on the subject element. When `inner` passes (meaning the violation condition is true), `NotPredicate` fails and reports the violation using the inner predicate's pass message as the detail.

**Example — domain must not import from the data layer**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Domain layer must not import from the data layer', (selector) {
    expect(
      selector.classes(inFolder: 'lib/domain'),
      doesNotDependOn('lib/data'),
    );
  });
}
```

**Example — production code must not be annotated with @deprecated**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Production classes must not use @deprecated', (selector) {
    expect(
      selector.classes(inFolder: 'lib'),
      notBeAnnotatedWith('deprecated'),
    );
  });
}
```

**Example — convenience method syntax**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Domain layer must not have circular dependencies', (selector) {
    expect(
      selector.classes(inFolder: 'lib/domain'),
      hasNoCircularDependencies(),
    );
  });
}
```

**Notes:** `NotPredicate` is the primary mechanism for expressing "must not" rules from any positive predicate. Every predicate also exposes a `.not()` convenience method that produces an equivalent `NotPredicate`. When the violation message reports a failure from `NotPredicate`, it includes the inner predicate's description of the passing condition so the message is still actionable.

---

### AndPredicate

Passes only when **all** inner predicates pass. Evaluation is short-circuit: stops at the first failure and reports that failure.

**Constructor**
```dart
AndPredicate(List<Predicate> predicates)
```

**Parameters**
| Parameter | Type | Description |
|-----------|------|-------------|
| `predicates` | `List<Predicate>` | The list of predicates that must all pass. Evaluated in order. |

**Passes when:** every predicate in `predicates` returns a pass result for the subject. The first failing predicate short-circuits and its failure message is reported.

**Example — class must end with 'Repository' AND be abstract**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch(
    'Repository interfaces must be abstract and named with the Repository suffix',
    (selector) {
      expect(
        selector.classes(inFolder: 'lib/domain/repositories'),
        haveNameEndingWith('Repository').and(beAbstract()),
      );
    },
  );
}
```

**Example — services must satisfy multiple structural constraints**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch(
    'Services must be named correctly, injectable, and have no public fields',
    (selector) {
      expect(
        selector.classes(inFolder: 'lib/services'),
        haveNameEndingWith('Service')
            .and(beAnnotatedWith('injectable'))
            .and(haveNoPublicFields())
            .and(doesNotDependOn('lib/presentation')),
      );
    },
  );
}
```

**Example — convenience method syntax**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch(
    'Repository implementations must be named correctly and be concrete',
    (selector) {
      expect(
        selector.classes(inFolder: 'lib/data/repositories'),
        haveNameEndingWith('Impl').and(beConcrete()),
      );
    },
  );
}
```

**Notes:** `AndPredicate` short-circuits on the first failure, so the order of predicates can affect which error message is reported. Put the most descriptive or most likely to fail predicate first. The `.and(other)` convenience method on any predicate produces an equivalent two-predicate `AndPredicate`.

---

### OrPredicate

Passes when **at least one** inner predicate passes. Evaluation is short-circuit: stops at the first success.

**Constructor**
```dart
OrPredicate(List<Predicate> predicates)
```

**Parameters**
| Parameter | Type | Description |
|-----------|------|-------------|
| `predicates` | `List<Predicate>` | The list of predicates; at least one must pass. Evaluated in order. |

**Passes when:** at least one predicate in `predicates` returns a pass result for the subject. On complete failure (all predicates fail), the combined failure messages from all predicates are reported together.

**Example — class must end with 'Bloc' OR 'Cubit'**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('State management classes must end with Bloc or Cubit', (selector) {
    expect(
      selector.classes(inFolder: 'lib/bloc'),
      haveNameEndingWith('Bloc').or(haveNameEndingWith('Cubit')),
    );
  });
}
```

**Example — use cases may implement UseCase or be callable (execute or call method)**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch(
    'Use cases must implement UseCase or declare an execute/call method',
    (selector) {
      expect(
        selector.classes(inFolder: 'lib/domain/usecases'),
        implement('UseCase').or(haveMethod('execute')).or(haveMethod('call')),
      );
    },
  );
}
```

**Example — convenience method syntax**
```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('State management classes may end with Bloc, Cubit, or Controller', (selector) {
    expect(
      selector.classes(inFolder: 'lib/state'),
      haveNameEndingWith('Bloc')
          .or(haveNameEndingWith('Cubit'))
          .or(haveNameEndingWith('Controller')),
    );
  });
}
```

**Notes:** `OrPredicate` short-circuits on the first passing predicate, so arrange predicates in order of how likely they are to match to minimize evaluations. When all predicates fail, the violation message combines all individual failure details to help diagnose which condition was closest to passing. The `.or(other)` convenience method on any predicate produces an equivalent two-predicate `OrPredicate`.

---

## Quick Reference

| Predicate | Group | Common use |
|-----------|-------|------------|
| `DependOnFolderPredicate` | Dependency | Enforce or ban imports from a folder |
| `DependOnPackagePredicate` | Dependency | Enforce or ban package dependencies |
| `OnlyDependOnFoldersPredicate` | Dependency | Whitelist allowed imports |
| `HasCircularDependencyPredicate` | Dependency | Detect import cycles (use with `NotPredicate`) |
| `NameStartsWithPredicate` | Naming | Enforce a prefix convention |
| `NameEndsWithPredicate` | Naming | Enforce a suffix convention |
| `NameContainsPredicate` | Naming | Require a keyword in the name |
| `NameMatchesPatternPredicate` | Naming | Full regex naming convention |
| `IsAbstractPredicate` | Type | Require abstract declaration |
| `IsConcreteClassPredicate` | Type | Require concrete class |
| `IsEnumPredicate` | Type | Require enum declaration |
| `IsMixinPredicate` | Type | Require mixin declaration |
| `IsExtensionPredicate` | Type | Require extension declaration |
| `ExtendsPredicate` | Type | Require a specific parent class |
| `ImplementsPredicate` | Type | Require a specific interface |
| `UsesMixinPredicate` | Type | Require a specific mixin |
| `AnnotatedWithPredicate` | Annotation | Require an annotation |
| `NotAnnotatedWithPredicate` | Annotation | Ban an annotation |
| `MaxMethodsPredicate` | Metrics | Cap method count |
| `MinMethodsPredicate` | Metrics | Require minimum methods |
| `MaxFieldsPredicate` | Metrics | Cap field count |
| `MinFieldsPredicate` | Metrics | Require minimum fields |
| `MaxImportsPredicate` | Metrics | Cap import count |
| `HasAllFinalFieldsPredicate` | Quality | Enforce immutability |
| `HasNoPublicFieldsPredicate` | Quality | Enforce encapsulation |
| `HasNoPublicMethodsPredicate` | Quality | Require fully private API |
| `HasMethodPredicate` | Quality | Require a specific method |
| `FileContentMatchesPredicate` | Quality | Pattern-match raw file content |
| `NotPredicate` | Composite | Logical negation |
| `AndPredicate` | Composite | All must pass |
| `OrPredicate` | Composite | At least one must pass |
