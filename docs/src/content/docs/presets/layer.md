---
title: Layer Presets
description: Presets for defining and enforcing layered architecture dependency rules.
sidebar:
  order: 1
---

The layer presets are the most commonly used presets in DartUnit. They define the allowed dependency directions in a layered architecture and generate a rule for every forbidden import path.

---

## layeredArchitecturePreset

Defines a complete layered architecture. For every pair of layers where access is not explicitly permitted, the preset generates an `ArchitectureRule` that forbids the import.

### Function signature

```dart
List<ArchitectureRule> layeredArchitecturePreset({
  required List<LayerDefinition> layers,
  RuleSeverity severity = RuleSeverity.error,
  List<String> exceptions = const [],
})
```

### LayerDefinition

```dart
LayerDefinition({
  required String name,
  required String folder,
  required List<String> canAccess,
})
```

| Field | Type | Description |
|-------|------|-------------|
| `name` | `String` | Human-readable layer name shown in violation messages |
| `folder` | `String` | Folder path that defines this layer (substring match) |
| `canAccess` | `List<String>` | Folder paths this layer is permitted to import from |

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `layers` | `List<LayerDefinition>` | required | Layer definitions with their access rules |
| `severity` | `RuleSeverity` | `RuleSeverity.error` | Severity for generated rules |
| `exceptions` | `List<String>` | `[]` | File paths exempt from all generated rules |

### Example — Flutter Clean Architecture

```dart title="arch_test/clean_architecture_arch_test.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) {
  final rules = layeredArchitecturePreset(
    layers: [
      LayerDefinition(
        name: 'Presentation',
        folder: 'lib/presentation',
        canAccess: ['lib/bloc', 'lib/domain'],
      ),
      LayerDefinition(
        name: 'Bloc',
        folder: 'lib/bloc',
        canAccess: ['lib/domain'],
      ),
      LayerDefinition(
        name: 'Domain',
        folder: 'lib/domain',
        canAccess: [], // domain depends on nobody
      ),
      LayerDefinition(
        name: 'Data',
        folder: 'lib/data',
        canAccess: ['lib/domain'], // data implements domain contracts
      ),
    ],
    severity: RuleSeverity.error,
  );

  for (final rule in rules) {
    archTest(args, rule);
  }
}
```

**Rules automatically generated for this configuration:**

| From | To | Direction |
|------|----|-----------|
| Presentation | Data | FORBIDDEN |
| Bloc | Data | FORBIDDEN |
| Bloc | Presentation | FORBIDDEN |
| Domain | Bloc | FORBIDDEN |
| Domain | Data | FORBIDDEN |
| Domain | Presentation | FORBIDDEN |
| Data | Bloc | FORBIDDEN |
| Data | Presentation | FORBIDDEN |

### Example — MVC Architecture

```dart title="arch_test/mvc_arch_test.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) {
  final rules = layeredArchitecturePreset(
    layers: [
      LayerDefinition(name: 'View', folder: 'lib/views', canAccess: ['lib/controllers']),
      LayerDefinition(name: 'Controller', folder: 'lib/controllers', canAccess: ['lib/models']),
      LayerDefinition(name: 'Model', folder: 'lib/models', canAccess: []),
    ],
    severity: RuleSeverity.error,
  );

  for (final rule in rules) {
    archTest(args, rule);
  }
}
```

### Example — Feature-First with Shared Core

```dart title="arch_test/feature_first_arch_test.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) {
  final rules = layeredArchitecturePreset(
    layers: [
      LayerDefinition(
        name: 'Features',
        folder: 'lib/features',
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
  );

  for (final rule in rules) {
    archTest(args, rule);
  }
}
```

---

## layerCannotDependOnPreset

Generates a single rule that forbids one layer from importing another. Simpler than `layeredArchitecturePreset` when you only need to add a specific prohibition.

### Function signature

