---
title: Layer Presets
description: Presets for defining and enforcing layered architecture dependency rules.
sidebar:
  order: 1
---

The layer presets are the most commonly used presets in DartUnit. They define the allowed dependency directions in a layered architecture and generate a rule for every forbidden import path.

---

## layeredArchitecture

Defines a complete layered architecture. For every pair of layers where access is not explicitly permitted, the preset generates an `ArchitectureRule` that forbids the import.

### Function signature

```dart
List<ArchitectureRule> layeredArchitecture({
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

```dart title="test_arch/clean_architecture_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) {
  final rules = layeredArchitecture(
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

```dart title="test_arch/mvc_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) {
  final rules = layeredArchitecture(
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

```dart title="test_arch/feature_first_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) {
  final rules = layeredArchitecture(
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

## layerCannotDependOn

Generates a single rule that forbids one layer from importing another. Simpler than `layeredArchitecture` when you only need to add a specific prohibition.

### Function signature

```dart
ArchitectureRule layerCannotDependOn({
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

```dart title="test_arch/domain_no_flutter_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(
  args,
  layerCannotDependOn(
    from: 'lib/domain',
    to: 'flutter',
    severity: RuleSeverity.critical,
  ),
);
```

### Example — Presentation must not access data directly

```dart title="test_arch/presentation_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) {
  archTest(
    args,
    layerCannotDependOn(
      from: 'lib/presentation',
      to: 'lib/data',
      severity: RuleSeverity.error,
    ),
  );

  archTest(
    args,
    layerCannotDependOn(
      from: 'lib/presentation',
      to: 'dio',
      severity: RuleSeverity.error,
    ),
  );
}
```

### When to use vs layeredArchitecture

| Situation | Recommendation |
|-----------|---------------|
| Defining the complete architecture at once | `layeredArchitecture` |
| Adding one specific prohibition to an existing rule set | `layerCannotDependOn` |
| Banning a package from a layer | `layerCannotDependOn` |

---

## layerCanOnlyDependOn

Generates a rule that restricts a layer to a whitelist of allowed imports. Any import not in the whitelist causes a violation.

### Function signature

```dart
ArchitectureRule layerCanOnlyDependOn({
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

```dart title="test_arch/domain_isolation_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(
  args,
  layerCanOnlyDependOn(
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

```dart title="test_arch/bloc_imports_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(
  args,
  layerCanOnlyDependOn(
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

```dart title="test_arch/full_architecture_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) {
  // Main architecture: layered rules
  final layerRules = layeredArchitecture(
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
  archTest(args, layerCannotDependOn(
    from: 'lib/domain',
    to: 'flutter',
    severity: RuleSeverity.critical,
  ));

  // Additional: domain must not use any HTTP library
  archTest(args, layerCannotDependOn(
    from: 'lib/domain',
    to: 'dio',
    severity: RuleSeverity.error,
  ));
}
```
