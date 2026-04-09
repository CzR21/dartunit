---
title: Selectors (Selector)
description: How selectors define which project elements a rule evaluates — ClassSelector, FileSelector, and LayerSelector.
sidebar:
  order: 3
---

The **Selector** defines which elements of the project are submitted to a rule's predicate. Think of it as the scope filter for a rule.

DartUnit provides three selector types:

| Type | Class | Selects |
|------|-------|---------|
| Class selector | `ClassSelector` | Dart classes filtered by folder, name, annotation, or inheritance |
| File selector | `FileSelector` | `.dart` files filtered by folder or filename pattern |
| Layer selector | `LayerSelector` | All classes in a specific architectural layer (folder) |

## ClassSelector

`ClassSelector` is the most powerful selector. It finds classes that match all of the specified criteria (all filters are combined with AND).

### Constructor

```dart
ClassSelector({
  String? folder,
  String? namePattern,
  String? annotatedWith,
  String? extendsType,
  String? implementsType,
  List<String> excludeNames = const [],
})
```

### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `folder` | `String?` | Substring match on the file path. `'lib/domain'` selects all files whose path contains `lib/domain`. |
| `namePattern` | `String?` | Dart regex applied to the class name. Case-sensitive. |
| `annotatedWith` | `String?` | Annotation name **without** the `@` prefix. Matches classes annotated with `@injectable` when given `'injectable'`. |
| `extendsType` | `String?` | Parent class name. Matches classes that `extends` the given type. |
| `implementsType` | `String?` | Interface name. Matches classes that `implements` the given type. |
| `excludeNames` | `List<String>` | Exact class names to exclude from the selection. |

### Examples

**Select all classes in a folder:**

```dart
ClassSelector(folder: 'lib/domain')
```

**Select classes matching a naming pattern:**

```dart
// All classes whose name ends with "RepositoryImpl"
ClassSelector(namePattern: r'.*RepositoryImpl$')
```

**Select repository implementations in the data layer:**

```dart
ClassSelector(
  folder: 'lib/data',
  namePattern: r'.*RepositoryImpl$',
  implementsType: 'Repository',
)
```

**Select annotated classes, excluding test doubles:**

```dart
ClassSelector(
  folder: 'lib/service',
  annotatedWith: 'injectable',
  excludeNames: ['MockUserService', 'FakeAuthService'],
)
```

**Select abstract repositories (exclude implementations):**

```dart
ClassSelector(
  folder: 'lib/domain/repositories',
  namePattern: r'^(?!.*Impl).*Repository$',
)
```

**Select BLoC classes:**

```dart
ClassSelector(namePattern: r'.*Bloc$')
```

:::tip
All specified parameters are combined with AND. `ClassSelector(folder: 'lib/data', namePattern: r'.*Impl$')` selects only classes that are both in `lib/data` AND whose name ends with `Impl`.
:::

## FileSelector

`FileSelector` selects `.dart` files rather than classes. Use it with predicates that operate on file content, such as `FileContentMatchesPredicate`.

### Constructor

```dart
FileSelector({
  String? folder,
  String? namePattern,
  List<String> excludeFolders = const [],
})
```

### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `folder` | `String?` | Substring match on the file path. |
| `namePattern` | `String?` | Dart regex applied to the filename (including extension). |
| `excludeFolders` | `List<String>` | Folder path substrings to exclude. |

### Examples

**All files in lib/:**

```dart
FileSelector(folder: 'lib')
```

**Only datasource files:**

```dart
FileSelector(
  folder: 'lib/data',
  namePattern: r'.*_datasource\.dart$',
)
```

**All files, excluding generated code:**

```dart
FileSelector(
  folder: 'lib',
  excludeFolders: ['lib/generated', 'lib/.dart_tool'],
)
```

**All files excluding tests:**

```dart
FileSelector(
  folder: 'lib',
  namePattern: r'^(?!.*_test\.dart).*\.dart$',
)
```

### Using FileSelector with predicates

`FileSelector` is typically paired with `hasNoContent()` / `hasContent()` arch matchers in a `testArch` call:

```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('No print() calls in production code', (arch) {
    expect(
      arch.files(folder: 'lib'),
      hasNoContent(r'print\s*\('),
    );
  }, severity: RuleSeverity.warning);
}
```

## LayerSelector

`LayerSelector` selects all classes in a specific folder, treating it as an architectural layer. It is functionally equivalent to `ClassSelector(folder: folder)`, but produces more descriptive violation messages that reference the layer name.

### Constructor

```dart
LayerSelector(String folder)
```

### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `folder` | `String` | The folder path that defines this layer (e.g., `'lib/domain'`). |

### Examples

```dart
LayerSelector('lib/domain')
LayerSelector('lib/data')
LayerSelector('lib/presentation')
```

**Using LayerSelector via testArch:**

```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Domain layer must not depend on data layer', (arch) {
    expect(
      arch.layer('domain', folder: 'lib/domain'),
      doesNotDependOn('lib/data'),
    );
  }, severity: RuleSeverity.error);
}
```

## The folder Filter — Substring Matching

The `folder` parameter on all selectors uses **substring matching** on the full file path. This means `'lib/domain'` matches any file whose path contains that string:

```
folder: 'lib/domain'

Matches:
  lib/domain/entities/user.dart
  lib/domain/repositories/user_repository.dart
  lib/domain/usecases/get_user_usecase.dart

Does not match:
  lib/data/repositories/user_repository_impl.dart
  lib/presentation/pages/home_page.dart
```

## namePattern — Dart Regex

The `namePattern` field accepts Dart regex syntax. Patterns are case-sensitive by default and matched against the full class name.

Common patterns:

```dart
// Ends with "Service"
namePattern: r'.*Service$'

// Starts with "Abstract" or "Base"
namePattern: r'^(Abstract|Base).*'

// Ends with "Bloc" or "Cubit"
namePattern: r'.*(Bloc|Cubit)$'

// Does not end with "Impl" (negative lookahead)
namePattern: r'^(?!.*Impl$).*'

// Exactly "UserRepository"
namePattern: r'^UserRepository$'
```

## Complete Reference

For the full selector API, see [Selectors — Reference](/reference/selectors).
