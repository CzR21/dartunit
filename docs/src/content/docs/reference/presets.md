---
title: Presets — Complete Reference
description: Overview of all 14 built-in presets with links to detailed documentation.
sidebar:
  order: 3
---

Presets are factory functions that generate one or more `ArchitectureRule` objects from a minimal configuration. Import `package:dartunit/dartunit.dart` and call them in a rule file.

## All 14 Presets

| Preset | Category | What it generates |
|--------|----------|-------------------|
| `layeredArchitecturePreset` | Layer | Rules for every forbidden layer pair in a multi-layer architecture |
| `layerCanOnlyDependOnPreset` | Layer | A folder may only import from an allowed set of folders |
| `layerCannotDependOnPreset` | Layer | A folder must not import from a specific folder or package |
| `namingFolderSuffixPreset` | Naming | Classes must end with the base name of their folder |
| `namingNamePatternPreset` | Naming | Classes must match a regex pattern |
| `mustBeAbstractPreset` | Structure | Classes must be declared `abstract` |
| `mustBeImmutablePreset` | Structure | All instance fields must be `final` or `const` |
| `noCircularDependenciesPreset` | Structure | No circular import chains |
| `classSizeLimitPreset` | Metrics | Classes must not exceed a method/field count limit |
| `noPublicFieldsPreset` | Quality | Classes must have no public fields |
| `noBannedCallsPreset` | Quality | Files must not contain specified regex patterns |
| `noExternalPackagePreset` | Dependency | Folders must not import from specified packages |
| `annotationMustHavePreset` | Annotation | Classes must have a specific annotation |
| `annotationMustNotHavePreset` | Annotation | Classes must not have a specific annotation |

## Detailed documentation by category

- [Layer Presets](/presets/layer) — `layeredArchitecturePreset`, `layerCanOnlyDependOnPreset`, `layerCannotDependOnPreset`
- [Naming Presets](/presets/naming) — `namingFolderSuffixPreset`, `namingNamePatternPreset`
- [Structure Presets](/presets/structure) — `mustBeAbstractPreset`, `mustBeImmutablePreset`, `noCircularDependenciesPreset`
- [Metrics Presets](/presets/metrics) — `classSizeLimitPreset`
- [Quality Presets](/presets/quality) — `noPublicFieldsPreset`, `noBannedCallsPreset`
- [Dependency Presets](/presets/dependency) — `noExternalPackagePreset`
- [Annotation Presets](/presets/annotation) — `annotationMustHavePreset`, `annotationMustNotHavePreset`
