---
title: Subjects
description: How Subject represent the elements under evaluation and the breaches found.
sidebar:
  order: 6
---

## Subject — The Element Under Evaluation

A `Subject` is the concrete element being evaluated by a rule's predicate. It is a uniform wrapper that represents either a class or a file, depending on which selector was used.

Predicates receive a `Subject` and do not need to know whether they are operating on a class or a file — the `Subject` provides a consistent interface in both cases.

### When the selector is ClassSelector or LayerSelector

The `Subject` contains an `AnalyzedClass` with the following properties:

| Property | Type | Description |
|----------|------|-------------|
| `name` | `String` | Class name |
| `filePath` | `String` | Full path to the file containing the class |
| `imports` | `List<String>` | All import paths declared in the file |
| `annotations` | `List<String>` | Annotation names present on the class (without `@`) |
| `extendsType` | `String?` | The parent class name from `extends`, if any |
| `implementsTypes` | `List<String>` | All interface names from `implements` |
| `mixins` | `List<String>` | All mixin names used by the class |
| `methods` | `List<String>` | Method names declared in the class |
| `fields` | `List<AnalyzedField>` | Fields with name, type, visibility, and `isFinal` |
| `isAbstract` | `bool` | Whether the class is declared `abstract` |
| `isEnum` | `bool` | Whether the declaration is an `enum` |
| `isMixin` | `bool` | Whether the declaration is a `mixin` |
| `isExtension` | `bool` | Whether the declaration is an `extension` |

### When the selector is FileSelector

The `Subject` contains an `AnalyzedFile` with the following properties:

| Property | Type | Description |
|----------|------|-------------|
| `path` | `String` | Full file path |
| `imports` | `List<String>` | All import paths declared in the file |
| `content` | `String` | The complete raw content of the file |

---