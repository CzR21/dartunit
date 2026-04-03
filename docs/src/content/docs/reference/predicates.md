---
title: Predicates Reference
description: Complete reference for all 28 built-in predicates. Each predicate defines a positive condition — use NotPredicate to invert.
sidebar:
  order: 1
---

All predicates implement the `Predicate` interface and follow the **positive condition model**: a predicate describes the condition that a compliant element satisfies. When the condition is met, the predicate **passes**. When you need to enforce the _absence_ of a condition, wrap the predicate in `NotPredicate`.

Every predicate is used inside an `ArchitectureRule`:

```dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(args, myRule);

final myRule = ArchitectureRule(
  description: 'Human-readable description of what is enforced',
  severity: RuleSeverity.error,
  selector: ClassSelector(folder: 'lib/domain'),
  predicate: SomePredicate(),
);
```

Predicates also expose three **convenience methods** for inline composition:

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

void main(List<String> args) => archTest(args, blocMustUseRepositories);

final blocMustUseRepositories = ArchitectureRule(
  description: 'BLoC classes must depend on the repository layer',
  severity: RuleSeverity.error,
  selector: ClassSelector(folder: 'lib/bloc', namePattern: r'.*Bloc$'),
  predicate: DependOnFolderPredicate('lib/domain/repositories'),
);
```

**Example — domain must NOT import from presentation (with NotPredicate)**
```dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(args, domainFreeFromPresentation);

final domainFreeFromPresentation = ArchitectureRule(
  description: 'Domain layer must not import from the presentation layer',
  severity: RuleSeverity.critical,
  selector: ClassSelector(folder: 'lib/domain'),
  predicate: NotPredicate(DependOnFolderPredicate('lib/presentation')),
);
```

**Example — data repositories must import from domain**
```dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(args, repoImplsDependOnDomain);

final repoImplsDependOnDomain = ArchitectureRule(
  description: 'Repository implementations must depend on the domain layer',
  severity: RuleSeverity.error,
  selector: ClassSelector(folder: 'lib/data/repositories', namePattern: r'.*Impl$'),
  predicate: DependOnFolderPredicate('lib/domain'),
);
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

void main(List<String> args) => archTest(args, presentationUsesFlutterBloc);

final presentationUsesFlutterBloc = ArchitectureRule(
  description: 'Presentation widgets must use flutter_bloc for state management',
  severity: RuleSeverity.warning,
  selector: ClassSelector(folder: 'lib/presentation/pages'),
  predicate: DependOnPackagePredicate('flutter_bloc'),
);
```

**Example — domain must NOT import Flutter (with NotPredicate)**
```dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(args, domainNoFlutter);

final domainNoFlutter = ArchitectureRule(
  description: 'Domain layer must not depend on Flutter',
  severity: RuleSeverity.critical,
  selector: ClassSelector(folder: 'lib/domain'),
  predicate: NotPredicate(DependOnPackagePredicate('flutter')),
);
```

**Example — domain must NOT use Dio (with NotPredicate)**
```dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(args, domainNoDio);

final domainNoDio = ArchitectureRule(
  description: 'Domain layer must not use HTTP client packages',
  severity: RuleSeverity.error,
  selector: ClassSelector(folder: 'lib/domain'),
  predicate: NotPredicate(DependOnPackagePredicate('dio')),
);
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

void main(List<String> args) => archTest(args, domainIsolation);

final domainIsolation = ArchitectureRule(
  description: 'Domain layer may only import from itself and shared core',
  severity: RuleSeverity.error,
  selector: ClassSelector(folder: 'lib/domain'),
  predicate: OnlyDependOnFoldersPredicate([
    'lib/domain',
    'lib/shared',
    'lib/core',
  ]),
);
```

**Example — utility classes can only import from Dart core paths**
```dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(args, utilsNoDomainImports);

final utilsNoDomainImports = ArchitectureRule(
  description: 'Utility classes must not import from any application layer',
  severity: RuleSeverity.warning,
  selector: ClassSelector(folder: 'lib/utils'),
  predicate: OnlyDependOnFoldersPredicate(['lib/utils']),
);
```

**Example — data layer strict boundaries**
```dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(args, dataLayerBoundaries);

