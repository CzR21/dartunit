---
title: layeredArchitecturePreset
description: Enforce a complete layered architecture by declaring layers and their allowed dependencies. Automatically generates all forbidden-pair rules.
sidebar:
  order: 1
---

`layeredArchitecturePreset` is the most comprehensive preset in DartUnit. You declare every layer in your architecture and specify which other layers each one is allowed to import from. The preset then computes the full set of forbidden dependency pairs and generates one `ArchitectureRule` per forbidden pair — automatically, without you having to enumerate them manually.

A project with five layers has up to 20 directional pairs. Without this preset, you would write 20 separate rule files. With it, you write one configuration block and every combination is covered.

---

## Why layered architecture enforcement matters

A layered architecture is not just a folder convention. It is a load-bearing structural constraint that determines whether your codebase remains testable, replaceable, and maintainable as it grows. The moment a layer starts importing from a layer it has no business knowing about, the structural guarantees begin to collapse — and they collapse silently. No compiler error warns you. No type mismatch surfaces. Only months later, when you try to test a use case in isolation and discover it pulls in the entire Flutter widget tree, does the damage become visible.

### The dependency inversion principle in practice

In a classic layered architecture, the domain layer sits at the center. It contains your business logic, your entities, your use cases. It answers the question: what does this application actually do? The domain layer must not know how data is fetched, how it is displayed, or which HTTP library is in use. That ignorance is not a weakness — it is the source of the domain layer's power. Because it knows nothing about infrastructure, it can be tested with plain Dart unit tests. Because it knows nothing about Flutter, it can be reused in a CLI tool or a server-side Dart app. Because it knows nothing about the data layer, you can swap your REST API for a local database without touching a single use case.

When a developer adds a single `import 'package:flutter/material.dart'` to a domain entity — perhaps just to use a `Color` constant — the domain layer gains a dependency on Flutter. Every unit test for that entity now requires the Flutter test environment. Every time Flutter releases a breaking change, your domain tests break. The entity can no longer be shared with a pure Dart backend. That one import has done structural damage that is difficult to reverse once it spreads.

### What breaks when layers are violated

**Domain imports from Presentation**

The most damaging violation. A use case class that imports a widget or a screen class creates a circular conceptual dependency. Your business logic becomes aware of how it is displayed. If you ever try to write a headless version of your app, or run integration tests without a device, that import will block you. The domain layer has absorbed a concern that belongs to the presentation layer.

**Presentation imports from Data**

A widget that directly creates a `Dio` instance, calls a repository implementation, or accesses a local database bypasses the intermediate layers entirely. This is sometimes called "fat widget" syndrome. The widget is now responsible for network error handling, data transformation, caching, and display all at once. It cannot be unit-tested without mocking HTTP calls. It cannot be reused in a different screen without duplicating the network logic.

**Data imports from BLoC**

A repository that triggers a Cubit event or reads from a BLoC state stream has inverted the dependency. The infrastructure layer is now driving the state management layer. State changes become unpredictable because two layers are mutually updating each other. Race conditions, double-triggers, and phantom state changes are the typical symptoms.

**Feature modules importing each other directly**

In feature-based architectures, features that import from each other create a mesh of dependencies. Feature A cannot be removed without also removing Feature B, which depends on Feature C, which imports Feature A. You can no longer develop or deploy features independently. Onboarding a new developer means they need to understand the entire mesh before touching anything.

### The cost of enforcing this manually

Code review catches some violations, but code review is manual, asynchronous, and subject to reviewer fatigue. A reviewer who has approved 40 pull requests this week is less likely to carefully trace every import chain on pull request 41. DartUnit moves the enforcement from code review into CI. The violation is surfaced immediately, with the exact file and import that caused it, before the pull request is even opened for review.

---

## Function signature

```dart
List<ArchitectureRule> layeredArchitecturePreset({
  required List<LayerDefinition> layers,
  RuleSeverity severity = RuleSeverity.error,
  List<String> exceptions = const [],
})
```

The function returns a `List<ArchitectureRule>`, not a single rule. You must iterate the list and pass each rule to `archTest` individually. This is because each forbidden pair becomes its own rule, with its own violation report.

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `layers` | `List<LayerDefinition>` | required | The full list of layer definitions. Each entry declares a folder and which other folders it may import from. |
| `severity` | `RuleSeverity` | `RuleSeverity.error` | The severity applied to every generated rule. Use `RuleSeverity.warning` when adopting incrementally. |
| `exceptions` | `List<String>` | `const []` | File path substrings to exempt from all generated rules. Useful for generated files or legacy bridging code during migration. |

