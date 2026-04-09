---
title: hasNoCircularDependency / hasCircularDependency
description: Detect circular import chains in your codebase. Almost always used as hasNoCircularDependency to ban cycles.
sidebar:
  order: 4
---

## What it does

`hasNoCircularDependency()` passes when the class is **not part of any circular import chain**. `hasCircularDependency()` is the inverse — it passes when the class **is** part of a cycle.

In almost all real-world rules, you want `hasNoCircularDependency()`. The positive version (`hasCircularDependency()`) is rarely useful in practice.

DartUnit checks **direct and indirect cycles**. A cycle between A→B→C→A is detected even though no file directly imports itself. All files participating in the cycle are flagged.

---

## What problem it solves

Circular dependencies are one of the most damaging structural problems in a Dart codebase. When A imports B and B imports A — directly or through a chain — the entire group of files becomes a single tightly-coupled unit.

**The consequences:**
- You cannot test A without also loading B, C, and everything else in the cycle
- You cannot refactor A without touching every file in the cycle
- The Dart analyzer may produce confusing errors or incorrect analysis results
- Incremental compilation becomes slower because a change to any file in the cycle recompiles all of them

Circular dependencies usually emerge gradually. A quick import here, a convenience shortcut there. By the time you notice the cycle, it's deeply entangled. `hasNoCircularDependency()` catches cycles at the moment they are introduced, before they become expensive to untangle.

---

## Syntax

```dart
// Class must NOT be part of any circular import chain
expect(subject, hasNoCircularDependency());

// Class IS part of a circular import chain (rare)
expect(subject, hasCircularDependency());
```

---

## Parameters

These matchers take **no parameters**. Cycle detection is performed automatically across the full import graph.

---

## When to use

Apply `hasNoCircularDependency()` to every layer in your application. There is almost never a valid reason for circular imports in a well-structured codebase. A common starting point is to scan the entire `lib/` folder:

```dart
expect(arch.classes(folder: 'lib'), hasNoCircularDependency());
```

You can also scope it to specific layers if you want tighter control over the error message:

```dart
expect(arch.classes(folder: 'lib/domain'), hasNoCircularDependency());
expect(arch.classes(folder: 'lib/data'), hasNoCircularDependency());
```

---

## Common use cases

- Enforce zero circular dependencies anywhere in the entire project
- Detect cycles introduced during a refactoring
- Scope cycle detection to a specific layer (for clearer error messages)
- Run cycle detection as a critical rule that blocks merges

---

## Examples

### No cycles anywhere in the project

The simplest and most comprehensive rule — check the entire codebase at once:

```dart title="test_arch/no_cycles_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('No circular dependencies allowed anywhere', (arch) {
    expect(
      arch.classes(folder: 'lib'),
      hasNoCircularDependency(),
    );
  });
}
```

When a cycle is found, DartUnit lists all files participating in the cycle:

```
CRITICAL | No circular dependencies allowed anywhere
         | lib/domain/repositories/cart_repository.dart
         | lib/domain/usecases/get_cart_usecase.dart
         | lib/domain/entities/cart.dart
         | These files form a circular import chain.
```

---

### Per-layer cycle detection

Scoping to individual layers produces more specific error messages and makes it easier to identify where the cycle originated:

```dart title="test_arch/layer_cycles_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArchGroup('No circular dependencies per layer', () {
    testArch('Domain layer has no cycles', (arch) {
      expect(arch.classes(folder: 'lib/domain'), hasNoCircularDependency());
    });

    testArch('Data layer has no cycles', (arch) {
      expect(arch.classes(folder: 'lib/data'), hasNoCircularDependency());
    });

    testArch('BLoC layer has no cycles', (arch) {
      expect(arch.classes(folder: 'lib/bloc'), hasNoCircularDependency());
    });

    testArch('Presentation layer has no cycles', (arch) {
      expect(arch.classes(folder: 'lib/presentation'), hasNoCircularDependency());
    });
  }, severity: RuleSeverity.critical);
}
```

---

### Combined with layer isolation

Running cycle detection alongside import boundary rules gives you a complete structural guarantee:

```dart title="test_arch/domain_structure_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArchGroup('Domain structural integrity', () {
    testArch('Domain does not import from data', (arch) {
      expect(arch.classes(folder: 'lib/domain'), doesNotDependOn('lib/data'));
    });

    testArch('Domain does not import from presentation', (arch) {
      expect(arch.classes(folder: 'lib/domain'), doesNotDependOn('lib/presentation'));
    });

    testArch('Domain has no circular dependencies', (arch) {
      expect(arch.classes(folder: 'lib/domain'), hasNoCircularDependency());
    });
  }, severity: RuleSeverity.critical);
}
```

---

## Related matchers

- [`doesNotDependOn`](/predicates/depend-on-folder/) — enforce directional layer boundaries
- [`onlyDependsOnFolders`](/predicates/only-depend-on-folders/) — whitelist all allowed imports
- [`hasMaxImports`](/predicates/max-imports/) — limit the total number of imports per file