final dataLayerBoundaries = ArchitectureRule(
  description: 'Data layer may only depend on domain and its own folders',
  severity: RuleSeverity.error,
  selector: ClassSelector(folder: 'lib/data'),
  predicate: OnlyDependOnFoldersPredicate([
    'lib/data',
    'lib/domain',
  ]),
);
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

void main(List<String> args) => archTest(args, noCircularDeps);

final noCircularDeps = ArchitectureRule(
  description: 'No circular dependencies are allowed anywhere in lib/',
  severity: RuleSeverity.critical,
  selector: ClassSelector(folder: 'lib'),
  predicate: NotPredicate(HasCircularDependencyPredicate()),
);
```

**Example — enforce no cycles scoped to domain**
```dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(args, noDomainCycles);

final noDomainCycles = ArchitectureRule(
  description: 'Domain layer must have no circular dependencies',
  severity: RuleSeverity.error,
  selector: ClassSelector(folder: 'lib/domain'),
  predicate: NotPredicate(HasCircularDependencyPredicate()),
);
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

void main(List<String> args) => archTest(args, interfacePrefix);

final interfacePrefix = ArchitectureRule(
  description: 'Interface classes in contracts/ must be prefixed with I',
  severity: RuleSeverity.warning,
  selector: ClassSelector(folder: 'lib/domain/contracts'),
  predicate: NameStartsWithPredicate('I'),
);
```

**Example — abstract base classes must start with 'Abstract'**
```dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(args, abstractBasePrefix);

final abstractBasePrefix = ArchitectureRule(
  description: 'Abstract base classes must be prefixed with Abstract',
  severity: RuleSeverity.warning,
  selector: ClassSelector(
    folder: 'lib/core/base',
    annotatedWith: 'baseClass',
  ),
  predicate: NameStartsWithPredicate('Abstract'),
);
```

**Example — mock classes in test must start with 'Mock' (with NotPredicate to prevent leaking)**
```dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(args, noMocksInLib);

final noMocksInLib = ArchitectureRule(
  description: 'Classes starting with Mock must not appear in lib/',
  severity: RuleSeverity.error,
  selector: ClassSelector(folder: 'lib'),
  predicate: NotPredicate(NameStartsWithPredicate('Mock')),
);
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

void main(List<String> args) => archTest(args, repositorySuffix);

final repositorySuffix = ArchitectureRule(
  description: 'All classes in domain/repositories must end with Repository',
  severity: RuleSeverity.error,
  selector: ClassSelector(folder: 'lib/domain/repositories'),
  predicate: NameEndsWithPredicate('Repository'),
);
```

**Example — test doubles must not end with 'Service' in production folders (with NotPredicate)**
```dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(args, noFakeServicesInLib);

final noFakeServicesInLib = ArchitectureRule(
  description: 'Classes ending with FakeService must not appear in lib/',
  severity: RuleSeverity.error,
  selector: ClassSelector(folder: 'lib', namePattern: r'^Fake.*'),
  predicate: NotPredicate(NameEndsWithPredicate('Service')),
);
```

**Example — state management classes may end with Bloc or Cubit (with OrPredicate)**
```dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(args, stateManagementSuffix);

final stateManagementSuffix = ArchitectureRule(
  description: 'State management classes must end with Bloc or Cubit',
  severity: RuleSeverity.warning,
  selector: ClassSelector(folder: 'lib/bloc'),
  predicate: NameEndsWithPredicate('Bloc').or(NameEndsWithPredicate('Cubit')),
);
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

void main(List<String> args) => archTest(args, cartFeatureNaming);

final cartFeatureNaming = ArchitectureRule(
  description: 'All classes in the cart feature must reference Cart in their name',
  severity: RuleSeverity.warning,
  selector: ClassSelector(folder: 'lib/features/cart'),
  predicate: NameContainsPredicate('Cart'),
);
```

**Example — production classes must not contain 'Mock' (with NotPredicate)**
```dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(args, noMockInProduction);

