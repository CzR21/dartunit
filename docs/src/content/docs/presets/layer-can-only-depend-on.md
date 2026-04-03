---
title: layerCanOnlyDependOnPreset
description: Whitelist the only folders a layer is allowed to import from. The strictest form of dependency control — anything outside the list is a violation.
sidebar:
  order: 3
---

`layerCanOnlyDependOnPreset` generates a single `ArchitectureRule` that restricts a layer to a whitelist of approved import sources. Any import found in the target layer that does not match one of the allowed folder substrings is reported as a violation.

This is the strictest form of import control that DartUnit offers. Rather than listing what is forbidden, you list what is permitted — and everything else is implicitly forbidden. The distinction matters enormously in practice: with a blacklist you can forget to add a new forbidden dependency, but with a whitelist you cannot accidentally allow a new one without updating the list explicitly.

---

## The whitelist approach versus the blacklist approach

To understand why the whitelist approach is valuable, consider what happens over a codebase's lifetime.

A blacklist (`layerCannotDependOnPreset`) works well when you have a specific, finite set of known bad dependencies. You say: "domain must not import flutter, domain must not import dio, domain must not import hive." Every rule you write is reactive — you are responding to a dependency that you know is bad.

The problem is the dependencies you haven't thought of yet. Six months from now, a developer adds `package:shared_preferences` to the domain layer to store a user preference. There is no rule forbidding it. The blacklist does not catch it. The violation silently enters the codebase and only surfaces when someone tries to run domain tests without the Flutter environment.

A whitelist catches this automatically. You declare: "domain may only import from `lib/domain` and `lib/core`." Anything else — including `shared_preferences`, including a package that didn't exist when you wrote the rule — is immediately a violation. The whitelist does not need to be updated when new forbidden dependencies appear. It already forbids them by default.

This is why whitelisting is the appropriate tool for layers that have high business value and must remain strictly controlled. The domain layer is the canonical example, but the same reasoning applies to any layer that must be framework-agnostic, independently testable, or reusable across platforms.

---

## What "only project files are analyzed" means

DartUnit analyzes the Dart files in your project — the files under your `lib/` directory and your rule files under `arch_test/`. It does not analyze the source code of your external dependencies.

When it checks imports, it matches the `allowedFolders` substrings against the import paths it finds in your project files. An import like `package:equatable/equatable.dart` will contain the substring `equatable`. An import like `dart:async` will contain `dart:async`. These are the strings you work with.

The critical consequence is this: **DartUnit does not flag imports of external packages as violations unless their path matches a forbidden pattern.** If `lib/domain` has `allowedFolders: ['lib/domain']`, a domain file importing `package:equatable/equatable.dart` will be a violation because `equatable` is not in the allowed list.

Wait — is that the right behavior? It depends on what you want to enforce.

If you want the domain layer to have zero external package dependencies beyond Dart's own standard library, then yes — allow only `lib/domain` and let DartUnit flag everything else, including `equatable`. This is the strictest possible setup.

If you want to allow specific external packages (equatable, meta, dartz), add their package name substrings to `allowedFolders`:

```dart
layerCanOnlyDependOnPreset(
  folder: 'lib/domain',
  allowedFolders: [
    'lib/domain',
    'equatable',     // allows package:equatable/equatable.dart
    'meta',          // allows package:meta/meta.dart
    'dartz',         // allows package:dartz/dartz.dart
  ],
)
```

Dart's built-in `dart:` imports (like `dart:async`, `dart:core`, `dart:convert`) are treated like any other import. If you use `dart:async` in domain code and your allowed list does not include `dart:`, it will be flagged. Add `dart:` to your allowed list if you want to permit all standard library imports:

```dart
layerCanOnlyDependOnPreset(
  folder: 'lib/domain',
  allowedFolders: [
    'lib/domain',
    'dart:',         // permits all dart: standard library imports
    'equatable',
  ],
)
```

---

## Function signature

