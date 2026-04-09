---
title: layerCannotDependOn
description: Forbid a layer from importing code from one or more specified layers. Targeted dependency prohibition without declaring the full architecture.
sidebar:
  order: 2
---

`layerCannotDependOn` forbids one layer from importing anything from specified layers. It is a direct, focused tool: you name the forbidden direction, and DartUnit enforces it automatically.

Unlike [`layeredArchitecture`](/presets/layered-architecture), which requires declaring every layer and derives all forbidden pairs from the allowed pairs, `layerCannotDependOn` makes no assumptions about the rest of your architecture. It adds exactly the constraints you specify. Use it on its own, stack multiple calls in a single file, or mix it with other presets.

## Function signature

```dart
void layerCannotDependOn({
  required String from,
  required List<String> to,
  RuleSeverity severity = RuleSeverity.error,
  List<String> exceptions = const [],
  String projectRoot = '.',
})
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `from` | `String` | required | Path substring identifying the layer that must not import from the `to` folders. Any file whose path contains this string is subject to the rule. |
| `to` | `List<String>` | required | Path substrings identifying the forbidden dependency targets. Can be local folder paths (`'lib/data'`) or package name substrings (`'flutter'`, `'dio'`). |
| `severity` | `RuleSeverity` | `RuleSeverity.error` | How violations are reported. `warning` exits with code 0. `error` and `critical` exit with code 1. |
| `exceptions` | `List<String>` | `const []` | File path substrings to exempt from this rule. |

## Basic usage

```dart title="test_arch/domain_isolation_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() => layerCannotDependOn(
  from: 'lib/domain',
  to: ['lib/data', 'lib/presentation', 'flutter'],
  severity: RuleSeverity.critical,
);
```

## When to use this preset

### Adding one specific constraint to an existing project

When you want to enforce a single critical boundary without touching anything else. Suppose your team has agreed that the domain layer must never import from Flutter — you don't need to declare five other layers to express that. One call, one constraint, enforced in CI.

```dart title="test_arch/domain_no_flutter_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() => layerCannotDependOn(
  from: 'lib/domain',
  to: ['flutter'],
  severity: RuleSeverity.critical,
);
```

### Incremental adoption

When introducing DartUnit to a project with accumulated technical debt, enforcing the full architecture at once may produce hundreds of violations. Start with the constraint that matters most, fix the violations, then add the next:

```dart title="test_arch/domain_isolation_test_arch.dart"
import 'package:dartunit/dartunit.dart';

// Week 1: enforce the single most critical constraint
void main() => layerCannotDependOn(
  from: 'lib/domain',
  to: ['lib/data'],
  severity: RuleSeverity.error,
);
```

Once this produces zero violations, add more `to` targets or call additional presets.

### Banning external packages from a layer

`layerCannotDependOn` is the correct tool for banning external packages from a layer. The `to` parameter performs substring matching against import paths, so `'dio'` matches `package:dio/dio.dart`, `package:dio/src/response.dart`, and any other dio import.

```dart title="test_arch/domain_pure_test_arch.dart"
import 'package:dartunit/dartunit.dart';

/// The domain layer must never depend on framework or infrastructure packages.
void main() => layerCannotDependOn(
  from: 'lib/domain',
  to: ['flutter', 'dio', 'http', 'get_it', 'hive', 'shared_preferences'],
  severity: RuleSeverity.critical,
);
```

## Examples

### Example 1 — Domain isolation

```dart title="test_arch/domain_isolation_test_arch.dart"
import 'package:dartunit/dartunit.dart';

