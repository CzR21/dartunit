---
title: layerCannotDependOnPreset
description: Forbid a layer from importing code from specified layers. Use for targeted dependency prohibition without declaring the full architecture.
sidebar:
  order: 2
---

`layerCannotDependOnPreset` generates a single `ArchitectureRule` that forbids one layer from importing anything from another specified layer. It is a direct, focused tool: you name the offending direction, and DartUnit enforces it.

Unlike [`layeredArchitecturePreset`](/presets/layered-architecture), which requires you to declare every layer in your architecture and then derives all forbidden pairs from the allowed pairs, `layerCannotDependOnPreset` makes no assumptions about the rest of your architecture. It adds exactly one constraint. You can use it on its own, stack multiple calls in a single file, or mix it with other presets.

---

## When to use this preset

### Adding one specific constraint to an existing project

If your codebase already has a documented architecture and you want to enforce a single critical boundary without touching anything else, `layerCannotDependOnPreset` is the right tool. Suppose your team has agreed that the domain layer must never import from Flutter. You do not need to declare five other layers to express that. You write one rule, run it in CI, and the constraint is enforced from that point forward.

```dart title="arch_test/domain_no_flutter_arch_test.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(
  args,
  layerCannotDependOnPreset(
    from: 'lib/domain',
    to: 'flutter',
    severity: RuleSeverity.critical,
  ),
);
```

### Incremental adoption

When you introduce DartUnit to a project that has accumulated technical debt, enforcing the full architecture at once may produce hundreds of violations. That volume is overwhelming and CI immediately breaks, which creates pressure to revert or ignore the tool.

The better approach is incremental adoption: start with the constraint that matters most to your team, fix the violations it exposes, then add the next constraint. `layerCannotDependOnPreset` is ideal for this strategy because each call is independent and narrowly scoped.

```dart title="arch_test/domain_isolation_arch_test.dart"
import 'package:dartunit/dartunit.dart';

// Week 1: enforce the single most critical constraint
void main(List<String> args) => archTest(
  args,
  layerCannotDependOnPreset(
    from: 'lib/domain',
    to: 'lib/data',
    severity: RuleSeverity.error,
  ),
);
```

Once this produces zero violations, add the next rule in a new file. Over several iterations you build toward full coverage without disrupting the team.

### Non-standard architectures

Not every project follows Clean Architecture or a classic layered pattern. Some codebases are primarily service-oriented, event-driven, or have custom organizational conventions that don't map cleanly to a full layer declaration. For these projects, `layeredArchitecturePreset` may be too rigid. You can instead express exactly the constraints that matter:

- "The analytics module must never import from the checkout module."
- "The shared utilities package must not import any feature-specific code."
- "The accessibility helpers must not depend on the networking layer."

None of these fit neatly into a hierarchy, but all of them are valid architectural constraints worth enforcing.

### Banning external packages from a layer

`layerCannotDependOnPreset` is the correct tool for banning external packages from a layer. The `to` parameter performs substring matching against import paths, and an external package like `package:dio/dio.dart` contains the substring `dio`. This lets you say "no file in `lib/domain` may import any path containing `flutter`" without needing to declare the full architecture.

---

## Function signature

```dart
ArchitectureRule layerCannotDependOnPreset({
  required String from,
  required String to,
  RuleSeverity severity = RuleSeverity.error,
  List<String> exceptions = const [],
})
```

This function returns a single `ArchitectureRule`, not a list. Use it directly with `archTest`:

