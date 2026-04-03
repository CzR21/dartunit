---
title: Presets
description: Built-in preset functions that register complete rule sets for common architectural patterns.
sidebar:
  order: 5
---

**Presets** are functions that internally call `testArchGroup` and `testArch` to register complete rule sets from a minimal configuration. Instead of writing several rules manually, you call a preset with the relevant parameters and it registers all the necessary tests.

## How to Use Presets

Import `package:dartunit/dartunit.dart` and call the preset function directly from `main()`. No iteration needed — the preset registers its tests internally:

```dart title="test_arch/naming_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() => namingFolderSuffix(
  folders: ['lib/service', 'lib/repository', 'lib/bloc'],
);
```

Multiple presets can be composed in a single file:

```dart title="test_arch/domain_rules_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  mustBeImmutable(
    folders: ['lib/domain/entities'],
    severity: RuleSeverity.error,
  );

  mustBeAbstract(
    folders: ['lib/domain/repositories'],
    severity: RuleSeverity.error,
  );

  noCircularDependencies();
}
```

## All 14 Presets

### Layer presets

| Preset | Description |
|--------|-------------|
| `layeredArchitecture` | Defines layers with allowed dependencies and generates a rule for every forbidden pair |
| `layerCanOnlyDependOn` | A layer may only import from an explicitly allowed set of folders (whitelist) |
| `layerCannotDependOn` | A layer must not import from specific folders |

### Naming presets

| Preset | Description |
|--------|-------------|
| `namingFolderSuffix` | Classes in a folder must end with the folder's base name (e.g., `lib/bloc` → must end with `Bloc`) |
| `namingNamePattern` | Classes in folders must match a regex pattern |

### Structure presets

| Preset | Description |
|--------|-------------|
| `mustBeAbstract` | Classes in the specified folders must be declared `abstract` |
| `mustBeImmutable` | All instance fields in the specified folders must be `final` |
| `noCircularDependencies` | No class anywhere in the project may be part of a circular import chain |

### Metrics presets

| Preset | Description |
|--------|-------------|
| `classSizeLimit` | Classes must not exceed a specified number of methods and/or fields |

### Quality presets

| Preset | Description |
|--------|-------------|
| `noPublicFields` | Classes in the specified folders must have no public fields |
| `noBannedCalls` | Files must not contain any of the specified regex patterns |

### Dependency presets

| Preset | Description |
|--------|-------------|
| `noExternalPackage` | Classes in the specified folders must not import from the specified packages |

### Annotation presets

| Preset | Description |
|--------|-------------|
| `annotationMustHave` | Classes in the specified folders must have a specific annotation |
| `annotationMustNotHave` | Classes in the specified folders must not have a specific annotation |

## Preset Signatures

All presets accept `severity` (default `RuleSeverity.error`) and `projectRoot` (default `'.'`).

```dart
namingFolderSuffix(folders: ['lib/service'], severity: RuleSeverity.error)
namingNamePattern(pattern: r'.*Bloc$', folders: ['lib/bloc'])
mustBeAbstract(folders: ['lib/domain/repositories'])
mustBeImmutable(folders: ['lib/domain/entities'])
noPublicFields(folders: ['lib/domain'])
noCircularDependencies()
layerCannotDependOn(from: 'lib/domain', to: ['lib/data', 'lib/ui'])
layerCanOnlyDependOn(layer: 'lib/domain', allowed: ['lib/domain', 'lib/shared'])
layeredArchitecture(layers: [
  (name: 'ui',     folder: 'lib/ui',     canAccess: ['lib/bloc', 'lib/domain']),
  (name: 'bloc',   folder: 'lib/bloc',   canAccess: ['lib/domain']),
  (name: 'domain', folder: 'lib/domain', canAccess: []),
])
annotationMustHave(annotation: 'injectable', folders: ['lib/data/repository'])
annotationMustNotHave(annotation: 'deprecated', folders: ['lib/ui'])
classSizeLimit(maxMethods: 20, maxFields: 15, folders: ['lib'])
noExternalPackage(packages: ['http', 'dio'], folders: ['lib/domain'])
noBannedCalls(patterns: [r'print\s*\(', r'debugPrint\s*\('], excludeFolders: ['test'])
```

## Mixing Presets and Custom Rules

A single rule file can compose presets alongside custom `testArch` calls:

```dart title="test_arch/domain_quality_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  // Presets
  mustBeImmutable(folders: ['lib/domain/entities']);
  mustBeAbstract(folders: ['lib/domain/repositories']);
  noPublicFields(folders: ['lib/domain']);

  // Custom rule
  testArch('Use cases must declare a call() method', (arch) {
    expect(
      arch.classes(folder: 'lib/domain/usecases'),
      hasMethod('call'),
    );
  });
}
```

## Architecture Templates

For a complete set of rules for a specific architecture pattern, use `dartunit init --template`:

```bash
dart run dartunit init --template clean  # Clean Architecture
dart run dartunit init --template bloc   # BLoC pattern
dart run dartunit init --template mvvm   # MVVM
dart run dartunit init --template mvc    # MVC
```

Templates generate a ready-to-run `*_test_arch.dart` file with all rules inlined and folder constants at the top for easy customization — no external function calls, just standard `testArchGroup`/`testArch`/`expect`.

## Detailed Preset Documentation

- [Layer Presets](/presets/layer) — `layeredArchitecture`, `layerCanOnlyDependOn`, `layerCannotDependOn`
- [Naming Presets](/presets/naming) — `namingFolderSuffix`, `namingNamePattern`
- [Structure Presets](/presets/structure) — `mustBeAbstract`, `mustBeImmutable`, `noCircularDependencies`
- [Metrics Presets](/presets/metrics) — `classSizeLimit`
- [Quality Presets](/presets/quality) — `noPublicFields`, `noBannedCalls`
- [Dependency Presets](/presets/dependency) — `noExternalPackage`
- [Annotation Presets](/presets/annotation) — `annotationMustHave`, `annotationMustNotHave`