final noMockInProduction = ArchitectureRule(
  description: 'Production classes must not contain Mock in their name',
  severity: RuleSeverity.error,
  selector: ClassSelector(folder: 'lib'),
  predicate: NotPredicate(NameContainsPredicate('Mock')),
);
```

**Example — mapper classes must contain 'Mapper'**
```dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(args, mapperNaming);

final mapperNaming = ArchitectureRule(
  description: 'Classes in data/mappers must contain Mapper in their name',
  severity: RuleSeverity.warning,
  selector: ClassSelector(folder: 'lib/data/mappers'),
  predicate: NameContainsPredicate('Mapper'),
);
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

void main(List<String> args) => archTest(args, blocNamingConvention);

final blocNamingConvention = ArchitectureRule(
  description: 'BLoC classes must match ^[A-Z][a-zA-Z]+Bloc$',
  severity: RuleSeverity.warning,
  selector: ClassSelector(folder: 'lib/bloc'),
  predicate: NameMatchesPatternPredicate(r'^[A-Z][a-zA-Z]+Bloc$'),
);
```

**Example — abstract base classes must start with Abstract or Base**
```dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(args, abstractBaseNaming);

final abstractBaseNaming = ArchitectureRule(
  description: 'Abstract base classes must start with Abstract or Base',
  severity: RuleSeverity.warning,
  selector: ClassSelector(folder: 'lib/core/base'),
  predicate: NameMatchesPatternPredicate(r'^(Abstract|Base)[A-Z].*'),
);
```

**Example — entity classes must follow PascalCase followed by Entity**
```dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(args, entityNaming);

final entityNaming = ArchitectureRule(
  description: 'Domain entities must match the ^[A-Z][a-zA-Z]+Entity$ pattern',
  severity: RuleSeverity.warning,
  selector: ClassSelector(folder: 'lib/domain/entities'),
  predicate: NameMatchesPatternPredicate(r'^[A-Z][a-zA-Z]+Entity$'),
);
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

void main(List<String> args) => archTest(args, contractsMustBeAbstract);

final contractsMustBeAbstract = ArchitectureRule(
  description: 'All classes in domain/contracts must be declared abstract',
  severity: RuleSeverity.error,
  selector: ClassSelector(folder: 'lib/domain/contracts'),
  predicate: IsAbstractPredicate(),
);
```

**Example — repository interfaces must be abstract**
```dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(args, repositoryInterfacesMustBeAbstract);

final repositoryInterfacesMustBeAbstract = ArchitectureRule(
  description: 'Repository interfaces must be declared abstract',
  severity: RuleSeverity.error,
  selector: ClassSelector(
    folder: 'lib/domain/repositories',
    namePattern: r'^(?!.*Impl).*Repository$',
  ),
  predicate: IsAbstractPredicate(),
);
```

**Example — implementations must NOT be abstract (with NotPredicate)**
```dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(args, implsMustNotBeAbstract);

final implsMustNotBeAbstract = ArchitectureRule(
  description: 'Repository implementations must not be abstract',
  severity: RuleSeverity.error,
  selector: ClassSelector(folder: 'lib/data/repositories', namePattern: r'.*Impl$'),
  predicate: NotPredicate(IsAbstractPredicate()),
);
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

void main(List<String> args) => archTest(args, implementationsMustBeConcrete);

final implementationsMustBeConcrete = ArchitectureRule(
  description: 'Repository implementations must be concrete classes',
  severity: RuleSeverity.error,
  selector: ClassSelector(folder: 'lib/data/repositories', namePattern: r'.*Impl$'),
  predicate: IsConcreteClassPredicate(),
);
```

**Example — use case classes must be concrete**
```dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(args, useCasesMustBeConcrete);

final useCasesMustBeConcrete = ArchitectureRule(
  description: 'Use cases must be concrete classes, not abstract',
  severity: RuleSeverity.error,
  selector: ClassSelector(folder: 'lib/domain/usecases'),
  predicate: IsConcreteClassPredicate(),
);
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

void main(List<String> args) => archTest(args, enumsFolderOnlyEnums);

final enumsFolderOnlyEnums = ArchitectureRule(
  description: 'Everything in lib/domain/enums must be an enum',
  severity: RuleSeverity.error,
  selector: ClassSelector(folder: 'lib/domain/enums'),
  predicate: IsEnumPredicate(),
);
```

**Example — status classes must be enums**
```dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(args, statusMustBeEnum);