---

## The `LayerDefinition` class

`LayerDefinition` is the core data structure you provide to `layeredArchitecturePreset`. Each instance represents one architectural layer.

```dart
LayerDefinition({
  required String name,
  required String folder,
  required List<String> canAccess,
})
```

### Fields

| Field | Type | Description |
|-------|------|-------------|
| `name` | `String` | Human-readable name shown in violation messages. Use descriptive names like `'Domain'` or `'Presentation Layer'` — this is what developers see when a rule fails. |
| `folder` | `String` | A path substring that identifies all files belonging to this layer. A file is considered part of this layer if its path contains this string. `'lib/domain'` matches `lib/domain/entities/user.dart`, `lib/domain/usecases/login_usecase.dart`, and any other file under that directory. |
| `canAccess` | `List<String>` | The list of folder substrings this layer is permitted to import from. If a layer may not import from any other layer, pass an empty list. The values here must match the `folder` values of other `LayerDefinition` entries exactly — DartUnit uses substring matching, so `'lib/domain'` in `canAccess` means "files whose path contains `lib/domain`". |

### How folder matching works

DartUnit inspects the import paths inside each Dart file, not the directory structure itself. When it encounters an import like:

```dart
import 'package:my_app/domain/entities/user.dart';
```

It checks whether the resolved path of that import contains any of the forbidden folder substrings. If the rule says files in `lib/presentation` must not import from `lib/data`, DartUnit checks every import in every file under `lib/presentation` and flags any whose path contains `lib/data`.

This substring approach means your `folder` values do not need to be exact directory paths. However, you should keep them specific enough to avoid false positives. Using `'domain'` alone might inadvertently match a file called `lib/animation_domain_helpers.dart`. Using `'lib/domain'` is unambiguous.

---

## How rules are generated

Given a list of `LayerDefinition` entries, the preset computes a Cartesian product of all layer pairs and generates a forbidden rule for every pair where the `from` layer's `canAccess` list does not include the `to` layer's folder.

For a four-layer configuration with layers A, B, C, D where:
- A can access B, C
- B can access C
- C can access nothing
- D can access C

The forbidden pairs are: A→D, B→A, B→D, C→A, C→B, C→D, D→A, D→B.

That is 8 rules generated from 4 definitions. For five layers the number of potential pairs is 20. For six layers it is 30. The preset scales; manual rule writing does not.

---

## Running the rules

Because `layeredArchitecturePreset` returns a list, you cannot use the single-rule `archTest` pattern directly. You must iterate:

```dart
void main(List<String> args) {
  final rules = layeredArchitecturePreset(layers: [...]);

  for (final rule in rules) {
    archTest(args, rule);
  }
}
```

Run the analysis with:

```bash
dart run dartunit analyze
```

---

## Example 1 — Clean Architecture (Domain / Data / Presentation)

Clean Architecture as described by Robert C. Martin places business logic at the center, with infrastructure and UI on the outside. Dependencies always point inward: UI depends on domain, infrastructure depends on domain, domain depends on nothing.

```dart title="arch_test/clean_architecture_arch_test.dart"
import 'package:dartunit/dartunit.dart';

/// Enforces a three-layer Clean Architecture.
///
/// Dependency directions:
///   Presentation → Domain         (allowed)
///   Data         → Domain         (allowed)
///   Domain       → (nothing)      (allowed)
///
/// Everything else is forbidden.
void main(List<String> args) {
  final rules = layeredArchitecturePreset(
    layers: [
      LayerDefinition(
        name: 'Presentation',
        folder: 'lib/presentation',
        canAccess: ['lib/domain'],
      ),
      LayerDefinition(
        name: 'Data',
        folder: 'lib/data',
        canAccess: ['lib/domain'],
      ),
      LayerDefinition(
        name: 'Domain',
        folder: 'lib/domain',
        canAccess: [],
      ),
    ],
    severity: RuleSeverity.error,
  );

  for (final rule in rules) {
    archTest(args, rule);
  }
}
```

**Generated rules for this configuration:**

| From | To | Result |
|------|----|--------|
| Presentation | Data | FORBIDDEN — widgets must not call repositories directly |
| Presentation | Domain | ALLOWED |
| Data | Presentation | FORBIDDEN — repositories must not know about the UI |
| Data | Domain | ALLOWED |
| Domain | Presentation | FORBIDDEN — the most critical constraint |
| Domain | Data | FORBIDDEN — domain must not know how data is fetched |