```dart
ArchitectureRule layerCanOnlyDependOnPreset({
  required String folder,
  required List<String> allowedFolders,
  RuleSeverity severity = RuleSeverity.error,
  List<String> exceptions = const [],
})
```

This function returns a single `ArchitectureRule`. Use it directly with `archTest`:

```dart
void main(List<String> args) => archTest(
  args,
  layerCanOnlyDependOnPreset(
    folder: 'lib/domain',
    allowedFolders: ['lib/domain'],
  ),
);
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `folder` | `String` | required | Path substring identifying the layer to restrict. Every file whose path contains this substring is subject to the whitelist. |
| `allowedFolders` | `List<String>` | required | List of path substrings that are permitted as import sources. An import is allowed if its path contains at least one of these substrings. An import that matches none of them is a violation. |
| `severity` | `RuleSeverity` | `RuleSeverity.error` | How violations are reported and whether they fail the analysis run. |
| `exceptions` | `List<String>` | `const []` | File path substrings to exempt from the rule. Files whose path contains an exception entry are skipped entirely. |

---

## How the whitelist check works

For every file whose path contains `folder`, DartUnit inspects each import statement. For each import, it checks whether the import path contains at least one substring from `allowedFolders`. If no substring matches, the import is a violation.

Consider a file at `lib/domain/usecases/get_user_usecase.dart` with these imports:

```dart
import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:my_app/domain/entities/user.dart';
import 'package:my_app/data/repositories/user_repository_impl.dart';
import 'package:flutter/material.dart';
```

With this rule:

```dart
layerCanOnlyDependOnPreset(
  folder: 'lib/domain',
  allowedFolders: [
    'lib/domain',
    'dart:',
    'equatable',
  ],
)
```

The check for each import:

| Import | Matches allowed? | Result |
|--------|-----------------|--------|
| `dart:async` | Yes — matches `dart:` | ALLOWED |
| `package:equatable/equatable.dart` | Yes — matches `equatable` | ALLOWED |
| `package:my_app/domain/entities/user.dart` | Yes — matches `lib/domain` | ALLOWED |
| `package:my_app/data/repositories/user_repository_impl.dart` | No match | VIOLATION |
| `package:flutter/material.dart` | No match | VIOLATION |

The last two imports are violations. The report will identify both the file and the specific import for each.

---

## Example 1 — Domain layer that can only depend on itself

The most common use of this preset is to enforce complete domain isolation. The domain layer imports only from itself: domain entities import other domain entities, use cases import domain entities and domain repository interfaces, and nothing else.

```dart title="arch_test/domain_whitelist_arch_test.dart"
import 'package:dartunit/dartunit.dart';

/// The domain layer may only import from itself.
///
/// This is the strictest possible domain isolation rule.
/// It ensures that:
///
///   - Domain tests run with plain `dart test` (no Flutter test runner)
///   - Domain classes are reusable in any Dart environment
///   - No infrastructure or UI concern can silently enter the domain
///
/// If a domain entity needs an external utility (such as value equality),
/// add the package name to allowedFolders rather than removing this rule.
void main(List<String> args) => archTest(
  args,
  layerCanOnlyDependOnPreset(
    folder: 'lib/domain',
    allowedFolders: [
      'lib/domain', // may import other domain classes
    ],
    severity: RuleSeverity.error,
  ),
);
```

This rule catches everything that `layerCannotDependOnPreset` would catch, plus anything you haven't thought of yet. It is the appropriate rule when your domain layer has been cleaned up and you want to lock it down permanently.

**If this produces unexpected violations:**

A common discovery when first applying this rule is that domain classes import `dart:async` for `Future` or `Stream`. Add `'dart:'` to the allowed list:

```dart
layerCanOnlyDependOnPreset(
  folder: 'lib/domain',
  allowedFolders: [
    'lib/domain',
    'dart:',
  ],
)
```

Another common discovery is that domain classes use `Equatable` for value equality or `Either` from `dartz` for functional error handling. Add those package names:

```dart
layerCanOnlyDependOnPreset(
  folder: 'lib/domain',
  allowedFolders: [
    'lib/domain',
    'dart:',
    'equatable',
    'dartz',
    'meta',
  ],
)
```

The key principle is that every package in this list should be a pure Dart package with no Flutter dependency. If you find yourself adding `flutter` or a Flutter plugin to the allowed list of the domain layer, that is a signal that the domain layer has absorbed a concern it should not have.

---

## Example 2 — Models layer that can only depend on Equatable and meta

A models layer that holds pure data classes (value objects, DTOs, entities) may need value equality and JSON serialization, but nothing else. Locking it down to specific utility packages prevents it from drifting into state management or UI territory.

```dart title="arch_test/models_whitelist_arch_test.dart"
import 'package:dartunit/dartunit.dart';