final statusMustBeEnum = ArchitectureRule(
  description: 'Classes ending with Status must be declared as enums',
  severity: RuleSeverity.warning,
  selector: ClassSelector(folder: 'lib', namePattern: r'.*Status$'),
  predicate: IsEnumPredicate(),
);
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

void main(List<String> args) => archTest(args, mixinsFolderOnlyMixins);

final mixinsFolderOnlyMixins = ArchitectureRule(
  description: 'Everything in lib/core/mixins must be a mixin',
  severity: RuleSeverity.error,
  selector: ClassSelector(folder: 'lib/core/mixins'),
  predicate: IsMixinPredicate(),
);
```

**Example — mixin-named classes must actually be mixins**
```dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(args, mixinNameMustBeMixin);

final mixinNameMustBeMixin = ArchitectureRule(
  description: 'Classes ending with Mixin must be declared as mixins',
  severity: RuleSeverity.warning,
  selector: ClassSelector(folder: 'lib', namePattern: r'.*Mixin$'),
  predicate: IsMixinPredicate(),
);
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

void main(List<String> args) => archTest(args, extensionsFolderOnlyExtensions);

final extensionsFolderOnlyExtensions = ArchitectureRule(
  description: 'Everything in lib/core/extensions must be an extension',
  severity: RuleSeverity.error,
  selector: ClassSelector(folder: 'lib/core/extensions'),
  predicate: IsExtensionPredicate(),
);
```

**Example — extension-named types must be extensions**
```dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(args, extensionNamingConvention);

final extensionNamingConvention = ArchitectureRule(
  description: 'Declarations ending with Extension must use the extension keyword',
  severity: RuleSeverity.warning,
  selector: ClassSelector(folder: 'lib', namePattern: r'.*Extension$'),
  predicate: IsExtensionPredicate(),
);
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

void main(List<String> args) => archTest(args, cartEventsMustExtendBase);

final cartEventsMustExtendBase = ArchitectureRule(
  description: 'All cart event classes must extend CartEvent',
  severity: RuleSeverity.error,
  selector: ClassSelector(folder: 'lib/bloc/cart', namePattern: r'.*Event$'),
  predicate: ExtendsPredicate('CartEvent'),
);
```

**Example — BLoC classes must extend Bloc**
```dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(args, blocsMustExtendBloc);

final blocsMustExtendBloc = ArchitectureRule(
  description: 'Classes ending with Bloc must extend Bloc',
  severity: RuleSeverity.error,
  selector: ClassSelector(folder: 'lib/bloc', namePattern: r'.*Bloc$'),
  predicate: ExtendsPredicate('Bloc'),
);
```

**Example — BLoC state classes must extend Equatable**
```dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(args, statesMustExtendEquatable);

final statesMustExtendEquatable = ArchitectureRule(
  description: 'BLoC state classes must extend Equatable for equality',
  severity: RuleSeverity.warning,
  selector: ClassSelector(folder: 'lib/bloc', namePattern: r'.*State$'),
  predicate: ExtendsPredicate('Equatable'),
);
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

void main(List<String> args) => archTest(args, repoImplsImplementInterface);

final repoImplsImplementInterface = ArchitectureRule(
  description: 'Repository implementations must implement a Repository interface',
  severity: RuleSeverity.error,
  selector: ClassSelector(folder: 'lib/data/repositories', namePattern: r'.*Impl$'),
  predicate: ImplementsPredicate('Repository'),
);
```

**Example — domain entities must NOT implement Serializable (with NotPredicate)**
```dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(args, domainEntitiesNoSerializable);

final domainEntitiesNoSerializable = ArchitectureRule(
  description: 'Domain entities must not implement Serializable',
  severity: RuleSeverity.error,
  selector: ClassSelector(folder: 'lib/domain/entities'),
  predicate: NotPredicate(ImplementsPredicate('Serializable')),
);
```

**Example — use cases must implement UseCase**
```dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(args, useCasesMustImplementInterface);

