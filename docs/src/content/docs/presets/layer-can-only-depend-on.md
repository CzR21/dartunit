---
title: layerCanOnlyDependOn
description: Whitelist the only folders a layer is allowed to import from. The strictest form of dependency control — anything outside the list is a violation.
sidebar:
  order: 3
---

`layerCanOnlyDependOn` restricts a layer to a whitelist of approved import sources. Any import found in the target layer that does not match one of the `allowed` folder substrings is reported as a violation.

This is the strictest form of import control in DartUnit. Rather than listing what is forbidden, you list what is permitted — and everything else is implicitly forbidden. With a blacklist you can forget to add a new forbidden dependency; with a whitelist you cannot accidentally allow a new one without explicitly updating the list.

## Function signature

```dart
void layerCanOnlyDependOn({
  required String layer,
  required List<String> allowed,
  RuleSeverity severity = RuleSeverity.error,
  List<String> exceptions = const [],
  String projectRoot = '.',
})
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `layer` | `String` | required | Path substring identifying the layer to restrict. Any file whose path contains this string is subject to the rule. |
| `allowed` | `List<String>` | required | Path substrings this layer is permitted to import. Any import not matching at least one of these substrings is a violation. |
| `severity` | `RuleSeverity` | `RuleSeverity.error` | How violations are reported. |
| `exceptions` | `List<String>` | `const []` | File path substrings to exempt from this rule. |

## Basic usage

```dart title="test_arch/domain_whitelist_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() => layerCanOnlyDependOn(
  layer: 'lib/domain',
  allowed: ['lib/domain', 'lib/core'],
);
```

This means every file in `lib/domain` may only import other files from `lib/domain` or `lib/core`. Any other import — including external packages like `flutter` or `dio` — is a violation.

## The whitelist versus blacklist distinction

### Why whitelisting is more robust

A blacklist ([`layerCannotDependOn`](/presets/layer-cannot-depend-on)) works well for known bad dependencies. The problem is dependencies you haven't thought of yet. Six months from now, a developer adds `package:shared_preferences` to the domain layer. There is no rule forbidding it. The blacklist doesn't catch it.

A whitelist catches this automatically. You declare: "domain may only import from `lib/domain` and `lib/core`." Anything else — including packages that didn't exist when you wrote the rule — is immediately a violation.

:::tip[Use both together]
The blacklist catches known bad dependencies with clearer violation messages. The whitelist catches anything you missed. Together they provide belt-and-suspenders enforcement.
:::

### External packages and dart: imports

DartUnit matches the `allowed` substrings against the full import path. This means:

- `package:equatable/equatable.dart` contains `equatable`
- `package:flutter/material.dart` contains `flutter`
- `dart:async` contains `dart:`

To allow specific external packages, add their name to the `allowed` list:

```dart
void main() => layerCanOnlyDependOn(
  layer: 'lib/domain',
  allowed: [
    'lib/domain',
    'lib/core',
    'equatable',  // allows package:equatable/equatable.dart
    'meta',       // allows package:meta/meta.dart
    'dartz',      // allows package:dartz/dartz.dart
    'dart:',      // allows all dart: standard library imports
  ],
);
```

## Examples

### Example 1 — Strict domain isolation

The strictest possible setup: the domain layer may only import from itself and core utilities:

```dart title="test_arch/domain_strict_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() => layerCanOnlyDependOn(
  layer: 'lib/domain',
  allowed: [
    'lib/domain',   // other domain files
    'lib/core',     // shared abstractions
    'equatable',    // value equality
    'meta',         // @immutable, @protected
    'dart:',        // standard library
  ],
);
```

### Example 2 — BLoC layer whitelist

BLoC classes are allowed to import from domain (for use cases) and models (for data), but nothing else:

```dart title="test_arch/bloc_whitelist_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() => layerCanOnlyDependOn(
  layer: 'lib/bloc',
  allowed: [
    'lib/bloc',     // sibling BLoC files
    'lib/domain',   // use cases and domain entities
    'lib/models',   // data models
    'bloc',         // package:bloc
    'flutter_bloc', // package:flutter_bloc
    'equatable',
    'dart:',
  ],
);
```

### Example 3 — Combining whitelist with layeredArchitecture

For a complete enforcement strategy, use `layeredArchitecture` for inter-layer direction rules, then `layerCanOnlyDependOn` for the most critical layer:

```dart title="test_arch/full_architecture_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  // Declare the full dependency graph
  layeredArchitecture(
    layers: [
      (name: 'Presentation', folder: 'lib/presentation', canAccess: ['lib/bloc', 'lib/domain']),
      (name: 'BLoC', folder: 'lib/bloc', canAccess: ['lib/domain']),
      (name: 'Domain', folder: 'lib/domain', canAccess: []),
      (name: 'Data', folder: 'lib/data', canAccess: ['lib/domain']),
    ],
    severity: RuleSeverity.error,
  );

  // Belt-and-suspenders: also whitelist domain's allowed imports
  // This catches external packages not covered by layeredArchitecture
  layerCanOnlyDependOn(
    layer: 'lib/domain',
    allowed: [
      'lib/domain',
      'lib/core',
      'equatable',
      'meta',
      'dart:',
    ],
    severity: RuleSeverity.critical,
  );
}
```

### Example 4 — Shared utilities layer

A shared utilities layer may import from core but not from any feature:

```dart title="test_arch/shared_whitelist_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() => layerCanOnlyDependOn(
  layer: 'lib/shared',
  allowed: [
    'lib/shared',
    'lib/core',
    'dart:',
    'flutter',       // shared UI utilities may use Flutter
    'equatable',
    'meta',
  ],
);
```

## Using exceptions

```dart title="test_arch/domain_whitelist_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() => layerCanOnlyDependOn(
  layer: 'lib/domain',
  allowed: ['lib/domain', 'lib/core', 'equatable', 'dart:'],
  exceptions: [
    // Generated file imports from lib/data during migration — issue #410
    'lib/domain/mappers/legacy_user_mapper.dart',
  ],
);
```

## Violation output

```
  ✗  "lib/domain" can only depend on: lib/domain, lib/core
       ✗ lib/domain/entities/product.dart [error] — imports from 'package:dio/dio.dart'
       ✗ lib/domain/usecases/login_usecase.dart [error] — imports from 'package:flutter/material.dart'

2 violation(s) found
```

## Related presets

| Preset | What it does |
|--------|-------------|
| [`layerCannotDependOn`](/presets/layer-cannot-depend-on) | Blacklist: forbid specific dependency directions |
| [`layeredArchitecture`](/presets/layered-architecture) | Full layer declaration with auto-generated forbidden pairs |