/// Models may only import from themselves and approved utility packages.
///
/// Approved utilities:
///   - equatable: structural equality for value objects
///   - meta: @immutable and @required annotations
///   - json_annotation: for JSON serialization annotations
///   - dart: standard library (dart:core is implicit, dart:convert for json)
///
/// Models must not import BLoC, repositories, services, or UI code.
void main(List<String> args) => archTest(
  args,
  layerCanOnlyDependOnPreset(
    folder: 'lib/models',
    allowedFolders: [
      'lib/models',        // may import other models
      'dart:',             // standard library (dart:convert for json)
      'equatable',         // structural equality
      'meta',              // annotations like @immutable
      'json_annotation',   // @JsonSerializable, @JsonKey
    ],
    severity: RuleSeverity.error,
  ),
);
```

**What this prevents:**

- A model importing a BLoC event to trigger state changes from within the model
- A model importing a widget class for display formatting
- A model importing a repository to lazy-load related data
- A model importing a service locator to resolve dependencies

All of these patterns make models stateful, context-dependent, and difficult to test in isolation.

---

## Example 3 — Pure utilities with zero project dependencies

A `lib/core` or `lib/utils` layer that provides truly generic utilities — logging, error handling, string manipulation, date formatting — should not depend on any feature-specific or layer-specific code. It must be usable from anywhere in the project without creating circular dependencies.

```dart title="arch_test/core_whitelist_arch_test.dart"
import 'package:dartunit/dartunit.dart';

/// Core utilities must not import any project-specific code.
///
/// lib/core is the foundation. Everything depends on it; it depends
/// on nothing within the project. Only standard library and approved
/// utility packages are allowed.
///
/// If a utility class in lib/core currently imports from lib/features
/// or lib/domain, that utility should be moved into the layer that uses
/// it, or the dependency should be inverted using a callback or interface.
void main(List<String> args) => archTest(
  args,
  layerCanOnlyDependOnPreset(
    folder: 'lib/core',
    allowedFolders: [
      'lib/core',      // may import other core utilities
      'dart:',         // standard library
      'meta',          // annotations
      'logger',        // logging package (if using package:logger)
      'intl',          // internationalization utilities
    ],
    severity: RuleSeverity.error,
  ),
);
```

**What this guarantees:**

Any file in `lib/core` can be imported by any other layer without creating a dependency cycle. If `lib/domain`, `lib/data`, and `lib/presentation` all import from `lib/core`, and `lib/core` imports from none of them, the dependency graph remains a directed acyclic graph. Remove `lib/core` from the allowed list and you would have the possibility of `lib/core` importing `lib/domain`, which imports `lib/core` — a cycle that causes unpredictable initialization order and build failures in larger projects.

---

## Example 4 — Data layer that can only depend on domain and external infrastructure packages

The data layer implements the interfaces defined in the domain layer. It is allowed to import from domain (to implement domain interfaces and use domain entities) and from infrastructure packages (HTTP clients, local databases, serialization tools). It must not import from the presentation layer or BLoC layer.

```dart title="arch_test/data_whitelist_arch_test.dart"
import 'package:dartunit/dartunit.dart';

