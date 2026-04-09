---
title: Dependency Presets
description: The noExternalPackage for controlling which external packages can be used in specific folders.
sidebar:
  order: 6
---

## noExternalPackage

Prohibits the use of specific external packages in certain project folders. Generates one `ArchitectureRule` per package per folder combination.

### Function signature

```dart
List<ArchitectureRule> noExternalPackage({
  required List<String> folders,
  required List<String> packages,
  RuleSeverity severity = RuleSeverity.error,
  List<String> exceptions = const [],
})
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `folders` | `List<String>` | required | Folders where the packages are forbidden |
| `packages` | `List<String>` | required | Package names to ban, **without** the `package:` prefix |
| `severity` | `RuleSeverity` | `RuleSeverity.error` | Violation severity |
| `exceptions` | `List<String>` | `[]` | Exact class names to exempt |

### Example — Pure domain — no external dependencies

```dart title="test_arch/domain_purity_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) {
  final rules = noExternalPackage(
    folders: ['lib/domain'],
    packages: [
      'flutter',           // no Flutter in domain
      'dio',               // no HTTP client in domain
      'get_it',            // no DI framework in domain
      'injectable',        // no DI annotations in domain
      'shared_preferences', // no persistence in domain
      'hive',              // no database in domain
      'sqflite',           // no database in domain
    ],
    severity: RuleSeverity.error,
  );

  for (final rule in rules) {
    archTest(args, rule);
  }
}
```

### Example — Presentation layer without HTTP access

```dart title="test_arch/presentation_deps_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) {
  final rules = noExternalPackage(
    folders: ['lib/presentation', 'lib/bloc'],
    packages: ['dio', 'http', 'retrofit', 'chopper'],
    severity: RuleSeverity.warning,
  );

  for (final rule in rules) {
    archTest(args, rule);
  }
}
```

### Example — Ban packages being phased out

```dart title="test_arch/legacy_packages_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) {
  final rules = noExternalPackage(
    folders: ['lib'],
    packages: [
      'provider',   // migrating to BLoC
      'mobx',       // deprecated in this project
    ],
    severity: RuleSeverity.error,
    exceptions: ['LegacyWidget'],
  );

  for (final rule in rules) {
    archTest(args, rule);
  }
}
```

### Violation output

```
ERROR | Domain must not depend on package: flutter
      | lib/domain/repositories/user_repository.dart:2
      | Class "UserRepository" imports from package: flutter

ERROR | Domain must not depend on package: dio
      | lib/domain/usecases/fetch_user_usecase.dart:3
      | Class "FetchUserUseCase" imports from package: dio
```

### How package names work

Specify the package name **without** the `package:` prefix:

```dart
packages: [
  'dio',           // matches: import 'package:dio/dio.dart';
  'flutter',       // matches: import 'package:flutter/material.dart';
  'get_it',        // matches: import 'package:get_it/get_it.dart';
]
```

### Combining with layer presets

For complete domain isolation, combine `noExternalPackage` with `layerCannotDependOn`:

```dart title="test_arch/domain_isolation_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) {
  // Ban specific packages from domain
  final packageRules = noExternalPackage(
    folders: ['lib/domain'],
    packages: ['flutter', 'dio', 'hive', 'get_it'],
    severity: RuleSeverity.error,
  );
  for (final rule in packageRules) {
    archTest(args, rule);
  }

  // Also ban data layer imports in domain
  archTest(
    args,
    layerCannotDependOn(
      from: 'lib/domain',
      to: 'lib/data',
      severity: RuleSeverity.error,
    ),
  );
}
```