**What this prevents in practice:**

- A screen widget directly instantiating a `UserRepositoryImpl` (which contains `Dio`)
- A domain use case importing a Flutter widget to retrieve a theme color
- A data repository calling a Navigator to redirect after a 401 response

---

## Example 2 — BLoC Architecture (Views / BLoCs / Models)

Many Flutter teams use a flatter, BLoC-centric architecture without a formal domain layer. Views dispatch events to BLoCs, BLoCs operate on models, models hold pure data.

```dart title="arch_test/bloc_architecture_arch_test.dart"
import 'package:dartunit/dartunit.dart';

/// Enforces a BLoC-centric three-layer architecture.
///
/// Dependency directions:
///   Views → BLoCs       (allowed — views listen to BLoC state)
///   BLoCs → Models      (allowed — BLoCs operate on models)
///   Models → (nothing)  (allowed — models are pure data)
void main(List<String> args) {
  final rules = layeredArchitecturePreset(
    layers: [
      LayerDefinition(
        name: 'Views',
        folder: 'lib/views',
        canAccess: ['lib/blocs', 'lib/models'],
      ),
      LayerDefinition(
        name: 'BLoCs',
        folder: 'lib/blocs',
        canAccess: ['lib/models'],
      ),
      LayerDefinition(
        name: 'Models',
        folder: 'lib/models',
        canAccess: [],
      ),
    ],
    severity: RuleSeverity.error,
  );

  for (final rule in rules) {
    archTest(args, rule);
  }
}
```

**Generated rules:**

| From | To | Result |
|------|----|--------|
| Views | BLoCs | ALLOWED |
| Views | Models | ALLOWED |
| BLoCs | Views | FORBIDDEN — BLoCs must not import widget classes |
| BLoCs | Models | ALLOWED |
| Models | Views | FORBIDDEN |
| Models | BLoCs | FORBIDDEN — models must not trigger BLoC events |

**Typical violation this catches:**

A developer adds a utility method to a model that formats a value for display and, to do so, imports a widget-level constant from `lib/views/theme.dart`. The model is now coupled to the view layer. This rule flags that import immediately.

---

## Example 3 — Feature-Based Architecture with Shared Layers

Larger applications often adopt feature-based folder structures where each feature is self-contained. Features should depend on shared infrastructure but must not depend on each other.

```dart title="arch_test/feature_architecture_arch_test.dart"
import 'package:dartunit/dartunit.dart';

/// Enforces a feature-based architecture.
///
/// Features are isolated from each other.
/// All features may use the shared and core layers.
/// Shared utilities may use core abstractions.
/// Core has no project dependencies.
void main(List<String> args) {
  final rules = layeredArchitecturePreset(
    layers: [
      LayerDefinition(
        name: 'Feature: Authentication',
        folder: 'lib/features/auth',
        canAccess: ['lib/shared', 'lib/core'],
      ),
      LayerDefinition(
        name: 'Feature: Profile',
        folder: 'lib/features/profile',
        canAccess: ['lib/shared', 'lib/core'],
      ),
      LayerDefinition(
        name: 'Feature: Dashboard',
        folder: 'lib/features/dashboard',
        canAccess: ['lib/shared', 'lib/core'],
      ),
      LayerDefinition(
        name: 'Shared',
        folder: 'lib/shared',
        canAccess: ['lib/core'],
      ),
      LayerDefinition(
        name: 'Core',
        folder: 'lib/core',
        canAccess: [],
      ),
    ],
    severity: RuleSeverity.error,
  );

  for (final rule in rules) {
    archTest(args, rule);
  }
}
```

**What this enforces:**

The three feature layers cannot import from each other. If the dashboard feature needs a user name from the auth feature, it cannot import it directly — the data must flow through a shared abstraction in `lib/shared` or `lib/core`. This forces the team to design proper inter-feature contracts rather than creating implicit coupling.

**Typical violation this catches:**

The dashboard screen imports `AuthBloc` from `lib/features/auth` to check the login state. This creates a hard dependency between two features. The dashboard can no longer function independently from the auth module. This rule flags that import and forces the team to either move the auth state to `lib/shared` or communicate through a shared interface.

---

## Example 4 — Five-Layer Enterprise Architecture

More complex applications, particularly those that need to separate their networking, caching, and business logic clearly, may use five or more layers.

