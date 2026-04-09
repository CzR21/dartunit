---
title: layeredArchitecture
description: Declare all layers with their allowed dependencies and automatically generate "must not depend on" rules for every forbidden pair.
sidebar:
  order: 1
---

`layeredArchitecture` is the most comprehensive preset in DartUnit. You declare every layer in your architecture and specify which other layers each one is allowed to access. The preset then computes the full set of forbidden dependency pairs and generates one rule per forbidden pair — automatically, without you having to enumerate them manually.

A project with five layers has up to 20 directional pairs. Without this preset, you would write 20 separate `testArch` calls. With it, you write one function call and every combination is covered.

## Function signature

```dart
void layeredArchitecture({
  required List<({String name, String folder, List<String> canAccess})> layers,
  RuleSeverity severity = RuleSeverity.error,
  List<String> exceptions = const [],
  String projectRoot = '.',
})
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `layers` | `List<({...})>` | required | The full list of layer definitions using Dart record syntax. Each entry declares a layer name, its folder path, and which other folders it may import from. |
| `severity` | `RuleSeverity` | `RuleSeverity.error` | The severity applied to every generated rule. Use `RuleSeverity.warning` when adopting incrementally. |
| `exceptions` | `List<String>` | `const []` | File path substrings to exempt from all generated rules. Useful for generated files or legacy bridging code. |

### Layer record fields

Each entry in the `layers` list is a Dart record with three fields:

| Field | Type | Description |
|-------|------|-------------|
| `name` | `String` | Human-readable name shown in violation messages. Use descriptive names like `'Domain'` or `'Presentation'`. |
| `folder` | `String` | A path substring that identifies all files in this layer. `'lib/domain'` matches any file whose path contains `lib/domain`. |
| `canAccess` | `List<String>` | The folder substrings this layer is permitted to import. Pass an empty list `[]` if this layer must not import from any other layer. |

## How rules are generated

Given a list of layer entries, the preset computes a Cartesian product of all layer pairs and generates a forbidden rule for every pair where the `from` layer's `canAccess` list does not include the `to` layer's folder.

```
Layers: A (canAccess: [B, C]), B (canAccess: [C]), C (canAccess: [])

Forbidden pairs generated:
  A → D  (if D exists)
  B → A  FORBIDDEN
  C → A  FORBIDDEN
  C → B  FORBIDDEN

Allowed pairs (no rule generated):
  A → B  ALLOWED
  A → C  ALLOWED
  B → C  ALLOWED
```

For four layers, the preset generates up to 12 forbidden-pair rules. For five layers, up to 20. For six, up to 30. The preset scales; manual rule writing does not.

## Basic usage

```dart title="test_arch/clean_architecture_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() => layeredArchitecture(
  layers: [
    (
      name: 'Presentation',
      folder: 'lib/presentation',
      canAccess: ['lib/domain'],
    ),
    (
      name: 'Data',
      folder: 'lib/data',
      canAccess: ['lib/domain'],
    ),
    (
      name: 'Domain',
      folder: 'lib/domain',
      canAccess: [],
    ),
  ],
  severity: RuleSeverity.error,
);
```

## Examples

### Example 1 — Clean Architecture

Clean Architecture places business logic at the center. Dependencies always point inward: UI depends on domain, infrastructure depends on domain, domain depends on nothing.

```
    ┌─────────────┐      ┌─────────────┐
    │ Presentation│      │    Data     │
    └──────┬──────┘      └──────┬──────┘
           │  depends on         │  depends on
           ▼                     ▼
    ┌──────────────────────────────────┐
    │              Domain              │
    │   (no dependencies on others)   │
    └──────────────────────────────────┘
