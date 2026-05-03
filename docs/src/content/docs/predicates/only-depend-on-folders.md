---
title: onlyDependsOnFolders
description: Enforce that a layer can only import from an explicit whitelist of folders. Stricter than doesNotDependOn — checks every single import, not just one.
sidebar:
  order: 3
---

## What it does

`onlyDependsOnFolders(folders)` passes when **every import** in the file comes from one of the listed folders — or from the Dart/Flutter SDK. If even a single import falls outside the whitelist, the rule fails.

This is the strictest import boundary matcher. While `doesNotDependOn` blocks a specific folder, `onlyDependsOnFolders` defines the complete set of folders a layer is **allowed** to import from. Anything not on the list is rejected.

---

## What problem it solves

`doesNotDependOn` works well when you know which folders to block. But there's a subtler problem: a layer might avoid all the explicitly banned folders while still importing from some unexpected place you didn't think to ban.

`onlyDependsOnFolders` flips the logic: instead of blocking specific folders, you declare a whitelist of everything that's allowed, and everything else is automatically blocked. This is the **closed-world assumption** for imports — if it's not on the list, it's forbidden.

This approach is safer in growing codebases because new folders are banned by default. You only add a folder to the whitelist when you consciously decide it's an acceptable dependency for that layer.

---

## Syntax

```dart
expect(subject, onlyDependsOnFolders(['lib/folder1', 'lib/folder2']));
```

---

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `folders` | `List<String>` | yes | The complete whitelist of allowed folder substrings. Any import not matching at least one entry causes the rule to fail. |

**Dart/Flutter SDK imports are always allowed** regardless of the whitelist. You do not need to add `dart:core`, `dart:async`, or `flutter/foundation.dart` to the list — they are implicitly permitted.

Each entry in the list is matched as a **substring** of the import path, so `'lib/domain'` matches any import containing that string.

---

## When to use

Use `onlyDependsOnFolders` for your strictest layer boundaries — the ones where you want a complete guarantee that nothing unexpected has crept in. It's especially valuable for:

- The **domain layer**: should only import from itself. Any external import is suspicious.
- **Shared utilities**: should only import from other utilities, never from application layers.
- **Core configuration**: should never depend on feature code.

For looser restrictions (just banning a specific layer), `doesNotDependOn` is simpler and sufficient.

---

## Common use cases

- Domain layer can only import from itself (pure Dart business logic, no infrastructure)
- Utility/shared code can only import from other utilities (no domain, no data, no UI)
- Data layer can only import from domain (to implement contracts) and its own folder
- Presentation can import from bloc and domain but not from data directly

---

## Examples

### Strict domain isolation

The domain layer should be completely self-contained — pure business logic with no external dependencies beyond Dart's standard library:

```dart title="test_arch/domain_isolation_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Domain layer can only import from itself', (selector) {
    expect(
      selector.classes(inFolder: 'lib/domain'),
      onlyDependsOnFolders(['lib/domain']),
    );
  });
}
```

If a domain class imports from `lib/data` or `lib/presentation`, DartUnit reports:

```
ERROR | Domain layer can only import from itself
      | lib/domain/usecases/get_cart_usecase.dart:4
      | imports lib/data/repositories/cart_repository_impl.dart (not in whitelist)
```

---

### Domain with a shared core

Many projects have a `lib/core` or `lib/shared` folder with utilities (extensions, constants, errors) used across all layers. Allow the domain to import from it explicitly:

```dart title="test_arch/domain_shared_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Domain may only import from itself and shared core', (selector) {
    expect(
      selector.classes(inFolder: 'lib/domain'),
      onlyDependsOnFolders([
        'lib/domain',   // its own files
        'lib/shared',   // shared utilities
        'lib/core',     // core constants, errors
      ]),
    );
  });
}
```

---

### Layered architecture with explicit boundaries

Define the allowed imports for each layer explicitly. This makes the dependency graph of your architecture visible directly in the test file:

```dart title="test_arch/layer_whitelist_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArchGroup('Strict layer boundaries', () {
    testArch('Domain only knows itself', (selector) {
      expect(
        selector.classes(inFolder: 'lib/domain'),
        onlyDependsOnFolders(['lib/domain', 'lib/core']),
      );
    });

    testArch('Data only knows domain and itself', (selector) {
      expect(
        selector.classes(inFolder: 'lib/data'),
        onlyDependsOnFolders(['lib/data', 'lib/domain', 'lib/core']),
      );
    });

    testArch('BLoC only knows domain and itself', (selector) {
      expect(
        selector.classes(inFolder: 'lib/bloc'),
        onlyDependsOnFolders(['lib/bloc', 'lib/domain', 'lib/core']),
      );
    });
  }, severity: RuleSeverity.error);
}
```

---

## Related matchers

- [`doesNotDependOn`](/predicates/depend-on-folder/) — simpler: ban one specific folder
- [`doesNotDependOnPackage`](/predicates/depend-on-package/) — ban a specific external package
- [`hasNoCircularDependency`](/predicates/has-circular-dependency/) — detect circular import chains