```dart title="arch_test/enterprise_architecture_arch_test.dart"
import 'package:dartunit/dartunit.dart';

/// Five-layer enterprise architecture:
///
///   Presentation
///       ↓
///     BLoC
///       ↓
///    Domain
///     ↓   ↓
///   Data  Cache
///
/// Data and Cache both implement domain contracts.
/// BLoC coordinates between domain use cases only.
/// Presentation only knows about BLoC and domain models.
void main(List<String> args) {
  final rules = layeredArchitecturePreset(
    layers: [
      LayerDefinition(
        name: 'Presentation',
        folder: 'lib/presentation',
        canAccess: ['lib/bloc', 'lib/domain'],
      ),
      LayerDefinition(
        name: 'BLoC',
        folder: 'lib/bloc',
        canAccess: ['lib/domain'],
      ),
      LayerDefinition(
        name: 'Domain',
        folder: 'lib/domain',
        canAccess: [],
      ),
      LayerDefinition(
        name: 'Data',
        folder: 'lib/data',
        canAccess: ['lib/domain'],
      ),
      LayerDefinition(
        name: 'Cache',
        folder: 'lib/cache',
        canAccess: ['lib/domain'],
      ),
    ],
    severity: RuleSeverity.error,
  );

  for (final rule in rules) {
    archTest(args, rule);
  }
}
```

**Generated rule count:** 16 forbidden pairs from 5 layer definitions.

**Notable constraints this generates:**

- Data must not import from Cache (they are siblings, not hierarchical)
- Cache must not import from Data (same reason — prevents circular caching logic)
- BLoC must not import from Presentation (prevents BLoC from triggering navigation directly)
- Domain must not import from any of the four surrounding layers

---

## Severity levels

`RuleSeverity` controls how violations are reported. The available values are:

| Value | Behavior |
|-------|----------|
| `RuleSeverity.warning` | Violation is printed but `dart run dartunit analyze` exits with code 0. CI passes. |
| `RuleSeverity.error` | Violation causes `dart run dartunit analyze` to exit with a non-zero code. CI fails. |
| `RuleSeverity.critical` | Same as error, but violations are visually highlighted more prominently in the report. |

### Incremental adoption strategy

If you are adding `layeredArchitecturePreset` to an existing project that already has some violations, start with `RuleSeverity.warning`. This lets you see the full scope of violations without breaking CI immediately:

```dart title="arch_test/architecture_arch_test.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) {
  final rules = layeredArchitecturePreset(
    layers: [
      LayerDefinition(
        name: 'Domain',
        folder: 'lib/domain',
        canAccess: [],
      ),
      LayerDefinition(
        name: 'Data',
        folder: 'lib/data',
        canAccess: ['lib/domain'],
      ),
      LayerDefinition(
        name: 'Presentation',
        folder: 'lib/presentation',
        canAccess: ['lib/domain'],
      ),
    ],
    // Start with warning so CI doesn't immediately break.
    // Review the report, fix violations, then escalate to error.
    severity: RuleSeverity.warning,
  );

  for (final rule in rules) {
    archTest(args, rule);
  }
}
```

Run `dart run dartunit analyze` and read the output carefully. The report will list every file containing a violation, the specific import that caused it, and the rule that was broken. Work through the violations systematically — often a handful of files account for the majority of them. Once the violation count reaches zero, change `severity` to `RuleSeverity.error` and commit. From that point on, CI will prevent new violations from entering the codebase.

---

## Using the `exceptions` parameter

Some files legitimately bridge layers during a migration period, or are auto-generated and cannot be refactored. The `exceptions` parameter accepts a list of path substrings. Any file whose path contains one of these substrings is excluded from all rules generated by this preset.

```dart title="arch_test/architecture_arch_test.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) {
  final rules = layeredArchitecturePreset(
    layers: [
      LayerDefinition(
        name: 'Domain',
        folder: 'lib/domain',
        canAccess: [],
      ),
      LayerDefinition(
        name: 'Data',
        folder: 'lib/data',
        canAccess: ['lib/domain'],
      ),
      LayerDefinition(
        name: 'Presentation',
        folder: 'lib/presentation',
        canAccess: ['lib/domain'],
      ),
    ],
    severity: RuleSeverity.error,
    exceptions: [
      // Generated code from build_runner — cannot be refactored
      'lib/data/models/user_model.g.dart',
      // Legacy bridge file being migrated — tracked in issue #482
      'lib/presentation/legacy/old_user_screen.dart',
    ],
  );

  for (final rule in rules) {
    archTest(args, rule);
  }
}
```

