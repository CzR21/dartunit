---
title: namingFileConvention
description: Enforce file naming conventions — files in a folder must match a naming pattern derived from the folder name, an explicit suffix, or a custom regex.
sidebar:
  order: 5
---

`namingFileConvention` enforces that every `.dart` file inside a given folder ends with a suffix derived from that folder's name. Files in `lib/services/` must end with `_service.dart`. Files in `lib/repositories/` must end with `_repository.dart`. Files in `lib/bloc/` must end with `_bloc.dart` or `_cubit.dart`.

This is the **file-level** counterpart to [`namingClassConvention`](/presets/naming-class-convention), which enforces naming at the **class** level. Use `namingFileConvention` when you want to enforce the file name convention independent of the class names inside the file.

## Function signature

```dart
void namingFileConvention({
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
| `folders` | `List<String>` | required | Folder paths to enforce. The file naming pattern is derived from each folder unless overridden. |
| `namePattern` | `String?` | — | Raw regex applied to the full filename. Overrides `prefix` and `suffix` when provided. |
| `prefix` | `String?` | — | Required filename prefix (e.g., `'remote_'`). Combined with `suffix` when both are provided. |
| `suffix` | `String?` | — | Required filename suffix without `.dart` extension (e.g., `'_service'`). The `.dart` extension is appended automatically. |
| `severity` | `RuleSeverity` | `RuleSeverity.error` | Severity of violations. |
| `exceptions` | `List<String>` | `const []` | File path substrings to exclude from the check. |

:::note[Mutual exclusivity]
`namePattern` and `prefix`/`suffix` are mutually exclusive. Use one or the other, not both.
:::

## How the suffix is derived

When neither `suffix`, `prefix`, nor `namePattern` is specified, the expected file suffix is derived from the folder's base name in `snake_case`, prefixed with `_`:

| Folder path | Derived suffix |
|-------------|----------------|
| `lib/services` | `_services.dart` |
| `lib/repositories` | `_repositories.dart` |
| `lib/bloc` | `_bloc.dart` |
| `lib/datasources` | `_datasources.dart` |
| `lib/features/cart/bloc` | `_bloc.dart` |

The full path does not affect the derived suffix — only the last segment matters.

## Examples

### Example 1 — Auto-derived suffix from folder name

```dart title="test_arch/file_naming_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() => namingFileConvention(
  folders: ['lib/services', 'lib/repositories'],
);
```

This enforces:
- `lib/services/` → files must end with `_services.dart` (e.g., `auth_services.dart`)
- `lib/repositories/` → files must end with `_repositories.dart`

### Example 2 — Explicit suffix

Use `suffix` when the auto-derived name doesn't match your convention (e.g., you use `_service.dart` singular):

```dart title="test_arch/file_naming_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() => namingFileConvention(
  folders: ['lib/services'],
  suffix: '_service',  // .dart is appended automatically
);
```

This enforces files like `auth_service.dart`, `user_service.dart`.

### Example 3 — Prefix and suffix together

Enforce both a prefix and suffix for remote data source files:

```dart title="test_arch/datasource_naming_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() => namingFileConvention(
  folders: ['lib/data/datasources'],
  prefix: 'remote_',
  suffix: '_datasource',
);
```

This enforces files like `remote_user_datasource.dart`, `remote_product_datasource.dart`.

### Example 4 — Custom regex pattern

Use `namePattern` for conventions that cannot be expressed with a simple prefix/suffix:

```dart title="test_arch/bloc_file_naming_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() => namingFileConvention(
  folders: ['lib/bloc'],
  namePattern: r'.*(bloc|cubit)\.dart$',
);
```

This allows both `auth_bloc.dart` and `auth_cubit.dart`.

### Example 5 — Clean Architecture file naming

Enforce file naming conventions across all Clean Architecture layers:

```dart title="test_arch/file_naming_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  // Domain layer: entity files end with _entity.dart
  namingFileConvention(
    folders: ['lib/domain/entities'],
    suffix: '_entity',
    severity: RuleSeverity.warning,
  );

  // Domain layer: repository interface files end with _repository.dart
  namingFileConvention(
    folders: ['lib/domain/repositories'],
    suffix: '_repository',
    severity: RuleSeverity.warning,
  );

  // Data layer: datasource files follow remote_*_datasource.dart
  namingFileConvention(
    folders: ['lib/data/datasources'],
    prefix: 'remote_',
    suffix: '_datasource',
    severity: RuleSeverity.error,
    exceptions: ['lib/data/datasources/local_cache_datasource.dart'],
  );

  // Data layer: model files end with _model.dart
  namingFileConvention(
    folders: ['lib/data/models'],
    suffix: '_model',
    severity: RuleSeverity.error,
  );
}
```

### Example 6 — BLoC architecture with multiple allowed patterns

```dart title="test_arch/bloc_naming_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  // State files: *_state.dart
  namingFileConvention(
    folders: ['lib/bloc'],
    namePattern: r'.*(bloc|cubit|state|event)\.dart$',
    severity: RuleSeverity.warning,
  );
}
```

## Combining with namingClassConvention

For the most comprehensive naming enforcement, combine both file-level and class-level checks:

```dart title="test_arch/naming_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  // Files in lib/services must end with _service.dart
  namingFileConvention(
    folders: ['lib/services'],
    suffix: '_service',
    severity: RuleSeverity.warning,
  );

  // Classes in lib/services must end with Service
  namingClassConvention(
    folders: ['lib/services'],
    suffix: 'Service',
    severity: RuleSeverity.warning,
  );
}
```

This enforces both `auth_service.dart` (file name) and `AuthService` (class name).

## Violations output

When a file does not match the required naming pattern:

```
  ✗  Files in "lib/services" must end with "_service.dart"
       ✗ lib/services/auth_helper.dart [error] — filename does not match pattern
```

## Related presets

| Preset | What it checks |
|--------|---------------|
| [`namingClassConvention`](/presets/naming-class-convention) | Class names inside a folder |