final useCasesMustImplementInterface = ArchitectureRule(
  description: 'Use case classes must implement the UseCase interface',
  severity: RuleSeverity.error,
  selector: ClassSelector(folder: 'lib/domain/usecases'),
  predicate: ImplementsPredicate('UseCase'),
);
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

void main(List<String> args) => archTest(args, entitiesMustUseEquatable);

final entitiesMustUseEquatable = ArchitectureRule(
  description: 'Domain entities must use EquatableMixin for value equality',
  severity: RuleSeverity.warning,
  selector: ClassSelector(folder: 'lib/domain/entities'),
  predicate: UsesMixinPredicate('EquatableMixin'),
);
```

**Example — model classes must use JsonSerializableMixin**
```dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(args, modelsMustUseJsonMixin);

final modelsMustUseJsonMixin = ArchitectureRule(
  description: 'Data models must apply JsonSerializableMixin',
  severity: RuleSeverity.warning,
  selector: ClassSelector(folder: 'lib/data/models'),
  predicate: UsesMixinPredicate('JsonSerializableMixin'),
);
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

void main(List<String> args) => archTest(args, servicesMustBeInjectable);

final servicesMustBeInjectable = ArchitectureRule(
  description: 'Services must be registered with the DI container via @injectable',
  severity: RuleSeverity.warning,
  selector: ClassSelector(folder: 'lib/services'),
  predicate: AnnotatedWithPredicate('injectable'),
);
```

**Example — domain classes must NOT carry @JsonSerializable (with NotPredicate)**
```dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(args, domainNoJsonSerializable);

final domainNoJsonSerializable = ArchitectureRule(
  description: 'Domain classes must not have @JsonSerializable — keep serialization in data layer',
  severity: RuleSeverity.error,
  selector: ClassSelector(folder: 'lib/domain'),
  predicate: NotPredicate(AnnotatedWithPredicate('JsonSerializable')),
);
```

**Example — REST data sources must carry @RestApi**
```dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(args, dataSourcesMustHaveRestApi);

final dataSourcesMustHaveRestApi = ArchitectureRule(
  description: 'Classes in data/datasources must be annotated with @RestApi',
  severity: RuleSeverity.error,
  selector: ClassSelector(folder: 'lib/data/datasources'),
  predicate: AnnotatedWithPredicate('RestApi'),
);
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

void main(List<String> args) => archTest(args, noVisibleForTestingInProd);

final noVisibleForTestingInProd = ArchitectureRule(
  description: 'Production classes in lib/ must not be annotated with @visibleForTesting',
  severity: RuleSeverity.warning,
  selector: ClassSelector(folder: 'lib'),
  predicate: NotAnnotatedWithPredicate('visibleForTesting'),
);
```

**Example — domain entities must not have @HiveType**
```dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(args, domainEntitiesNoHiveType);

final domainEntitiesNoHiveType = ArchitectureRule(
  description: 'Domain entities must not carry persistence annotations such as @HiveType',
  severity: RuleSeverity.error,
  selector: ClassSelector(folder: 'lib/domain/entities'),
  predicate: NotAnnotatedWithPredicate('HiveType'),
);
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

void main(List<String> args) => archTest(args, blocMethodLimit);

final blocMethodLimit = ArchitectureRule(
  description: 'BLoC classes must declare at most 10 methods to stay focused',
  severity: RuleSeverity.warning,
  selector: ClassSelector(folder: 'lib/bloc', namePattern: r'.*Bloc$'),
  predicate: MaxMethodsPredicate(10),
);
```

**Example — general class size limit**
```dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(args, classMethodLimit);

final classMethodLimit = ArchitectureRule(
  description: 'Classes in lib/ must not exceed 20 methods',
  severity: RuleSeverity.info,
  selector: ClassSelector(folder: 'lib'),
  predicate: MaxMethodsPredicate(20),
);
```

**Example — value objects should have at most 5 methods**
```dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(args, valueObjectMethodLimit);

final valueObjectMethodLimit = ArchitectureRule(
  description: 'Value objects must be simple — at most 5 methods',
  severity: RuleSeverity.warning,
  selector: ClassSelector(folder: 'lib/domain/value_objects'),
  predicate: MaxMethodsPredicate(5),
);
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