```

```dart title="test_arch/clean_architecture_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() => layeredArchitecture(
  layers: [
    (
      name: 'Presentation',
      folder: 'lib/presentation',
      canAccess: ['lib/domain'],
    ),
    (
      name: 'Data',
      folder: 'lib/data',
      canAccess: ['lib/domain'],
    ),
    (
      name: 'Domain',
      folder: 'lib/domain',
      canAccess: [],
    ),
  ],
  severity: RuleSeverity.error,
);
```

**Generated rules for this configuration:**

| From | To | Result |
|------|----|--------|
| Presentation | Data | **FORBIDDEN** — widgets must not call repositories directly |
| Presentation | Domain | ALLOWED |
| Data | Presentation | **FORBIDDEN** — repositories must not know about the UI |
| Data | Domain | ALLOWED |
| Domain | Presentation | **FORBIDDEN** — the most critical constraint |
| Domain | Data | **FORBIDDEN** — domain must not know how data is fetched |

**What this prevents:**
- A screen widget directly instantiating a `UserRepositoryImpl` (which contains `Dio`)
- A domain use case importing a Flutter widget to retrieve a theme color
- A data repository calling Navigator to redirect after a 401 response

### Example 2 — BLoC Architecture

Many Flutter teams use a BLoC-centric architecture without a formal domain layer:

```
    ┌──────────┐
    │   Views  │  depends on
    └────┬─────┘
         │
         ▼
    ┌──────────┐  depends on
    │  BLoCs   │────────────┐
    └──────────┘            │
                            ▼
                      ┌──────────┐
                      │  Models  │
                      └──────────┘
```

```dart title="test_arch/bloc_architecture_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() => layeredArchitecture(
  layers: [
    (
      name: 'Views',
      folder: 'lib/views',
      canAccess: ['lib/blocs', 'lib/models'],
    ),
    (
      name: 'BLoCs',
      folder: 'lib/blocs',
      canAccess: ['lib/models'],
    ),
    (
      name: 'Models',
      folder: 'lib/models',
      canAccess: [],
    ),
  ],
  severity: RuleSeverity.error,
);
```

### Example 3 — Full Flutter BLoC (4 layers)

A complete Flutter project with BLoC separating presentation, state management, business logic, and data:

```
Presentation ──► BLoC ──► Domain ◄── Data
```

```dart title="test_arch/flutter_bloc_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() => layeredArchitecture(
  layers: [
    (
      name: 'Presentation',
      folder: 'lib/presentation',
      canAccess: ['lib/bloc', 'lib/domain'],
    ),
    (
      name: 'BLoC',
      folder: 'lib/bloc',
      canAccess: ['lib/domain'],
    ),
    (
      name: 'Domain',
      folder: 'lib/domain',
      canAccess: [],
    ),
    (
      name: 'Data',
      folder: 'lib/data',
      canAccess: ['lib/domain'],
    ),
  ],
  severity: RuleSeverity.error,
);
```

**Generated rules:** 10 forbidden pairs from 4 layers.

Notable constraints:
- BLoC must not import from Presentation (prevents BLoC from triggering navigation directly)
- Data must not import from BLoC (prevents repositories from dispatching events)
- Domain must not import from any of the three surrounding layers

### Example 4 — Feature-Based Architecture

Larger applications often adopt feature-based folder structures where each feature is self-contained:

```dart title="test_arch/feature_architecture_test_arch.dart"
import 'package:dartunit/dartunit.dart';

