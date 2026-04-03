---
title: Subjects and Violations
description: How Subject and Violation represent the elements under evaluation and the breaches found.
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

## Violation — A Detected Rule Breach

A `Violation` represents a single detected rule breach. Each `Subject` that fails a rule's predicate produces exactly one `Violation`.

### Structure

```
Violation {
  ruleDescription: "BLoC classes must not depend on the view layer"
  message:         "Class UserBloc imports from lib/presentation/views"
  filePath:        "lib/bloc/user_bloc.dart"
  line:            3
  severity:        RuleSeverity.error
}
```

### Fields

| Field | Description |
|-------|-------------|
| `ruleDescription` | The `description` string from the `ArchitectureRule` |
| `message` | A specific message explaining this particular violation |
| `filePath` | Path to the file where the violation was detected |
| `line` | Approximate line number (typically line 1 for class-level violations) |
| `severity` | The severity level: `info`, `warning`, `error`, or `critical` |

### Console output

The `analyze` command renders violations as an ASCII table, sorted by severity from most severe to least:

```
┌──────────┬──────────────────────────────────────────────┬────────────────────────────────────────┬──────┐
│ Severity │ Rule                                         │ File                                   │ Line │
├──────────┼──────────────────────────────────────────────┼────────────────────────────────────────┼──────┤
│ CRITICAL │ No circular dependencies                     │ lib/core/services/auth_service.dart    │   1  │
│ ERROR    │ Domain must not depend on data layer         │ lib/domain/usecases/get_user.dart      │   3  │
│ WARNING  │ Classes in lib/bloc must end with Bloc       │ lib/bloc/auth_manager.dart             │   1  │
│ INFO     │ High import count (informational)            │ lib/core/utils/helpers.dart            │   1  │
└──────────┴──────────────────────────────────────────────┴────────────────────────────────────────┴──────┘

4 violations found (1 critical, 1 error, 1 warning, 1 info)
```

### Severity colors in the terminal

| Severity | Color |
|----------|-------|
| `info` | White |
| `warning` | Yellow |
| `error` | Red |
| `critical` | Magenta |

Use `--no-color` with `dartunit analyze` to disable color output in CI environments.

### HTML report

After every `analyze` run, a self-contained HTML report is generated in the project root. It includes:

- Summary cards showing total violations, critical, errors, warnings, and info counts
- A full violations table with severity badges, rule descriptions, file paths, and line numbers
- Dark theme with no external dependencies

### Exit codes

The `analyze` process exits with a code that reflects the most severe violation found:

| Exit Code | Condition |
|-----------|-----------|
| `0` | No violations, or only `info` and `warning` violations |
| `1` | At least one `error` or `critical` violation |
| `2` | Configuration or runtime error before analysis could complete |

This makes CI integration straightforward — any `error` or `critical` violation automatically fails the pipeline.