/// The domain layer contains business logic and must remain:
/// - Flutter-agnostic (testable with plain dart test)
/// - Infrastructure-agnostic (no HTTP, database, or storage dependencies)
/// - UI-agnostic (no knowledge of how data is displayed)
void main() => layerCannotDependOn(
  from: 'lib/domain',
  to: ['lib/presentation', 'lib/data', 'flutter', 'dio'],
  severity: RuleSeverity.critical,
);
```

### Example 2 — Prevent BLoC from depending on Views

```dart title="test_arch/bloc_isolation_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() => layerCannotDependOn(
  from: 'lib/bloc',
  to: ['lib/presentation', 'lib/views'],
  severity: RuleSeverity.error,
);
```

### Example 3 — Models must not depend on BLoC

```dart title="test_arch/models_isolation_test_arch.dart"
import 'package:dartunit/dartunit.dart';

/// Data models hold pure data and must not know about state management.
void main() => layerCannotDependOn(
  from: 'lib/models',
  to: ['lib/bloc', 'lib/blocs'],
  severity: RuleSeverity.error,
);
```

### Example 4 — Core utilities must not depend on feature code

```dart title="test_arch/core_isolation_test_arch.dart"
import 'package:dartunit/dartunit.dart';

/// lib/core is a foundation layer — it must not depend on feature modules.
void main() => layerCannotDependOn(
  from: 'lib/core',
  to: ['lib/features'],
  severity: RuleSeverity.error,
);
```

### Example 5 — Multiple targeted constraints

Call the preset multiple times or use `testArchGroup` to group related constraints:

```dart title="test_arch/domain_strict_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  // All forbidden dependencies for the domain layer in a single call
  layerCannotDependOn(
    from: 'lib/domain',
    to: [
      'lib/presentation',   // No UI
      'lib/data',           // No infrastructure
      'flutter',            // No Flutter framework
      'dio',                // No HTTP client
      'hive',               // No local database
    ],
    severity: RuleSeverity.critical,
  );

  // The core utilities layer also has restrictions
  layerCannotDependOn(
    from: 'lib/core',
    to: ['lib/features', 'lib/bloc'],
    severity: RuleSeverity.error,
  );
}
```

## Using exceptions

Exempt specific files from a rule when they legitimately need the dependency during a migration:

```dart title="test_arch/presentation_no_data_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() => layerCannotDependOn(
  from: 'lib/presentation',
  to: ['lib/data'],
  severity: RuleSeverity.error,
  exceptions: [
    // Legacy screen being migrated in issue #301.
    // Remove this exception once migration is complete.
    'lib/presentation/screens/legacy_checkout_screen.dart',
  ],
);
```

:::caution[Treat exceptions as tracked debt]
Document why each exception exists with a comment and a reference to the issue that will remove it. An exception list that grows over time signals that enforcement is being avoided.
:::

## Combining with layerCanOnlyDependOn

For the most critical layers, use both a blacklist and a whitelist:

```dart title="test_arch/domain_strict_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  // Blacklist: known forbidden dependencies
  layerCannotDependOn(
    from: 'lib/domain',
    to: ['lib/presentation', 'lib/data', 'flutter', 'dio'],
    severity: RuleSeverity.critical,
  );

  // Whitelist: catch any future forbidden dependency not yet on the blacklist
  layerCanOnlyDependOn(
    layer: 'lib/domain',
    allowed: ['lib/domain', 'lib/core'],
    severity: RuleSeverity.error,
  );
}
```

The whitelist is the safety net. Even if a new developer imports a package that isn't on the blacklist, the whitelist catches it because it isn't in the allowed list.

## Violation output

```
  ✗  "lib/domain" must not depend on "lib/data"
       ✗ lib/domain/entities/product.dart [critical] — depends on lib/data
       ✗ lib/domain/usecases/fetch_products_usecase.dart [critical] — depends on lib/data

2 violation(s) found
```

## Related presets

| Preset | What it does |
|--------|-------------|
| [`layeredArchitecture`](/presets/layered-architecture) | Declares all layers at once; generates all forbidden pairs automatically |
| [`layerCanOnlyDependOn`](/presets/layer-can-only-depend-on) | Whitelist: only explicitly allowed imports are permitted |