/// The data layer may import from domain and approved infrastructure packages.
///
/// Approved infrastructure:
///   - dio: HTTP client for REST API calls
///   - hive: local key-value database
///   - hive_flutter: Flutter-specific Hive initialization (acceptable in data)
///   - shared_preferences: simple persistent storage
///   - json_annotation / json_serializable: JSON serialization
///   - dart: standard library
///
/// The data layer must NOT import from presentation or BLoC layers.
/// Those constraints are enforced here implicitly because presentation
/// and bloc are not in the allowed list.
void main(List<String> args) => archTest(
  args,
  layerCanOnlyDependOnPreset(
    folder: 'lib/data',
    allowedFolders: [
      'lib/data',          // may import other data classes
      'lib/domain',        // implements domain interfaces, uses domain entities
      'lib/core',          // shared utilities
      'dart:',             // standard library
      'dio',               // HTTP client
      'hive',              // local database
      'hive_flutter',      // Flutter Hive init
      'shared_preferences', // simple storage
      'json_annotation',   // serialization annotations
      'retrofit',          // if using retrofit for API generation
    ],
    severity: RuleSeverity.error,
  ),
);
```

**Note on `hive_flutter`:** The data layer importing `hive_flutter` is a deliberate exception to the "no Flutter in data" principle. `hive_flutter` provides Flutter-specific initialization for Hive that is commonly required in the data layer. Whether this is acceptable depends on your project's portability requirements. If you need the data layer to be usable in a pure Dart server environment, remove `hive_flutter` from the allowed list and initialize Hive through an injectable adapter instead.

---

## Example 5 — BLoC layer with a tightly scoped whitelist

The BLoC layer coordinates between domain use cases and the presentation layer's state needs. It may import from domain and from itself, but must not import from the data layer or from the presentation layer.

```dart title="arch_test/bloc_whitelist_arch_test.dart"
import 'package:dartunit/dartunit.dart';