```dart
ArchitectureRule layerCannotDependOnPreset({
  required String from,
  required String to,
  RuleSeverity severity = RuleSeverity.error,
  List<String> exceptions = const [],
})
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `from` | `String` | required | The folder (or package) that must not import from `to` |
| `to` | `String` | required | The folder (or package) that must not be imported by `from` |
| `severity` | `RuleSeverity` | `RuleSeverity.error` | Violation severity |
| `exceptions` | `List<String>` | `[]` | File paths to exempt |

### Example — Domain must not use Flutter

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

### Example — Presentation must not access data directly

```dart title="arch_test/presentation_arch_test.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) {
  archTest(
    args,
    layerCannotDependOnPreset(
      from: 'lib/presentation',
      to: 'lib/data',
      severity: RuleSeverity.error,
    ),
  );

  archTest(
    args,
    layerCannotDependOnPreset(
      from: 'lib/presentation',
      to: 'dio',
      severity: RuleSeverity.error,
    ),
  );
}
```

### When to use vs layeredArchitecturePreset

| Situation | Recommendation |
|-----------|---------------|
| Defining the complete architecture at once | `layeredArchitecturePreset` |
| Adding one specific prohibition to an existing rule set | `layerCannotDependOnPreset` |
| Banning a package from a layer | `layerCannotDependOnPreset` |

---

## layerCanOnlyDependOnPreset

Generates a rule that restricts a layer to a whitelist of allowed imports. Any import not in the whitelist causes a violation.

### Function signature

```dart
ArchitectureRule layerCanOnlyDependOnPreset({
  required String folder,
  required List<String> allowedFolders,
  RuleSeverity severity = RuleSeverity.error,
  List<String> exceptions = const [],
})
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `folder` | `String` | required | The layer to restrict |
| `allowedFolders` | `List<String>` | required | Folders this layer is allowed to import from |
| `severity` | `RuleSeverity` | `RuleSeverity.error` | Violation severity |
| `exceptions` | `List<String>` | `[]` | File paths to exempt |

### Example — Strict domain isolation

```dart title="arch_test/domain_isolation_arch_test.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(
  args,
  layerCanOnlyDependOnPreset(
    folder: 'lib/domain',
    allowedFolders: [
      'lib/domain',  // can import from itself
      'lib/shared',  // shared utilities
      'lib/core',    // core abstractions
    ],
    severity: RuleSeverity.error,
  ),
);
```

### Example — Bloc layer whitelist

```dart title="arch_test/bloc_imports_arch_test.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(
  args,
  layerCanOnlyDependOnPreset(
    folder: 'lib/bloc',
    allowedFolders: [
      'lib/bloc',
      'lib/domain',
      'lib/shared',
    ],
    severity: RuleSeverity.error,
  ),
);
```

---

## Combining layer presets

It is common to combine all three layer presets in different files or within the same file:

```dart title="arch_test/full_architecture_arch_test.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) {
  // Main architecture: layered rules
  final layerRules = layeredArchitecturePreset(
    layers: [
      LayerDefinition(name: 'Domain', folder: 'lib/domain', canAccess: []),
      LayerDefinition(name: 'Data', folder: 'lib/data', canAccess: ['lib/domain']),
      LayerDefinition(name: 'Bloc', folder: 'lib/bloc', canAccess: ['lib/domain']),
      LayerDefinition(name: 'Presentation', folder: 'lib/presentation', canAccess: ['lib/bloc', 'lib/domain']),
    ],
  );
  for (final rule in layerRules) {
    archTest(args, rule);
  }

  // Additional: domain must not use Flutter (stricter than the layer rules)
  archTest(args, layerCannotDependOnPreset(
    from: 'lib/domain',
    to: 'flutter',
    severity: RuleSeverity.critical,
  ));

  // Additional: domain must not use any HTTP library
  archTest(args, layerCannotDependOnPreset(
    from: 'lib/domain',
    to: 'dio',
    severity: RuleSeverity.error,
  ));
}
```
