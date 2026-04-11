---
title: Presets — Complete Reference
description: Overview of all 15 built-in presets with links to detailed documentation.
sidebar:
  order: 3
---

Presets are functions that internally call `testArchGroup` and `testArch` to register complete rule sets from a minimal configuration. Import `package:dartunit/dartunit.dart` and call them directly in `main()`.

## All 14 Presets

| Preset | Category | What it enforces |
|--------|----------|-------------------|
| [`layeredArchitecture`](/presets/layered-architecture) | Layer | Rules for every forbidden layer pair in a multi-layer architecture |
| [`layerCanOnlyDependOn`](/presets/layer-can-only-depend-on) | Layer | A folder may only import from an allowed set of folders (whitelist) |
| [`layerCannotDependOn`](/presets/layer-cannot-depend-on) | Layer | A folder must not import from specific folders or packages (blacklist) |
| [`namingClassSuffix`](/presets/naming-class-suffix) | Naming | Classes must end with the capitalized base name of their folder |
| [`namingFileSuffix`](/presets/naming-file-suffix) | Naming | Files must match a naming pattern derived from their folder name |
| [`mustBeAbstract`](/presets/must-be-abstract) | Structure | Classes must be declared `abstract` |
| [`mustBeImmutable`](/presets/must-be-immutable) | Structure | All instance fields must be `final` or `const` |
| [`noPublicFields`](/presets/no-public-fields) | Structure | Classes must have no public fields |
| [`noCircularDependencies`](/presets/no-circular-dependencies) | Structure | No circular import chains anywhere in the project |
| [`classSizeLimit`](/presets/class-size-limit) | Metrics | Classes must not exceed a method and/or field count limit |
| [`noBannedCalls`](/presets/no-banned-calls) | Quality | Files must not contain specified regex patterns |
| [`noExternalPackage`](/presets/no-external-package) | Dependency | Folders must not import from specified external packages |
| [`annotationMustHave`](/presets/annotation-must-have) | Annotation | Classes must have a specific annotation |
| [`annotationMustNotHave`](/presets/annotation-must-not-have) | Annotation | Classes must not have a specific annotation |

## Common preset signatures

All presets follow the same conventions:

- Called directly in `void main()` — no iteration or wrapper needed
- Accept `severity: RuleSeverity` (default: `RuleSeverity.error`)
- Accept `projectRoot: String` (default: `'.'`)
- Accept `exceptions: List<String>` for path-based exemptions

```dart title="test_arch/all_presets_example_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  // Layer constraints
  layeredArchitecture(layers: [
    (name: 'Presentation', folder: 'lib/presentation', canAccess: ['lib/domain']),
    (name: 'Domain',       folder: 'lib/domain',       canAccess: []),
    (name: 'Data',         folder: 'lib/data',         canAccess: ['lib/domain']),
  ]);

  layerCannotDependOn(
    from: 'lib/domain',
    to: ['flutter', 'dio'],
    severity: RuleSeverity.critical,
  );

  // Naming conventions
  namingClassSuffix(folders: ['lib/bloc', 'lib/service', 'lib/repository']);
  namingFileSuffix(folders: ['lib/data/datasources'], suffix: '_datasource');

  // Structure rules
  mustBeAbstract(folders: ['lib/domain/repositories']);
  mustBeImmutable(folders: ['lib/domain/entities']);
  noCircularDependencies(severity: RuleSeverity.critical);

  // Quality
  noBannedCalls(
    patterns: [r'print\s*\(', r'debugPrint\s*\('],
    excludeFolders: ['test'],
    severity: RuleSeverity.warning,
  );
  classSizeLimit(maxMethods: 20, maxFields: 15);

  // Annotations
  annotationMustHave(annotation: 'injectable', folders: ['lib/data/repositories']);
}
```
