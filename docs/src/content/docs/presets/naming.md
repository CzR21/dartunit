---
title: Naming Presets
description: Presets for enforcing naming conventions on classes in specific folders.
sidebar:
  order: 2
---

Naming conventions are one of the most common architecture rules. The naming presets let you enforce them without writing individual predicates for each folder.

---

## namingFolderSuffix

Enforces that classes in a folder end with a suffix derived from the folder's base name. For example, classes in `lib/bloc` must end with `Bloc`, and classes in `lib/repository` must end with `Repository`.

### Function signature

```dart
ArchitectureRule namingFolderSuffix({
  required List<String> folders,
  RuleSeverity severity = RuleSeverity.warning,
  List<String> exceptions = const [],
})
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `folders` | `List<String>` | required | List of folder paths. The suffix is the last path segment, capitalized. |
| `severity` | `RuleSeverity` | `RuleSeverity.warning` | Violation severity |
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

void main(List<String> args) => archTest(
  args,
  namingFolderSuffix(
    folders: [
      'lib/bloc',
      'lib/cubit',
      'lib/repository',
      'lib/datasource',
      'lib/usecase',
    ],
    severity: RuleSeverity.warning,
    exceptions: ['BaseBloc', 'BaseCubit'],
  ),
);
```

### Example — MVC project

```dart title="test_arch/naming_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(
  args,
  namingFolderSuffix(
    folders: [
      'lib/controllers',
      'lib/models',
    ],
    severity: RuleSeverity.warning,
  ),
);
```

### Example — Strict enforcement (error severity)

```dart title="test_arch/naming_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(
  args,
  namingFolderSuffix(
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
  ),
);
```

### Violation output

```
WARNING | Classes in lib/bloc must end with "Bloc"
        | lib/bloc/auth_manager.dart:1
        | Class "AuthManager" does not end with "Bloc"
```

:::tip[Use exceptions for base classes]
Classes like `BaseBloc`, `AbstractService`, and code-generated files often legitimately deviate from the suffix convention. Use `exceptions` rather than relaxing the rule:
:::

---

## namingNamePattern

Enforces that classes in a folder match a specific regex pattern. More flexible than `namingFolderSuffix` when the convention cannot be described by a simple suffix.

### Function signature

```dart
ArchitectureRule namingNamePattern({
  required String folder,
  required String pattern,
  RuleSeverity severity = RuleSeverity.warning,
  List<String> exceptions = const [],
})
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `folder` | `String` | required | The folder to check (substring match) |
| `pattern` | `String` | required | Dart regex that class names must match |
| `severity` | `RuleSeverity` | `RuleSeverity.warning` | Violation severity |
| `exceptions` | `List<String>` | `[]` | Exact class names to exempt |

### Example — Domain entities must follow Entity suffix

```dart title="test_arch/entity_naming_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(
  args,
  namingNamePattern(
    folder: 'lib/domain/entities',
    pattern: r'^[A-Z][a-zA-Z]+Entity$',
    severity: RuleSeverity.warning,
  ),
);
```

### Example — Repository interfaces must start with I

```dart title="test_arch/repository_naming_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(
  args,
  namingNamePattern(
    folder: 'lib/domain/repositories',
    pattern: r'^I[A-Z][a-zA-Z]+$',
    severity: RuleSeverity.warning,
    exceptions: ['RepositoryBase'],
  ),
);
```

### Example — Mappers must contain "Mapper"

```dart title="test_arch/mapper_naming_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(
  args,
  namingNamePattern(
    folder: 'lib/data/mappers',
    pattern: r'.*Mapper$',
    severity: RuleSeverity.warning,
  ),
);
```

### Common patterns

| Use case | Pattern |
|----------|---------|
| Ends with "Entity" | `r'^[A-Z][a-zA-Z]+Entity$'` |
| Ends with "Bloc" or "Cubit" | `r'.*(Bloc\|Cubit)$'` |
| Starts with "I" (interface convention) | `r'^I[A-Z].*$'` |
| Contains "Mapper" | `r'.*Mapper.*'` |
| Does not end with "Impl" | `r'^(?!.*Impl$).*'` |
| PascalCase with any suffix | `r'^[A-Z][a-zA-Z0-9]+$'` |

:::caution[Regex is case-sensitive]
`r'.*service$'` will not match `AuthService`. Always use the correct case: `r'.*Service$'`.
:::