/// BLoC classes may only import from domain, core, and BLoC infrastructure.
///
/// The BLoC layer must not:
///   - Import from the data layer directly (use domain interfaces instead)
///   - Import from the presentation layer (no widget imports in BLoC)
///   - Import from other BLoC cubits directly (use shared domain events)
///
/// BLoC coordination between features should happen through domain
/// event buses or shared streams, not through direct BLoC-to-BLoC imports.
void main(List<String> args) => archTest(
  args,
  layerCanOnlyDependOnPreset(
    folder: 'lib/bloc',
    allowedFolders: [
      'lib/bloc',      // may import sibling BLoC/Cubit classes
      'lib/domain',    // primary dependency: domain use cases and entities
      'lib/core',      // shared utilities
      'dart:',         // standard library
      'flutter_bloc',  // the BLoC package itself
      'equatable',     // for state equality
      'meta',          // annotations
    ],
    severity: RuleSeverity.error,
  ),
);
```

---

## Handling `dart:` imports

Standard library imports starting with `dart:` are among the most common sources of confusion when first applying a whitelist rule. Here is a complete reference:

| Import | Package substring |
|--------|-----------------|
| `dart:async` | `dart:async` or `dart:` (for all) |
| `dart:core` | `dart:core` or `dart:` (for all) |
| `dart:convert` | `dart:convert` or `dart:` (for all) |
| `dart:io` | `dart:io` or `dart:` (for all) |
| `dart:math` | `dart:math` or `dart:` (for all) |
| `dart:typed_data` | `dart:typed_data` or `dart:` (for all) |

Using `'dart:'` as a single allowed entry permits all standard library imports. If your domain layer should not use `dart:io` (because `dart:io` is not available in Flutter Web), you can list individual standard library packages instead:

```dart
layerCanOnlyDependOnPreset(
  folder: 'lib/domain',
  allowedFolders: [
    'lib/domain',
    'dart:async',
    'dart:core',
    'dart:convert',
    'dart:math',
    // Deliberately NOT including dart:io — domain must be web-compatible
  ],
)
```

---

## Common gotcha: forgetting to allow the layer itself

The most frequent mistake when setting up `layerCanOnlyDependOnPreset` is forgetting to include the target folder in its own allowed list. A domain file that imports another domain file — a use case importing an entity, for example — will be flagged as a violation if `'lib/domain'` is not in `allowedFolders`.

**Incorrect — domain cannot import itself:**

```dart
layerCanOnlyDependOnPreset(
  folder: 'lib/domain',
  allowedFolders: [
    'dart:',
    'equatable',
    // Missing: 'lib/domain'
  ],
)
```

**Correct:**

```dart
layerCanOnlyDependOnPreset(
  folder: 'lib/domain',
  allowedFolders: [
    'lib/domain',  // always include the folder itself
    'dart:',
    'equatable',
  ],
)
```

Every realistic use of this preset will include the target folder in its own allowed list.

---

## Common gotcha: package name substrings that are too short

If an allowed package name is a common English word or a short abbreviation, it may inadvertently match unrelated import paths.

```dart
// 'get' would match package:get/get.dart but also
// package:my_app/domain/usecases/get_user_usecase.dart
// Don't use 'get' as an allowed entry if you're banning project imports.
allowedFolders: [
  'lib/domain',
  'get',  // Problematic if your file paths contain the word 'get'
]
```

Use the package name as it appears in the import path. For `package:get/get.dart`, the reliable substring is `package:get` rather than just `get`:

```dart
allowedFolders: [
  'lib/domain',
  'package:get',
]
```

For internal project folders, always use the `lib/` prefix path like `lib/domain` to avoid matching unrelated file names.

---

## Using `exceptions` during migration

When applying `layerCanOnlyDependOnPreset` to an existing project, you will often find violations in files that cannot be refactored immediately. Use the `exceptions` parameter to exempt specific files while you work toward full compliance:

```dart title="arch_test/domain_whitelist_arch_test.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(
  args,
  layerCanOnlyDependOnPreset(
    folder: 'lib/domain',
    allowedFolders: [
      'lib/domain',
      'dart:',
      'equatable',
    ],
    severity: RuleSeverity.error,
    exceptions: [
      // This use case was written before the whitelist rule was introduced.
      // It imports from lib/data to work around a missing domain interface.
      // Tracked in issue #544: create IProductRepository in domain layer.
      'lib/domain/usecases/sync_products_usecase.dart',
    ],
  ),
);
```

The exception entry is a path substring, so `'sync_products_usecase'` would also work if it is unambiguous. Use the most specific substring that uniquely identifies the file.

---

## Combining with `layerCannotDependOnPreset`

A whitelist rule is comprehensive but can be verbose — every allowed external package must be listed. Sometimes you want the convenience of a whitelist for your project's own code and explicit bans for specific external packages, without listing every permitted package:

```dart title="arch_test/domain_combined_arch_test.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) {
  // Whitelist controls which project layers are importable
  archTest(
    args,
    layerCanOnlyDependOnPreset(
      folder: 'lib/domain',
      allowedFolders: [
        'lib/domain',
        'lib/core',
        'dart:',
        // External packages are allowed by default here because we
        // use explicit bans below for the most critical ones.
        // This is the "trust but verify" approach.
      ],
      severity: RuleSeverity.error,
    ),
  );

  // Explicit bans for the highest-risk external packages
  archTest(
    args,
    layerCannotDependOnPreset(
      from: 'lib/domain',
      to: 'flutter',
      severity: RuleSeverity.critical,
    ),
  );

  archTest(
    args,
    layerCannotDependOnPreset(
      from: 'lib/domain',
      to: 'dio',
      severity: RuleSeverity.critical,
    ),
  );

  archTest(
    args,
    layerCannotDependOnPreset(
      from: 'lib/domain',
      to: 'hive',
      severity: RuleSeverity.error,
    ),
  );
}
```

This combination catches both accidental project-layer crossings (via the whitelist) and specific critical external package dependencies (via explicit bans).

---

## Relationship to `layeredArchitecturePreset`

`layeredArchitecturePreset` generates forbidden-pair rules for a complete layer graph. When you declare that `Domain` has `canAccess: []`, the preset generates rules forbidding domain from importing data, presentation, and every other declared layer. But it does not forbid domain from importing external packages like `flutter` or `dio`.

`layerCanOnlyDependOnPreset` for the same domain layer would forbid all imports except those explicitly whitelisted — including external packages. The two tools are complementary:

- Use `layeredArchitecturePreset` to enforce the global dependency graph between all your declared layers.
- Use `layerCanOnlyDependOnPreset` on your most critical layers for the strictest possible control, including external packages.

```dart title="arch_test/full_architecture_arch_test.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) {
  // Declare the full layer graph
  final rules = layeredArchitecturePreset(
    layers: [
      LayerDefinition(name: 'Presentation', folder: 'lib/presentation', canAccess: ['lib/bloc', 'lib/domain']),
      LayerDefinition(name: 'BLoC', folder: 'lib/bloc', canAccess: ['lib/domain']),
      LayerDefinition(name: 'Domain', folder: 'lib/domain', canAccess: []),
      LayerDefinition(name: 'Data', folder: 'lib/data', canAccess: ['lib/domain']),
    ],
    severity: RuleSeverity.error,
  );
  for (final rule in rules) {
    archTest(args, rule);
  }

  // Strict whitelist for the domain layer
  // This adds coverage that layeredArchitecturePreset does not provide:
  // it catches external package imports that the layer graph can't express.
  archTest(
    args,
    layerCanOnlyDependOnPreset(
      folder: 'lib/domain',
      allowedFolders: [
        'lib/domain',
        'dart:',
        'equatable',
        'dartz',
        'meta',
      ],
      severity: RuleSeverity.error,
    ),
  );
}
```

---

## What the violation message looks like

When a file in the target folder imports from a path not in the allowed list, the output follows this format:

```
VIOLATION [error] lib/domain may only depend on: [lib/domain, dart:, equatable]
  File:   lib/domain/usecases/upload_file_usecase.dart
  Import: package:my_app/data/sources/file_upload_api.dart