void main(List<String> args) => archTest(args, repoMinMethods);

final repoMinMethods = ArchitectureRule(
  description: 'Repository implementations must declare at least 3 methods for CRUD operations',
  severity: RuleSeverity.error,
  selector: ClassSelector(folder: 'lib/data/repositories', namePattern: r'.*Impl$'),
  predicate: MinMethodsPredicate(3),
);
```

**Example — use cases must declare at least one method**
```dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(args, useCaseMinMethods);

final useCaseMinMethods = ArchitectureRule(
  description: 'Use case classes must declare at least one method',
  severity: RuleSeverity.error,
  selector: ClassSelector(folder: 'lib/domain/usecases'),
  predicate: MinMethodsPredicate(1),
);
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

void main(List<String> args) => archTest(args, valueObjectFieldLimit);

final valueObjectFieldLimit = ArchitectureRule(
  description: 'Value objects should be simple — at most 5 fields',
  severity: RuleSeverity.warning,
  selector: ClassSelector(folder: 'lib/domain/value_objects'),
  predicate: MaxFieldsPredicate(5),
);
```

**Example — entities must not become God objects**
```dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(args, entityFieldLimit);

final entityFieldLimit = ArchitectureRule(
  description: 'Domain entities must not declare more than 10 fields',
  severity: RuleSeverity.warning,
  selector: ClassSelector(folder: 'lib/domain/entities'),
  predicate: MaxFieldsPredicate(10),
);
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

void main(List<String> args) => archTest(args, entityMinFields);

final entityMinFields = ArchitectureRule(
  description: 'Domain entities must declare at least 1 field (e.g., an id)',
  severity: RuleSeverity.error,
  selector: ClassSelector(folder: 'lib/domain/entities'),
  predicate: MinFieldsPredicate(1),
);
```

**Example — data models must have at least 2 fields**
```dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(args, modelMinFields);

final modelMinFields = ArchitectureRule(
  description: 'Data models must declare at least 2 fields',
  severity: RuleSeverity.warning,
  selector: ClassSelector(folder: 'lib/data/models'),
  predicate: MinFieldsPredicate(2),
);
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

void main(List<String> args) => archTest(args, entityLowCoupling);

final entityLowCoupling = ArchitectureRule(
  description: 'Domain entities must have at most 3 imports to keep coupling low',
  severity: RuleSeverity.warning,
  selector: ClassSelector(folder: 'lib/domain/entities'),
  predicate: MaxImportsPredicate(3),
);
```

**Example — high import count flags God Classes**
```dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(args, noGodClasses);

final noGodClasses = ArchitectureRule(
  description: 'Classes with more than 15 imports are likely God Classes',
  severity: RuleSeverity.warning,
  selector: ClassSelector(folder: 'lib'),
  predicate: MaxImportsPredicate(15),
);
```

**Example — use case files should stay focused (at most 5 imports)**
```dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(args, useCaseLowImports);

final useCaseLowImports = ArchitectureRule(
  description: 'Use case files must not exceed 5 imports',
  severity: RuleSeverity.info,
  selector: ClassSelector(folder: 'lib/domain/usecases'),
  predicate: MaxImportsPredicate(5),
);
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

void main(List<String> args) => archTest(args, statesMustBeImmutable);

final statesMustBeImmutable = ArchitectureRule(
  description: 'BLoC state classes must have all final fields for immutability',
  severity: RuleSeverity.error,
  selector: ClassSelector(folder: 'lib/bloc', namePattern: r'.*State$'),
  predicate: HasAllFinalFieldsPredicate(),
);
```

**Example — domain entities must be immutable**
```dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(args, entitiesImmutable);

final entitiesImmutable = ArchitectureRule(
  description: 'Domain entities must be immutable — all fields must be final',
  severity: RuleSeverity.error,
  selector: ClassSelector(folder: 'lib/domain/entities'),
  predicate: HasAllFinalFieldsPredicate(),
);
```

**Example — value objects must be immutable**
```dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(args, valueObjectsImmutable);

final valueObjectsImmutable = ArchitectureRule(
  description: 'Value objects must have all final fields',
  severity: RuleSeverity.error,
  selector: ClassSelector(folder: 'lib/domain/value_objects'),
  predicate: HasAllFinalFieldsPredicate(),
);
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

