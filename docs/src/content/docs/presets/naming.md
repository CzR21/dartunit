---
title: Naming Presets
description: Presets for enforcing naming conventions on classes in specific folders.
sidebar:
  order: 2
---

Naming conventions are one of the most common architecture rules. The naming presets let you enforce them without writing individual predicates for each folder.

---

## namingClassConvention

Enforces that classes in a folder end with a suffix derived from the folder's base name. For example, classes in `lib/bloc` must end with `Bloc`, and classes in `lib/repository` must end with `Repository`.

### Function signature

```dart
void namingClassConvention({
  required List<String> folders,
  String? namePattern,
  String? prefix,
  String? suffix,
  RuleSeverity severity = RuleSeverity.error,
  List<String> exceptions = const [],
  String projectRoot = '.',
})
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `folders` | `List<String>` | required | List of folder paths. The suffix is the last path segment, capitalized. |
| `namePattern` | `String?` | — | Raw regex applied to the class name. Overrides `prefix`/`suffix` when provided. |
| `prefix` | `String?` | — | Required class name prefix. |
| `suffix` | `String?` | — | Explicit suffix, overriding the auto-derived one. |
| `severity` | `RuleSeverity` | `RuleSeverity.error` | Violation severity |
| `exceptions` | `List<String>` | `[]` | Exact class names to exempt from the rule |

### How the suffix is derived

The preset takes the last segment of the folder path and capitalizes it:

| Folder | Required suffix |
|--------|----------------|
| `lib/bloc` | `Bloc` |
| `lib/service` | `Service` |
| `lib/repository` | `Repository` |
| `lib/datasource` | `Datasource` |
| `lib/usecase` | `Usecase` |
| `lib/controller` | `Controller` |

### Example — Flutter BLoC project

```dart title="test_arch/naming_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() => namingClassConvention(
  folders: [
    'lib/bloc',
    'lib/cubit',
    'lib/repository',
    'lib/datasource',
    'lib/usecase',
  ],
  severity: RuleSeverity.warning,
  exceptions: ['BaseBloc', 'BaseCubit'],
);
```

### Example — MVC project

```dart title="test_arch/naming_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() => namingClassConvention(
  folders: [
    'lib/controllers',
    'lib/models',
  ],
  severity: RuleSeverity.warning,
);
```

### Example — Strict enforcement (error severity)

```dart title="test_arch/naming_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() => namingClassConvention(
  folders: [
    'lib/bloc',
    'lib/domain/repositories',
    'lib/data/datasources',
  ],
  severity: RuleSeverity.error,
  exceptions: [
    'AbstractBloc',
    'BaseRepository',
  ],
);
```

### Violation output

```
  ✗  Classes in "lib/bloc" must end with "Bloc"
       ✗ lib/bloc/auth_manager.dart [error] — "AuthManager" does not match .*Bloc$
```

:::tip[Use exceptions for base classes]
Classes like `BaseBloc`, `AbstractService`, and code-generated files often legitimately deviate from the suffix convention. Use `exceptions` rather than relaxing the rule:
:::

