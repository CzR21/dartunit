---
title: dependsOn / doesNotDependOn
description: Check whether classes import from a specific folder. The most common matchers for enforcing layer boundaries in your architecture.
sidebar:
  order: 1
---

## What it does

`dependsOn(folder)` passes when the class **imports at least one file** from the given folder path. `doesNotDependOn(folder)` is its mirror — it passes when the class **has no import** from that folder.

These are the two most commonly used matchers in DartUnit. Most architecture rules boil down to "layer A must not talk to layer B", which is exactly what `doesNotDependOn` enforces.

---

## What problem it solves

In Dart/Flutter projects, there are no compile-time barriers between folders. Any file can import any other file — the language does not stop you from writing:

```dart
// lib/domain/entities/user.dart
import 'package:myapp/data/datasources/user_api.dart'; // ← nobody stops this
```

This is a problem because it breaks the Dependency Rule: the domain layer should define contracts, not know about HTTP clients. Over time, without enforcement, every layer ends up importing from every other layer — making the code impossible to test in isolation and impossible to refactor without breaking everything.

`doesNotDependOn` closes this door automatically. Every time a developer accidentally imports across a forbidden boundary, DartUnit flags it before it reaches the codebase.

---

## Syntax

```dart
// Class must import from the given folder
expect(subject, dependsOn('lib/some/folder'));

// Class must NOT import from the given folder
expect(subject, doesNotDependOn('lib/some/folder'));
```

---

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `folder` | `String` | yes | A substring matched against each import path in the file. Any import whose path contains this string is considered a match. |

The match is a **substring check**, not an exact path. `doesNotDependOn('lib/data')` will catch imports like `../../lib/data/repositories/user_repo.dart` because the path contains `lib/data`.

---

## When to use

Use `doesNotDependOn` to enforce **layer isolation** — the core idea that each layer should only know about the layers directly below it.

Use `dependsOn` when you need to verify that a layer actually **uses** a dependency it should be using — for example, ensuring BLoC classes actually import from the repository layer (and not bypassing it by talking directly to data sources).

---

## Common use cases

**Enforcing layer isolation (most common):**
- Domain must not import from data
- Domain must not import from presentation
- Data must not import from presentation
- Presentation must not import from domain entities directly (only through BLoC/ViewModel)

**Enforcing required dependencies:**
- BLoC classes must import from the repository layer (not bypass it)
- Repository implementations must import from the domain layer (to implement its contracts)
- Data sources must import from the domain model layer

---

## Examples

### Basic rule — domain must not import from data

The most fundamental architecture rule: the domain layer defines contracts; the data layer implements them. The domain should never need to import from data.

```dart title="test_arch/domain_isolation_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Domain must not import from data layer', (arch) {
    expect(
      arch.classes(folder: 'lib/domain'),
      doesNotDependOn('lib/data'),
    );
  });
}
```

If a domain class ever imports something from `lib/data`, DartUnit will report:

```
ERROR | Domain must not import from data layer
      | lib/domain/repositories/cart_repository.dart:3
      | imports lib/data/datasources/cart_api.dart
```

---

### Checking both directions at once

A complete boundary test checks that neither layer imports from the other:

```dart title="test_arch/layer_boundaries_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArchGroup('Layer boundaries', () {
    testArch('Domain must not import from data', (arch) {
      expect(arch.classes(folder: 'lib/domain'), doesNotDependOn('lib/data'));
    });

    testArch('Domain must not import from presentation', (arch) {
      expect(arch.classes(folder: 'lib/domain'), doesNotDependOn('lib/presentation'));
    });

    testArch('Data must not import from presentation', (arch) {
      expect(arch.classes(folder: 'lib/data'), doesNotDependOn('lib/presentation'));
    });
  }, severity: RuleSeverity.critical);
}
```

---

### Ensuring required dependencies (dependsOn)

This rule enforces that BLoC classes actually depend on the repository layer — preventing developers from bypassing repositories and calling data sources directly:

```dart title="test_arch/bloc_dependencies_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('BLoC classes must use the repository layer', (arch) {
    expect(
      arch.classes(folder: 'lib/bloc', namePattern: r'.*Bloc$'),
      dependsOn('lib/domain/repositories'),
    );
  });
}
```

---

## Related matchers

- [`dependsOnPackage` / `doesNotDependOnPackage`](/predicates/depend-on-package/) — check external package dependencies
- [`onlyDependsOnFolders`](/predicates/only-depend-on-folders/) — whitelist all allowed imports (stricter)
- [`hasNoCircularDependency`](/predicates/has-circular-dependency/) — detect circular import chains
- [`hasMaxImports`](/predicates/max-imports/) — limit total number of imports
