---
title: hasMaxImports
description: Enforce that a file has at most N import directives. A high import count is a strong signal of poor separation of concerns or a God Class.
sidebar:
  order: 23
---

## What it does

`hasMaxImports(max)` passes when the total number of `import` directives in the file is less than or equal to `max`. All types of imports are counted: `package:` imports, `dart:` imports, and relative `'../..'` imports.

---

## What problem it solves

The number of imports in a file is a proxy measurement for how many things a class depends on. A class with 20 imports is touching 20 different parts of the codebase — which is a strong signal that the class is doing too many things.

This metric is particularly useful for detecting **God Classes** that don't show up as having too many methods or fields, because they may delegate to many collaborators rather than doing everything themselves.

High import counts also make builds slower (more files to analyze) and create more opportunities for circular dependencies.

`hasMaxImports()` complements import boundary rules (`doesNotDependOn`, `onlyDependsOnFolders`) by limiting not just *what* a class imports, but *how much* it imports.

---

## Syntax

```dart
expect(subject, hasMaxImports(10));
```

---

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `max` | `int` | yes | Maximum allowed number of import directives (inclusive). All import types are counted. |

---

## When to use

Apply different limits based on the expected role of each class:

| Class type | Suggested limit |
|-----------|----------------|
| Domain entities | 2–3 (should be self-contained) |
| Domain use cases | 3–5 (depend on a few interfaces) |
| Repository implementations | 5–8 |
| BLoC classes | 5–10 |
| General classes | 10–15 as a broad ceiling |
| Data models | Up to 5 (json_annotation + a few types) |

---

## Common use cases

- Domain entities should have at most 3 imports (low coupling signal)
- Use case files must stay focused (at most 5 imports)
- General classes with more than 15 imports are likely God Classes
- Data source implementations must stay below 10 imports

---

## Examples

### Low-coupling requirement for domain entities

Domain entities should be self-contained and minimally coupled. A high import count in an entity is a red flag:

```dart title="test_arch/entity_coupling_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Domain entities must have at most 3 imports (low coupling)', (selector) {
    expect(
      selector.classes(inFolder: 'lib/domain/entities'),
      hasMaxImports(3),
    );
  });
}
```

---

### God Class detection

A broad ceiling to catch the most obviously over-coupled classes:

```dart title="test_arch/god_class_detection_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Classes with more than 15 imports are likely God Classes', (selector) {
    expect(
      selector.classes(inFolder: 'lib'),
      hasMaxImports(15),
    );
  });
}
```

---

### Use case focus enforcement

Use cases should be focused on a single business operation. If a use case is importing from 8+ places, it's probably doing too much:

```dart title="test_arch/usecase_imports_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Use case files must stay focused — at most 5 imports', (selector) {
    expect(
      selector.classes(inFolder: 'lib/domain/usecases'),
      hasMaxImports(5),
    );
  });
}
```

---

## Notes

- All `import` directives are counted: `dart:`, `package:`, and relative `'../..'` imports.
- A high import count is a signal, not a certainty — some legitimate classes (orchestrators, factories) need many collaborators. Use this rule with appropriate limits for each class type.
- Combine with `onlyDependsOnFolders` to enforce both the count and the origin of imports.

---

## Related matchers

- [`onlyDependsOnFolders`](/predicates/only-depend-on-folders/) — whitelist allowed import origins
- [`doesNotDependOn`](/predicates/depend-on-folder/) — ban imports from a specific folder
- [`hasMaxMethods`](/predicates/max-methods/) — enforce a maximum number of methods
- [`hasMaxFields`](/predicates/max-fields/) — enforce a maximum number of fields
