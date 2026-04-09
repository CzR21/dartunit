---
title: dependsOnPackage / doesNotDependOnPackage
description: Check whether classes import from a specific external package. Commonly used to keep the domain layer free from Flutter or HTTP packages.
sidebar:
  order: 2
---

## What it does

`dependsOnPackage(package)` passes when the class **imports at least one file** from the given external package. `doesNotDependOnPackage(package)` passes when the class has **no import** from that package.

These matchers only inspect `package:` imports — they do not look at relative path imports between your own files.

---

## What problem it solves

External package dependencies are one of the most common sources of unintended coupling. Consider this scenario:

- Your domain layer should be pure Dart — testable without Flutter, without HTTP, without any infrastructure concern.
- A developer under time pressure imports `package:dio/dio.dart` directly into a domain use case to make a quick API call.
- Now your domain layer is coupled to Dio. Testing a use case requires setting up HTTP mocks. Switching from Dio to another HTTP client requires touching the domain layer.

`doesNotDependOnPackage` prevents this from happening. The rule runs on every CI build and rejects any commit that introduces a forbidden package dependency into a protected layer.

---

## Syntax

```dart
// Class must import from the given package
expect(subject, dependsOnPackage('flutter_bloc'));

// Class must NOT import from the given package
expect(subject, doesNotDependOnPackage('flutter'));
```

---

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `package` | `String` | yes | Matched as a substring of the import path (without the `package:` prefix). `'flutter'` matches both `flutter` and `flutter_bloc`. Use a more specific string for exact matches. |

The match is a **substring check** on the import path. `doesNotDependOnPackage('flutter')` will reject `import 'package:flutter/material.dart'` and also `import 'package:flutter_bloc/flutter_bloc.dart'` because both contain `flutter`.

If you need to allow `flutter_bloc` but ban `flutter` directly, use the more specific string `'package:flutter/'` as the pattern — or combine with `doesNotDependOnPackage('flutter/')` (note the trailing slash).

---

## When to use

Use `doesNotDependOnPackage` to protect layers that should remain framework-agnostic:

- The **domain layer** should never import Flutter, Dio, Hive, or any infrastructure package.
- The **domain layer** should remain pure Dart so that use cases and entities can be tested without Flutter's test infrastructure.

Use `dependsOnPackage` to ensure a layer actually uses the package it's supposed to use:

- Presentation widgets should use `flutter_bloc` for state management.
- Data sources should use `dio` or `http` for network calls (not hardcode HTTP logic elsewhere).

---

## Common use cases

**Protecting the domain layer (most important):**
- Domain must not import `flutter` (UI framework)
- Domain must not import `dio` or `http` (HTTP clients)
- Domain must not import `hive` or `shared_preferences` (persistence)
- Domain must not import `get_it` (dependency injection)

**Enforcing required package usage:**
- Presentation must use `flutter_bloc` for state management
- Data models must use `json_annotation` for serialization

---

## Examples

### Protect domain from Flutter

The domain layer should contain pure business logic. It must not depend on Flutter — otherwise you can't test it with plain Dart unit tests.

```dart title="test_arch/domain_no_flutter_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArchGroup('Domain layer must stay Flutter-agnostic', () {
    testArch('Domain must not import Flutter', (arch) {
      expect(arch.classes(folder: 'lib/domain'), doesNotDependOnPackage('flutter'));
    });

    testArch('Domain must not use Dio', (arch) {
      expect(arch.classes(folder: 'lib/domain'), doesNotDependOnPackage('dio'));
    });

    testArch('Domain must not use Hive', (arch) {
      expect(arch.classes(folder: 'lib/domain'), doesNotDependOnPackage('hive'));
    });
  }, severity: RuleSeverity.critical);
}
```

---

### Verify required package usage

Ensure that your presentation layer actually uses the state management package your team decided on — and hasn't accidentally introduced a competing approach:

```dart title="test_arch/presentation_flutter_bloc_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Presentation pages must use flutter_bloc', (arch) {
    expect(
      arch.classes(folder: 'lib/presentation/pages'),
      dependsOnPackage('flutter_bloc'),
    );
  });
}
```

---

### Comprehensive architecture protection

A full protection suite covering all critical layer-package relationships:

```dart title="test_arch/package_rules_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArchGroup('Package dependency rules', () {
    testArch('Domain must not use any infrastructure packages', (arch) {
      final domain = arch.classes(folder: 'lib/domain');
      expect(domain, doesNotDependOnPackage('flutter'));
      expect(domain, doesNotDependOnPackage('dio'));
      expect(domain, doesNotDependOnPackage('hive'));
      expect(domain, doesNotDependOnPackage('shared_preferences'));
      expect(domain, doesNotDependOnPackage('get_it'));
    });

    testArch('Data layer must not use Flutter UI packages', (arch) {
      expect(
        arch.classes(folder: 'lib/data'),
        doesNotDependOnPackage('flutter'),
      );
    });
  }, severity: RuleSeverity.error);
}
```

---

## Related matchers

- [`dependsOn` / `doesNotDependOn`](/predicates/depend-on-folder/) — check internal folder dependencies
- [`onlyDependsOnFolders`](/predicates/only-depend-on-folders/) — whitelist all allowed imports
- [`hasMaxImports`](/predicates/max-imports/) — limit total number of imports