/// Features are isolated from each other.
/// All features may use shared utilities and core abstractions.
void main() => layeredArchitecture(
  layers: [
    (
      name: 'Feature: Authentication',
      folder: 'lib/features/auth',
      canAccess: ['lib/shared', 'lib/core'],
    ),
    (
      name: 'Feature: Profile',
      folder: 'lib/features/profile',
      canAccess: ['lib/shared', 'lib/core'],
    ),
    (
      name: 'Feature: Dashboard',
      folder: 'lib/features/dashboard',
      canAccess: ['lib/shared', 'lib/core'],
    ),
    (
      name: 'Shared',
      folder: 'lib/shared',
      canAccess: ['lib/core'],
    ),
    (
      name: 'Core',
      folder: 'lib/core',
      canAccess: [],
    ),
  ],
  severity: RuleSeverity.error,
);
```

**What this enforces:** The three feature layers cannot import from each other. If the dashboard feature needs data from the auth feature, it must flow through a shared abstraction in `lib/shared` or `lib/core` — not through a direct import.

## Using exceptions

Some files legitimately bridge layers during a migration period, or are auto-generated and cannot be refactored:

```dart title="test_arch/architecture_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() => layeredArchitecture(
  layers: [
    (name: 'Domain', folder: 'lib/domain', canAccess: []),
    (name: 'Data', folder: 'lib/data', canAccess: ['lib/domain']),
    (name: 'Presentation', folder: 'lib/presentation', canAccess: ['lib/domain']),
  ],
  severity: RuleSeverity.error,
  exceptions: [
    // Generated code from build_runner — cannot be refactored
    'lib/data/models/user_model.g.dart',
    // Legacy bridge file tracked in issue #482
    'lib/presentation/legacy/old_user_screen.dart',
  ],
);
```

:::caution[Use exceptions sparingly]
Each exception is a known compromise. Document why it exists with a comment, and include a reference to the issue that will eventually eliminate it. An exception list that grows over time signals that enforcement is being avoided rather than the architecture being fixed.
:::

## Incremental adoption

If you are adding this preset to an existing project with existing violations, start with `RuleSeverity.warning`. This lets you see the full scope of violations without immediately breaking CI:

```dart title="test_arch/architecture_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() => layeredArchitecture(
  layers: [
    (name: 'Domain', folder: 'lib/domain', canAccess: []),
    (name: 'Data', folder: 'lib/data', canAccess: ['lib/domain']),
    (name: 'Presentation', folder: 'lib/presentation', canAccess: ['lib/domain']),
  ],
  // Start with warning so CI doesn't immediately break.
  // Fix violations, then escalate to error.
  severity: RuleSeverity.warning,
);
```

Run `dart run dartunit analyze`, review the report, work through the violations systematically, and once the count reaches zero, promote the severity to `RuleSeverity.error`.

## Combining with other presets

`layeredArchitecture` covers inter-layer dependency directions. Combine it with other presets for a complete rule set:

```dart title="test_arch/full_rules_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  // Layer direction rules (all forbidden pairs)
  layeredArchitecture(
    layers: [
      (name: 'Presentation', folder: 'lib/presentation', canAccess: ['lib/bloc', 'lib/domain']),
      (name: 'BLoC', folder: 'lib/bloc', canAccess: ['lib/domain']),
      (name: 'Domain', folder: 'lib/domain', canAccess: []),
      (name: 'Data', folder: 'lib/data', canAccess: ['lib/domain']),
    ],
    severity: RuleSeverity.error,
  );

  // Explicit ban on external packages in the domain layer
  layerCannotDependOn(
    from: 'lib/domain',
    to: ['flutter', 'dio', 'http', 'get_it'],
    severity: RuleSeverity.critical,
  );

  // Belt-and-suspenders: whitelist what domain CAN depend on
  layerCanOnlyDependOn(
    layer: 'lib/domain',
    allowed: ['lib/domain'],
    severity: RuleSeverity.error,
  );
}
```

## Common mistakes

### Forgetting to register a layer

If a folder exists in your codebase but is not declared as a layer entry, imports from that folder are invisible to the preset. A file in `lib/services` importing from `lib/domain` will not be flagged if `lib/services` is not registered.

### Circular allowed dependencies

If Layer A lists Layer B in `canAccess`, and Layer B also lists Layer A in `canAccess`, no forbidden rule is generated for either direction. This creates a circular dependency — both layers can import from each other, effectively making them one tightly-coupled unit. The preset does not warn about circular `canAccess` relationships.

### Mismatched folder values

The strings in `canAccess` must exactly match the `folder` values of other layer entries — because matching is done by substring comparison against import paths:

```dart
// Correct
(name: 'Presentation', folder: 'lib/presentation', canAccess: ['lib/domain']),

// Wrong — 'domain' without 'lib/' matches too broadly
(name: 'Presentation', folder: 'lib/presentation', canAccess: ['domain']),
```

Always use the full relative path prefix (e.g., `'lib/domain'`, not just `'domain'`).

### External package dependencies

`layeredArchitecture` analyzes internal import paths. It does not ban `package:flutter` or `package:dio`. For external package bans, use [`layerCannotDependOn`](/presets/layer-cannot-depend-on) with the package name.

## Violation output

When a violation is found, the output identifies the rule, the file, and the specific class that caused it:

```
  ✗  Layer "Domain" must not depend on layer "Data"
       ✗ lib/domain/entities/user.dart [error] — depends on lib/data

1 violation(s) found
```

The HTML report at `.dartunit/report.html` provides the full violation table with severity badges and clickable file paths.