```dart
void main(List<String> args) => archTest(
  args,
  layerCannotDependOnPreset(from: '...', to: '...'),
);
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `from` | `String` | required | Path substring identifying the layer that must not import from `to`. Any file whose path contains this string is subject to the rule. |
| `to` | `String` | required | Path substring identifying the forbidden dependency target. If any import in a `from` file contains this string, a violation is reported. This can be a local folder path (`'lib/data'`) or a package name substring (`'flutter'`, `'dio'`). |
| `severity` | `RuleSeverity` | `RuleSeverity.error` | How violations are reported. `warning` exits with code 0. `error` and `critical` exit with a non-zero code. |
| `exceptions` | `List<String>` | `const []` | File path substrings to exempt from this rule. Any file whose path contains an exceptions entry is skipped entirely. |

---

## How matching works

The `from` parameter is matched against the file path of each Dart file DartUnit analyzes. The `to` parameter is matched against each import path found inside those files.

Consider a file at `lib/domain/usecases/get_user_usecase.dart` with these imports:

```dart
import 'package:my_app/domain/entities/user.dart';
import 'package:my_app/data/repositories/user_repository_impl.dart';
import 'package:equatable/equatable.dart';
```

If you have a rule with `from: 'lib/domain'` and `to: 'lib/data'`:

1. DartUnit checks whether the file path `lib/domain/usecases/get_user_usecase.dart` contains `'lib/domain'` — it does, so this file is subject to the rule.
2. DartUnit checks each import path for the substring `'lib/data'`.
3. The import `package:my_app/data/repositories/user_repository_impl.dart` contains `data/repositories` — but does it contain `lib/data`? That depends on how DartUnit resolves paths. In practice, use the path substring that unambiguously identifies the target folder in your project's import paths.

If your project is named `my_app` and your data layer lives at `lib/data/`, the resolved import path will typically contain `my_app/data`. Using `to: 'lib/data'` is safe because `lib/data` appears in the absolute path of those files. Using just `to: 'data'` would match any import containing the word "data", including third-party packages — so be specific.

---

## Example 1 — Domain must not depend on Presentation

This is the most critical architectural constraint in a Clean Architecture project. The domain layer contains business logic and entities that must be framework-agnostic. Any import from the presentation layer — a widget, a screen class, a theme constant — destroys the domain layer's independence.

```dart title="arch_test/domain_no_presentation_arch_test.dart"
import 'package:dartunit/dartunit.dart';

/// The domain layer must never import from the presentation layer.
///
/// Why this matters:
/// - Domain logic becomes testable without Flutter if it has no UI dependencies
/// - Domain entities can be reused in non-Flutter Dart applications
/// - Presentation concerns (colors, fonts, screen sizes) have no place in
///   business logic
///
/// If a domain entity needs a value that currently lives in the presentation
/// layer (such as a display name or a color code), move that value to a
/// shared constants file in lib/core or lib/shared.
void main(List<String> args) => archTest(
  args,
  layerCannotDependOnPreset(
    from: 'lib/domain',
    to: 'lib/presentation',
    severity: RuleSeverity.critical,
  ),
);
```

**Running this:**

```bash
dart run dartunit analyze
```

**Sample violation output:**

```
VIOLATION [critical] Domain must not depend on Presentation
  File:   lib/domain/usecases/format_product_usecase.dart
  Import: package:my_app/presentation/formatters/currency_formatter.dart

1 violation(s) found. Exit code: 1
```

**How to fix this violation:** The `CurrencyFormatter` class is currently in the presentation layer but is being used by a domain use case. Move `CurrencyFormatter` to `lib/core/formatters/` or `lib/shared/formatters/`. The domain layer can then import from `lib/core`, which is an allowed dependency. The presentation layer can also import from `lib/core`, so no functionality is lost.

---

## Example 2 — Models must not depend on BLoC

In a BLoC-based Flutter application, the models layer holds pure data classes. Models must not know about BLoC events, states, or cubits. BLoC is infrastructure that sits above models; models must not reach upward.

```dart title="arch_test/models_no_bloc_arch_test.dart"
import 'package:dartunit/dartunit.dart';

/// Data models must not import BLoC classes.
///
/// Models are pure data. They hold values and may define equality,
/// serialization, and simple transformations. They have no business
/// in triggering state management events.
///
/// If you find a model that needs to emit an event, extract that
/// logic into a use case or a BLoC event handler instead.
void main(List<String> args) => archTest(
  args,
  layerCannotDependOnPreset(
    from: 'lib/models',
    to: 'lib/blocs',
    severity: RuleSeverity.error,
  ),
);
```

A common violation of this rule occurs when a developer adds a convenience factory or an extension method to a model that dispatches a BLoC event — for example, a `UserModel.logout()` method that calls `AuthBloc.add(LogoutEvent())`. The logic seems convenient but it makes the model impossible to use without the BLoC infrastructure, breaks unit tests of the model class, and creates a circular dependency if the BLoC also imports the model.

---

## Example 3 — Core utilities must not depend on feature code

A `lib/core` or `lib/utils` folder is meant to be a dependency of features, not a dependent of them. Core utilities — error handlers, logging wrappers, string utilities, network abstractions — should be usable by any feature without pulling in any specific feature's code.

```dart title="arch_test/core_no_features_arch_test.dart"
import 'package:dartunit/dartunit.dart';