void main(List<String> args) => archTest(args, servicesNoPublicFields);

final servicesNoPublicFields = ArchitectureRule(
  description: 'Service classes must not expose public fields — use methods instead',
  severity: RuleSeverity.warning,
  selector: ClassSelector(folder: 'lib/services'),
  predicate: HasNoPublicFieldsPredicate(),
);
```

**Example — BLoC classes must not expose public fields**
```dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(args, blocsNoPublicFields);

final blocsNoPublicFields = ArchitectureRule(
  description: 'BLoC classes must not expose public fields',
  severity: RuleSeverity.warning,
  selector: ClassSelector(folder: 'lib/bloc'),
  predicate: HasNoPublicFieldsPredicate(),
);
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

void main(List<String> args) => archTest(args, internalUtilsNoPublicMethods);

final internalUtilsNoPublicMethods = ArchitectureRule(
  description: 'Classes in lib/internal must expose no public methods',
  severity: RuleSeverity.warning,
  selector: ClassSelector(folder: 'lib/internal'),
  predicate: HasNoPublicMethodsPredicate(),
);
```

**Example — helper classes in a sealed module should be fully private**
```dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(args, sealedHelperPrivate);

final sealedHelperPrivate = ArchitectureRule(
  description: 'Helper classes must not expose a public API',
  severity: RuleSeverity.info,
  selector: ClassSelector(folder: 'lib/helpers', namePattern: r'.*Helper$'),
  predicate: HasNoPublicMethodsPredicate(),
);
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

void main(List<String> args) => archTest(args, reposMustDispose);

final reposMustDispose = ArchitectureRule(
  description: 'Repository implementations must declare a dispose() method for cleanup',
  severity: RuleSeverity.warning,
  selector: ClassSelector(folder: 'lib/data/repositories', namePattern: r'.*Impl$'),
  predicate: HasMethodPredicate('dispose'),
);
```

**Example — use cases must declare a 'call' method**
```dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(args, useCasesMustHaveCall);

final useCasesMustHaveCall = ArchitectureRule(
  description: 'Use case classes must declare a call() method as their primary entry point',
  severity: RuleSeverity.error,
  selector: ClassSelector(folder: 'lib/domain/usecases'),
  predicate: HasMethodPredicate('call'),
);
```

**Example — entities should expose a copyWith method**
```dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(args, entitiesHaveCopyWith);

final entitiesHaveCopyWith = ArchitectureRule(
  description: 'Domain entities should declare a copyWith() method',
  severity: RuleSeverity.warning,
  selector: ClassSelector(folder: 'lib/domain/entities'),
  predicate: HasMethodPredicate('copyWith'),
);
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

void main(List<String> args) => archTest(args, noPrintCalls);

final noPrintCalls = ArchitectureRule(
  description: 'No print() calls allowed in production code',
  severity: RuleSeverity.warning,
  selector: FileSelector(folder: 'lib'),
  predicate: NotPredicate(
    FileContentMatchesPredicate(
      r'print\s*\(',
      description: 'contains a print() call',
    ),
  ),
);
```

**Example — no hardcoded URLs (with NotPredicate)**
```dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(args, noHardcodedUrls);

final noHardcodedUrls = ArchitectureRule(
  description: 'Hardcoded HTTP URLs must not appear in production code',
  severity: RuleSeverity.error,
  selector: FileSelector(folder: 'lib'),
  predicate: NotPredicate(
    FileContentMatchesPredicate(
      r'https?://[^\s\'"]+',
      description: 'contains a hardcoded URL',
    ),
  ),
);
```

**Example — no TODO comments in production code (with NotPredicate)**
```dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(args, noTodoComments);

final noTodoComments = ArchitectureRule(
  description: 'TODO comments must not remain in production code',
  severity: RuleSeverity.info,
  selector: FileSelector(folder: 'lib'),
  predicate: NotPredicate(
    FileContentMatchesPredicate(
      r'//\s*TODO',
      description: 'contains a TODO comment',
    ),
  ),
);
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

