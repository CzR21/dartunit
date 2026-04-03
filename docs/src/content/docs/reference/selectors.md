---
title: Selectors — Complete Reference
description: Full reference for ClassSelector, FileSelector, and LayerSelector.
sidebar:
  order: 2
---

## ClassSelector

Selects Dart classes using combined filters. All specified filters are combined with AND — a class must satisfy every filter to be selected.

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
| `folder` | `String?` | Substring matched against the full file path. `'lib/domain'` selects all files under `lib/domain/`. |
| `namePattern` | `String?` | Dart regex matched against the class name. Case-sensitive. |
| `annotatedWith` | `String?` | Annotation name without `@`. Selects classes that have `@<annotation>`. |
| `extendsType` | `String?` | Parent class name. Selects classes that extend this type. |
| `implementsType` | `String?` | Interface name. Selects classes that implement this type. |
| `excludeNames` | `List<String>` | Exact class names to exclude from the selection. |

### Examples

```dart
// All classes in lib/domain
ClassSelector(folder: 'lib/domain')

// All classes whose name ends with "RepositoryImpl"
ClassSelector(namePattern: r'.*RepositoryImpl$')

// Repository implementations in the data layer that implement Repository
ClassSelector(
  folder: 'lib/data/repositories',
  namePattern: r'.*RepositoryImpl$',
  implementsType: 'Repository',
)

// Injectable services, excluding test doubles
ClassSelector(
  folder: 'lib/service',
  annotatedWith: 'injectable',
  excludeNames: ['MockAnalyticsService', 'FakeAuthService'],
)

// Abstract repositories (no Impl suffix)
ClassSelector(
  folder: 'lib/domain/repositories',
  namePattern: r'^(?!.*Impl).*Repository$',
)

// All concrete classes in the data layer
ClassSelector(folder: 'lib/data')
```

### Selecting all classes

Calling `ClassSelector()` with no arguments selects every class in the project:

```dart
ClassSelector() // selects all classes in lib/
```

---

## FileSelector

Selects `.dart` files. Use with predicates that operate on file content, such as `FileContentMatchesPredicate`.

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
| `folder` | `String?` | Substring matched against the full file path. |
| `namePattern` | `String?` | Dart regex matched against the filename (including extension). |
| `excludeFolders` | `List<String>` | Folder path substrings to exclude from the selection. |

### Examples

```dart
// All files in lib/
FileSelector(folder: 'lib')

// Only datasource files in lib/data
FileSelector(
  folder: 'lib/data',
  namePattern: r'.*_datasource\.dart$',
)

// All lib/ files, excluding generated code
FileSelector(
  folder: 'lib',
  excludeFolders: ['lib/generated'],
)
```

---

## LayerSelector

Selects all classes in a folder, treating it as an architectural layer. Functionally equivalent to `ClassSelector(folder: folder)`, but produces more descriptive violation messages.

### Constructor

```dart
LayerSelector(String folder)
```

### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `folder` | `String` | The folder path that defines this layer (e.g., `'lib/domain'`). Used for both selection and violation messages. |

### Examples

```dart
LayerSelector('lib/domain')
LayerSelector('lib/data')
LayerSelector('lib/presentation')
LayerSelector('lib/bloc')
```

```dart
// Rule using LayerSelector
ArchitectureRule(
  description: 'Domain layer must not depend on data layer',
  severity: RuleSeverity.error,
  selector: LayerSelector('lib/domain'),
  predicate: NotPredicate(DependOnFolderPredicate('lib/data')),
)
```

---

## The folder parameter — substring matching

The `folder` parameter on all selectors uses **substring matching** against the full file path. A file is included if its path contains the given string.

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

---

## namePattern — Dart regex

The `namePattern` field uses Dart regex syntax. Patterns are case-sensitive by default and matched against the complete class or file name.

Common patterns:

```dart
r'.*Service$'                // ends with "Service"
r'^(Abstract|Base).*'        // starts with "Abstract" or "Base"
r'.*(Bloc|Cubit)$'           // ends with "Bloc" or "Cubit"
r'^(?!.*Impl$).*'            // does not end with "Impl"
r'^[A-Z][a-zA-Z]+Entity$'   // follows "<PascalCase>Entity" format
r'.*_datasource\.dart$'      // filename ends with "_datasource.dart"
```
