---
title:  Violations
description: How Violation represent the elements under evaluation and the breaches found.
sidebar:
  order: 7
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

### Severity inheritance and override

A violation's severity comes from the rule that produced it. When a `testArch` is inside a `testArchGroup`, the **group severity always overrides** the individual `testArch` severity — the `testArch`-level `severity` parameter is ignored:

```dart
testArchGroup('Domain rules', () {

  testArch('Must not depend on data', (selector) {
    // ...
  }, severity: RuleSeverity.warning);   // ← ignored, group overrides

  testArch('Must be Flutter-agnostic', (selector) {
    // ...
  });                                   // ← also inherits group severity

}, severity: RuleSeverity.error);       // ← this wins for ALL tests in the group
```

Any violation from this group will have `severity: error`, regardless of what the individual `testArch` declared.

A `testArch` defined outside any group uses its own `severity` (defaulting to `RuleSeverity.error`).

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
