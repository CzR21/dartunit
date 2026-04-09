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

## All 15 Presets

### Layer presets

| Preset | Description |
|--------|-------------|
| [`layeredArchitecture`](/presets/layered-architecture) | Declares all layers with allowed dependencies and generates a rule for every forbidden pair |
| [`layerCanOnlyDependOn`](/presets/layer-can-only-depend-on) | A layer may only import from an explicitly allowed set of folders (whitelist) |
| [`layerCannotDependOn`](/presets/layer-cannot-depend-on) | A layer must not import from specific folders (blacklist) |

### Naming presets

| Preset | Description |
|--------|-------------|
| [`namingFolderSuffix`](/presets/naming-folder-suffix) | Classes in a folder must end with the folder's base name capitalized (e.g., `lib/bloc` → must end with `Bloc`) |
| [`namingFileSuffix`](/presets/naming-file-suffix) | Files in a folder must match a naming pattern (file-level naming convention) |
| [`namingNamePattern`](/presets/naming-name-pattern) | Classes in folders must match a custom regex pattern |

### Structure presets

| Preset | Description |
|--------|-------------|
| [`mustBeAbstract`](/presets/must-be-abstract) | Classes in the specified folders must be declared `abstract` |
| [`mustBeImmutable`](/presets/must-be-immutable) | All instance fields in the specified folders must be `final` |
| [`noPublicFields`](/presets/no-public-fields) | Classes in the specified folders must have no public fields |
| [`noCircularDependencies`](/presets/no-circular-dependencies) | No class anywhere in the project may be part of a circular import chain |

### Metrics presets

| Preset | Description |
|--------|-------------|
| [`classSizeLimit`](/presets/class-size-limit) | Classes must not exceed a specified number of methods and/or fields |

### Quality presets

| Preset | Description |
|--------|-------------|
| [`noBannedCalls`](/presets/no-banned-calls) | Files must not contain any of the specified regex patterns |
| [`noExternalPackage`](/presets/no-external-package) | Classes in the specified folders must not import from specified packages |

### Annotation presets

| Preset | Description |
|--------|-------------|
| [`annotationMustHave`](/presets/annotation-must-have) | Classes in the specified folders must have a specific annotation |
| [`annotationMustNotHave`](/presets/annotation-must-not-have) | Classes in the specified folders must not have a specific annotation |

## Preset Signatures

All presets accept `severity` (default `RuleSeverity.error`) and `projectRoot` (default `'.'`).

```dart
// Naming presets
namingFolderSuffix(folders: ['lib/service'])
namingFolderSuffix(folders: ['lib/bloc'], suffix: 'Bloc')
namingFolderSuffix(folders: ['lib/bloc'], namePattern: r'.*(Bloc|Cubit)$')
namingFileSuffix(folders: ['lib/services'], suffix: '_service')
namingFileSuffix(folders: ['lib/bloc'], namePattern: r'.*(bloc|cubit)\.dart$')
namingNamePattern(pattern: r'.*Bloc$', folders: ['lib/bloc'])

// Structure presets
mustBeAbstract(folders: ['lib/domain/repositories'])
mustBeImmutable(folders: ['lib/domain/entities'])
noPublicFields(folders: ['lib/domain'])
noCircularDependencies()

// Layer presets
layerCannotDependOn(from: 'lib/domain', to: ['lib/data', 'lib/ui'])
layerCanOnlyDependOn(layer: 'lib/domain', allowed: ['lib/domain', 'lib/shared'])
layeredArchitecture(layers: [
  (name: 'ui',     folder: 'lib/ui',     canAccess: ['lib/bloc', 'lib/domain']),
  (name: 'bloc',   folder: 'lib/bloc',   canAccess: ['lib/domain']),
  (name: 'domain', folder: 'lib/domain', canAccess: []),
])

// Annotation presets
annotationMustHave(annotation: 'injectable', folders: ['lib/data/repository'])
annotationMustNotHave(annotation: 'deprecated', folders: ['lib/ui'])

// Metrics / Quality presets
classSizeLimit(maxMethods: 20, maxFields: 15, folders: ['lib'])
noExternalPackage(packages: ['http', 'dio'], folders: ['lib/domain'])
noBannedCalls(patterns: [r'print\s*\(', r'debugPrint\s*\('], excludeFolders: ['test'])
```

## Mixing Presets and Custom Rules

A single rule file can compose presets alongside custom `testArch` calls:

```dart title="test_arch/domain_quality_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  // Presets — concise and comprehensive
  mustBeImmutable(folders: ['lib/domain/entities']);
  mustBeAbstract(folders: ['lib/domain/repositories']);
  noPublicFields(folders: ['lib/domain']);

  // Custom rule — fine-grained control
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

Templates generate a ready-to-run `*_test_arch.dart` file with all rules inlined and folder constants at the top for easy customization. No external function calls — just standard `testArchGroup`/`testArch`/`expect`, so you can see and modify every rule.

## Detailed Preset Documentation

- [Layer Presets](/presets/layered-architecture) — `layeredArchitecture`, `layerCanOnlyDependOn`, `layerCannotDependOn`
- [Naming Presets](/presets/naming-folder-suffix) — `namingFolderSuffix`, `namingFileSuffix`, `namingNamePattern`
- [Structure Presets](/presets/must-be-abstract) — `mustBeAbstract`, `mustBeImmutable`, `noPublicFields`, `noCircularDependencies`
- [Metrics & Quality](/presets/class-size-limit) — `classSizeLimit`, `noBannedCalls`, `noExternalPackage`
- [Annotation Presets](/presets/annotation-must-have) — `annotationMustHave`, `annotationMustNotHave`