Use exceptions sparingly. Each exception is a known compromise. Document why the exception exists with a comment, and include a reference to the issue or migration task that will eventually eliminate it. An exception list that grows over time is a sign that enforcement is being avoided rather than the architecture being fixed.

---

## How violations appear in the report

When `dart run dartunit analyze` finds a violation, the output identifies:

1. The rule that was violated (shown as "Layer X must not depend on Layer Y")
2. The file that contains the forbidden import
3. The specific import statement that caused the violation

A typical violation report looks like this:

```
VIOLATION [error] Domain must not depend on Presentation
  File:   lib/domain/usecases/format_user_name_usecase.dart
  Import: package:my_app/presentation/theme/app_colors.dart

VIOLATION [error] Domain must not depend on Data
  File:   lib/domain/entities/user.dart
  Import: package:my_app/data/models/user_model.dart

2 violation(s) found. Exit code: 1
```

The first violation shows a use case in the domain layer importing a color constant from the presentation layer. The second shows a domain entity importing a data model — the domain entity should define its own structure, not depend on the data layer's DTO.

Both of these are actionable: move `AppColors` to a shared location not owned by the presentation layer, and create a pure domain `User` entity that the data `UserModel` maps to.

---

## Common mistakes

### Forgetting to register a layer

If a folder exists in your codebase but is not declared as a `LayerDefinition`, imports from that folder are invisible to the preset. A file in `lib/services` importing from `lib/domain` will not be flagged because `lib/services` is not a registered layer.

You can catch unregistered layers by periodically auditing your folder structure against your `LayerDefinition` list, or by adding a separate rule that restricts which top-level folders are allowed to exist at all.

### Circular allowed dependencies

If Layer A lists Layer B in `canAccess`, and Layer B also lists Layer A in `canAccess`, the preset will not generate a forbidden rule for either direction. This is a circular dependency — each layer can import from the other. In practice this means the two layers are tightly coupled and should probably be merged or separated more clearly.

The preset does not warn you about circular `canAccess` relationships. You are responsible for ensuring that the allowed access graph is acyclic.

### Using `canAccess` with folder values that do not match

The strings in `canAccess` must exactly match the `folder` values of other `LayerDefinition` entries — not because DartUnit validates them, but because the matching is done by substring comparison against import paths. If you write:

```dart
LayerDefinition(
  name: 'Presentation',
  folder: 'lib/presentation',
  canAccess: ['domain'],  // Should be 'lib/domain'
),
```

The `canAccess` entry `'domain'` will match any import path containing the word "domain", including package names of third-party packages. Always use the full relative path prefix.

### Expecting package path matching for external dependencies

`layeredArchitecturePreset` analyzes import paths. For internal project files, the path will contain your folder structure. For external packages like `package:flutter/material.dart` or `package:dio/dio.dart`, the path will contain the package name. If you want to ban a specific external package from a layer, use `layerCannotDependOnPreset` with the package name as the `to` parameter — it is better suited for that use case.

---

## Combining with other presets

`layeredArchitecturePreset` covers inter-layer dependency directions. You will often want to complement it with additional rules:

```dart title="arch_test/full_rules_arch_test.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) {
  // Layer direction rules
  final layerRules = layeredArchitecturePreset(
    layers: [
      LayerDefinition(name: 'Presentation', folder: 'lib/presentation', canAccess: ['lib/bloc', 'lib/domain']),
      LayerDefinition(name: 'BLoC', folder: 'lib/bloc', canAccess: ['lib/domain']),
      LayerDefinition(name: 'Domain', folder: 'lib/domain', canAccess: []),
      LayerDefinition(name: 'Data', folder: 'lib/data', canAccess: ['lib/domain']),
    ],
    severity: RuleSeverity.error,
  );
  for (final rule in layerRules) {
    archTest(args, rule);
  }

  // The layered preset forbids domain→data, but doesn't cover
  // external packages. Add explicit bans for critical packages.
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

  // Belt-and-suspenders: also whitelist what domain CAN import
  archTest(
    args,
    layerCanOnlyDependOnPreset(
      folder: 'lib/domain',
      allowedFolders: ['lib/domain'],
      severity: RuleSeverity.error,
    ),
  );
}
```

See [`layerCannotDependOnPreset`](/presets/layer-cannot-depend-on) and [`layerCanOnlyDependOnPreset`](/presets/layer-can-only-depend-on) for the targeted and whitelist-based complements to this preset.