/// Core utilities must not import feature-specific code.
///
/// lib/core is a foundation layer. It should have no knowledge of
/// lib/features. If a utility class in lib/core currently imports
/// from lib/features, that utility likely belongs inside the feature
/// that uses it, or the functionality it uses should be moved up
/// into lib/core where it can be shared.
void main(List<String> args) => archTest(
  args,
  layerCannotDependOnPreset(
    from: 'lib/core',
    to: 'lib/features',
    severity: RuleSeverity.error,
  ),
);
```

**Typical violation this catches:**

A logging utility in `lib/core/logging/app_logger.dart` imports `UserFeatureFlags` from `lib/features/user/` to decide which log level to use for user-related events. The fix is to either pass the log level as a parameter (keeping the logger generic), or move the user-specific logging logic into `lib/features/user/`.

---

## Example 4 — Multiple forbidden layers in one rule file

You can call `layerCannotDependOnPreset` multiple times in a single rule file to express several related prohibitions together:

```dart title="arch_test/domain_strict_arch_test.dart"
import 'package:dartunit/dartunit.dart';

/// Strict domain isolation rules.
///
/// The domain layer must not depend on:
///   - The presentation layer (UI concerns)
///   - The data layer (infrastructure concerns)
///   - Flutter itself (framework dependency)
///   - Dio (HTTP client — infrastructure concern)
///   - Hive (local database — infrastructure concern)
///
/// Domain entities and use cases must be testable with plain `dart test`,
/// no Flutter test environment required.
void main(List<String> args) {
  // No UI imports
  archTest(
    args,
    layerCannotDependOnPreset(
      from: 'lib/domain',
      to: 'lib/presentation',
      severity: RuleSeverity.critical,
    ),
  );

  // No infrastructure imports
  archTest(
    args,
    layerCannotDependOnPreset(
      from: 'lib/domain',
      to: 'lib/data',
      severity: RuleSeverity.critical,
    ),
  );

  // No Flutter framework
  archTest(
    args,
    layerCannotDependOnPreset(
      from: 'lib/domain',
      to: 'flutter',
      severity: RuleSeverity.critical,
    ),
  );

  // No HTTP client
  archTest(
    args,
    layerCannotDependOnPreset(
      from: 'lib/domain',
      to: 'dio',
      severity: RuleSeverity.error,
    ),
  );

  // No local database
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

Each call is independent. If three of these five constraints are violated, DartUnit reports three separate violations — one per rule — rather than a single combined message. This makes it easy to identify exactly which prohibited dependency is present.

---

## Example 5 — Preventing cross-feature dependencies in a monorepo

In a Dart monorepo or a large modular Flutter app, you may have packages that must remain decoupled. For example, a `packages/checkout` module and a `packages/analytics` module may both exist, but checkout must not directly import analytics internals.

```dart title="arch_test/checkout_isolation_arch_test.dart"
import 'package:dartunit/dartunit.dart';

/// The checkout feature must not depend on analytics internals.
///
/// Analytics should be triggered through a shared event interface,
/// not by directly instantiating analytics classes from checkout.
/// This keeps checkout testable without the analytics infrastructure.
void main(List<String> args) {
  archTest(
    args,
    layerCannotDependOnPreset(
      from: 'packages/checkout',
      to: 'packages/analytics/src',
      severity: RuleSeverity.error,
    ),
  );

  // The analytics public API (not src/) is allowed.
  // No rule needed — only the internal src/ is forbidden.
}
```

---

## Combining with `layerCanOnlyDependOnPreset`

`layerCannotDependOnPreset` is a blacklist: it says "this specific import is forbidden". [`layerCanOnlyDependOnPreset`](/presets/layer-can-only-depend-on) is a whitelist: it says "only these specific imports are allowed". For critical layers, you can apply both.

The blacklist catches known bad dependencies. The whitelist catches unknown future bad dependencies that you haven't thought to blacklist yet. Together they provide belt-and-suspenders enforcement:

```dart title="arch_test/domain_double_enforcement_arch_test.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) {
  // Blacklist: known forbidden dependencies
  archTest(
    args,
    layerCannotDependOnPreset(
      from: 'lib/domain',
      to: 'lib/presentation',
      severity: RuleSeverity.critical,
    ),
  );

  archTest(
    args,
    layerCannotDependOnPreset(
      from: 'lib/domain',
      to: 'lib/data',
      severity: RuleSeverity.critical,
    ),
  );

  archTest(
    args,
    layerCannotDependOnPreset(
      from: 'lib/domain',
      to: 'flutter',
      severity: RuleSeverity.critical,
    ),
  );

  // Whitelist: the only thing domain is allowed to import
  // This catches any future forbidden dependency not yet on the blacklist
  archTest(
    args,
    layerCanOnlyDependOnPreset(
      folder: 'lib/domain',
      allowedFolders: ['lib/domain', 'lib/core'],
      severity: RuleSeverity.error,
    ),
  );
}
```

The whitelist rule at the bottom is the safety net. Even if a new developer imports a package that isn't on the blacklist, the whitelist rule catches it because it isn't on the allowed list either.

---

## Using the `exceptions` parameter

When you have a file that must temporarily violate a rule — perhaps a bridge adapter during a migration, or a generated file that imports from the wrong layer — you can exempt it by path substring:

```dart title="arch_test/presentation_no_data_arch_test.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(
  args,
  layerCannotDependOnPreset(
    from: 'lib/presentation',
    to: 'lib/data',
    severity: RuleSeverity.error,
    exceptions: [
      // Legacy screen being migrated in issue #301.
      // Remove this exception once migration is complete.
      'lib/presentation/screens/legacy_checkout_screen.dart',
    ],
  ),
);
```

Treat each exception entry as a known debt item. Include a comment explaining why the exception exists and a reference to where it is tracked. Review exceptions during each sprint to ensure they are actually being addressed.

---

## What the violation message looks like

When a violation is detected, the output follows this format:

```
VIOLATION [error] <from_layer> must not depend on <to_layer>
  File:   <path to the file containing the forbidden import>
  Import: <the specific import statement that violates the rule>
```

For example, a rule with `from: 'lib/domain'` and `to: 'lib/data'` producing a violation looks like:

```
VIOLATION [error] lib/domain must not depend on lib/data
  File:   lib/domain/entities/product.dart
  Import: package:my_app/data/models/product_dto.dart

VIOLATION [error] lib/domain must not depend on lib/data
  File:   lib/domain/usecases/fetch_products_usecase.dart
  Import: package:my_app/data/sources/product_api_client.dart

2 violation(s) found. Exit code: 1
```

Each violation is a separate line item, making it straightforward to open each file and remove or replace the forbidden import.

---

## Choosing `from` and `to` values

The most common source of confusion is picking substring values that are either too broad or don't match the actual import paths in your project.

**Too broad — avoid:**

```dart
layerCannotDependOnPreset(
  from: 'domain',   // matches lib/domain, but also package:domain_events, etc.
  to: 'data',       // matches lib/data, but also 'package:intl' (contains 'data'? no, but others might)
)
```

**Precise — prefer:**

```dart
layerCannotDependOnPreset(
  from: 'lib/domain',
  to: 'lib/data',
)
```

**For external packages, use the package name:**

```dart
layerCannotDependOnPreset(
  from: 'lib/domain',
  to: 'flutter',  // matches package:flutter/material.dart, package:flutter/widgets.dart, etc.
)
```

**For specific packages that might have ambiguous names, use the full package prefix:**

```dart
layerCannotDependOnPreset(
  from: 'lib/domain',
  to: 'package:dio',  // more specific than just 'dio' if needed
)
```

---

## Performance characteristics

`layerCannotDependOnPreset` generates a single rule that scans all files matching the `from` path substring. For large projects with many files in the `from` folder, this scan is performed once per rule. If you call the function 10 times in one rule file, each generates a separate scan. This is fine for most projects. For very large codebases with tens of thousands of files, group related prohibitions in the same file to minimize redundant file scanning.

---

## Relationship to other presets

| Preset | What it does | When to use it |
|--------|-------------|----------------|
| `layerCannotDependOnPreset` | Blacklist: forbid one specific dependency direction | Targeted prohibition, incremental adoption, banning external packages |
| [`layeredArchitecturePreset`](/presets/layered-architecture) | Full declaration: generates all forbidden pairs from allowed pairs | When declaring the complete architecture at once |
| [`layerCanOnlyDependOnPreset`](/presets/layer-can-only-depend-on) | Whitelist: only explicitly allowed imports are permitted | Strictest control; use for the most critical layers |