VIOLATION [error] lib/domain may only depend on: [lib/domain, dart:, equatable]
  File:   lib/domain/entities/user.dart
  Import: package:flutter/foundation.dart

2 violation(s) found. Exit code: 1
```

The allowed list is included in the violation message, so developers immediately understand both what was violated and what the approved alternatives are. The first violation shows a use case bypassing the domain repository interface by importing the implementation directly. The second shows a domain entity importing a Flutter foundation class — likely to use `@immutable` from Flutter instead of from the `meta` package.

Both are actionable: replace the data import with the domain interface, and replace the Flutter import with `package:meta/meta.dart` for the `@immutable` annotation.

---

## Decision guide: which preset to use for dependency control

| Question | Answer | Recommended preset |
|----------|--------|-------------------|
| Do you need to declare and enforce the full layer graph at once? | Yes | `layeredArchitecturePreset` |
| Do you need to add a single targeted prohibition? | Yes | `layerCannotDependOnPreset` |
| Do you want to ban a specific external package from a layer? | Yes | `layerCannotDependOnPreset` |
| Do you want the strictest possible control, including unknown future dependencies? | Yes | `layerCanOnlyDependOnPreset` |
| Is the layer being restricted your most critical, highest-value layer? | Yes | `layerCanOnlyDependOnPreset` |
| Are you adopting DartUnit incrementally and want to start small? | Yes | `layerCannotDependOnPreset` |
| Do you want belt-and-suspenders enforcement on a single critical layer? | Yes | Both `layerCannotDependOnPreset` and `layerCanOnlyDependOnPreset` |