void main(List<String> args) => archTest(args, domainNoDataImports);

final domainNoDataImports = ArchitectureRule(
  description: 'Domain layer must not import from the data layer',
  severity: RuleSeverity.critical,
  selector: ClassSelector(folder: 'lib/domain'),
  predicate: NotPredicate(DependOnFolderPredicate('lib/data')),
);
```

**Example — production code must not be annotated with @deprecated**
```dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(args, noDeprecatedInProd);

final noDeprecatedInProd = ArchitectureRule(
  description: 'Production classes must not use @deprecated',
  severity: RuleSeverity.warning,
  selector: ClassSelector(folder: 'lib'),
  predicate: NotPredicate(AnnotatedWithPredicate('deprecated')),
);
```

**Example — convenience method syntax**
```dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(args, domainNoCycles);

final domainNoCycles = ArchitectureRule(
  description: 'Domain layer must not have circular dependencies',
  severity: RuleSeverity.critical,
  selector: ClassSelector(folder: 'lib/domain'),
  // Equivalent to NotPredicate(HasCircularDependencyPredicate())
  predicate: HasCircularDependencyPredicate().not(),
);
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

void main(List<String> args) => archTest(args, repositoryInterfaceRule);

final repositoryInterfaceRule = ArchitectureRule(
  description: 'Repository interfaces must be abstract and named with the Repository suffix',
  severity: RuleSeverity.error,
  selector: ClassSelector(folder: 'lib/domain/repositories'),
  predicate: AndPredicate([
    NameEndsWithPredicate('Repository'),
    IsAbstractPredicate(),
  ]),
);
```

**Example — services must satisfy multiple structural constraints**
```dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(args, serviceStructureRule);

final serviceStructureRule = ArchitectureRule(
  description: 'Services must be named correctly, injectable, and have no public fields',
  severity: RuleSeverity.warning,
  selector: ClassSelector(folder: 'lib/services'),
  predicate: AndPredicate([
    NameEndsWithPredicate('Service'),
    AnnotatedWithPredicate('injectable'),
    HasNoPublicFieldsPredicate(),
    NotPredicate(DependOnFolderPredicate('lib/presentation')),
  ]),
);
```

**Example — convenience method syntax**
```dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(args, repoNamingAndStructure);

final repoNamingAndStructure = ArchitectureRule(
  description: 'Repository implementations must be named correctly and be concrete',
  severity: RuleSeverity.error,
  selector: ClassSelector(folder: 'lib/data/repositories'),
  // Equivalent to AndPredicate([NameEndsWithPredicate('Impl'), IsConcreteClassPredicate()])
  predicate: NameEndsWithPredicate('Impl').and(IsConcreteClassPredicate()),
);
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

void main(List<String> args) => archTest(args, stateManagementNaming);

final stateManagementNaming = ArchitectureRule(
  description: 'State management classes must end with Bloc or Cubit',
  severity: RuleSeverity.warning,
  selector: ClassSelector(folder: 'lib/bloc'),
  predicate: OrPredicate([
    NameEndsWithPredicate('Bloc'),
    NameEndsWithPredicate('Cubit'),
  ]),
);
```

**Example — use cases may implement UseCase or be callable (execute or call method)**
```dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(args, useCaseContracts);

final useCaseContracts = ArchitectureRule(
  description: 'Use cases must implement UseCase or declare an execute/call method',
  severity: RuleSeverity.error,
  selector: ClassSelector(folder: 'lib/domain/usecases'),
  predicate: OrPredicate([
    ImplementsPredicate('UseCase'),
    HasMethodPredicate('execute'),
    HasMethodPredicate('call'),
  ]),
);
```

**Example — convenience method syntax**
```dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(args, controllerOrBlocNaming);

final controllerOrBlocNaming = ArchitectureRule(
  description: 'State management classes may end with Bloc, Cubit, or Controller',
  severity: RuleSeverity.warning,
  selector: ClassSelector(folder: 'lib/state'),
  // Equivalent to OrPredicate([...])
  predicate: NameEndsWithPredicate('Bloc')
      .or(NameEndsWithPredicate('Cubit'))
      .or(NameEndsWithPredicate('Controller')),
);
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
