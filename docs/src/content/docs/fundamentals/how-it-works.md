---
title: How It Works
description: The DartUnit rule execution lifecycle — from rule files to reported violations.
sidebar:
  order: 1
---

Understanding DartUnit's execution model helps you write efficient rules and diagnose unexpected behavior.

## The Execution Model

DartUnit integrates with `dart test` — rule files are standard test files discovered and executed in a single `dart test` run.

When you run `dart run dartunit analyze`, the following happens:

```
dart run dartunit analyze
        │
        ▼
 AnalyzeCommand
  ├─ 1. Discover all *_test_arch.dart files in test_arch/
  ├─ 2. Run: dart test test_arch/rule_one_test_arch.dart
  │              test_arch/rule_two_test_arch.dart
  │              test_arch/rule_three_test_arch.dart
  │              --reporter json
  ├─ 3. Collect violations from stderr (DARTUNIT_RESULT: protocol)
  └─ 4. Render summary to console + generate HTML report
```

All rule files are executed in a **single `dart test` invocation**. Each `testArch` call registers a test; each `testArchGroup` groups tests and shares an analysis context across them, analyzing the project only once per group.

## Inside a Rule File

Every rule file is a Dart test file with a `main()` function that uses `testArch()` or `testArchGroup()`:

```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArchGroup('Repository contracts', () {
    testArch('Repository interfaces in domain must be abstract', (arch) {
      expect(
        arch.classes(folder: 'lib/domain/repositories', namePattern: r'.*Repository$'),
        isAbstractClass(),
      );
    });
    testArch('Repository implementations must not be abstract', (arch) {
      expect(
        arch.classes(namePattern: r'.*RepositoryImpl$'),
        isConcreteClass(),
      );
    });
  }, severity: RuleSeverity.error);
}
```

Each `testArch` call:
1. Builds an `ArchSubject` from the `ArchTester` methods (`classes`, `files`, `layer`)
2. Passes it to `expect()` with an arch matcher
3. The matcher runs the predicate against each selected element, emits a `DARTUNIT_RESULT:` protocol line to stderr, and prints the human-readable result to stdout

## The Select → Evaluate → Report Lifecycle

For each `testArch`, the execution follows three stages:

### Stage 1: Select

`arch.classes(folder: 'lib/domain/repositories', namePattern: r'.*Repository$')` produces an `ArchSubject` that wraps:
- The `Selector` (which classes/files match)
- The shared `AnalysisContext` (pre-analyzed project graph)
- The effective `RuleSeverity`

```
arch.classes(folder: 'lib/domain/repositories', namePattern: r'.*Repository$')
  │
  ▼
ArchSubject → [UserRepository, AuthRepository, ProductRepository]
```

### Stage 2: Evaluate

When `expect(subject, matcher)` is called, the matcher applies the predicate to each subject element:

```
isAbstractClass()
  │
  ├─ UserRepository     → abstract class → passed ✓
  ├─ AuthRepository     → abstract class → passed ✓
  └─ ProductRepository  → concrete class → failed ✗ → Violation
```

The semantics are **positive**: the matcher describes the condition a compliant element must satisfy. Use the `doesNot*` family of matchers for "must not" rules.

### Stage 3: Report

The matcher always emits two outputs:

1. **stderr** — `DARTUNIT_RESULT:{json}` consumed by `dartunit analyze` to collect violations
2. **stdout** — Human-readable result for direct `dart test` runs:

```
  ✓  Repository interfaces in domain must be abstract
  ✗  Repository implementations must not be abstract
       ✗ lib/data/repositories/user_repo.dart [error] — must be concrete
```

## Shared Context in testArchGroup

A key performance feature: `testArchGroup` analyzes the project **once** and shares the result across all `testArch` calls inside the group.

```dart
testArchGroup('Domain layer', () {
  // All three testArch calls share the same AnalysisContext.
  // The project is analyzed only once per group.
  testArch('Must not depend on data', (arch) { ... });
  testArch('Must not depend on presentation', (arch) { ... });
  testArch('Must be Flutter-agnostic', (arch) { ... });
}, projectRoot: '.');
```

Standalone `testArch` calls (outside a group) each analyze the project independently.

## Severity

Severity can be set at two levels:

- **Group level** (`testArchGroup(..., severity: RuleSeverity.error)`) — inherited by all `testArch` inside the group
- **Test level** (`testArch(..., severity: RuleSeverity.warning)`) — overrides the group severity for that specific test

Only `error` and `critical` violations cause `dartunit analyze` to exit with code 1.

## Source Code Analysis

DartUnit analyzes project source using regular expressions — not the Dart compiler or analysis server. This keeps it fast and simple.

For each `.dart` file, the parser extracts:

- **Imports and exports** — for dependency graph construction
- **Class declarations** — name, `extends`, `implements`, mixins, `abstract`/`enum`/`mixin` modifiers
- **Annotations** — `@injectable`, `@freezed`, etc.
- **Methods** — name and visibility
- **Fields** — name, type, visibility, `final`/`const`

The result is a dependency graph and a list of analyzed classes that selectors and predicates query.

:::note[Known limitation]
Because the parser uses regex rather than the Dart compiler, code embedded in multiline string literals may be misidentified in rare edge cases. This does not affect typical projects.
:::

## Running a Single Rule During Development

While developing a new rule, run it directly without triggering the full analysis:

```bash
dart test test_arch/my_rule_test_arch.dart
```

## Key Components

| Component | Responsibility |
|-----------|---------------|
| `testArch()` | Registers a single architecture test |
| `testArchGroup()` | Groups tests, analyzes project once, propagates severity |
| `ArchTester` | Passed to each `testArch` body; builds selectors via `classes()`, `files()`, `layer()` |
| `ArchSubject` | Carries the selector, context, and severity — passed to `expect()` |
| Arch matcher | Evaluates predicate, emits `DARTUNIT_RESULT:`, prints ✓/✗ |
| `Violation` | A record of a rule breach |
| Preset function | Calls `testArchGroup`/`testArch` internally for a common pattern |

## File Discovery

`dartunit analyze` looks for files matching `*_test_arch.dart` in the `test_arch/` folder. Files without this suffix are ignored.

```
test_arch/
├── domain_layer_test_arch.dart       ← discovered
├── naming_conventions_test_arch.dart ← discovered
├── helpers.dart                       ← ignored (no _test_arch suffix)
└── README.md                          ← ignored
```

## HTML Report

After every `analyze` run, a self-contained HTML file is generated at `.dartunit/report.html`. It includes:

- Summary cards: total violations, critical, errors, warnings, info
- Full violations table with severity badges, file paths, and rule descriptions
- Dark theme, no external dependencies

The report is always regenerated on each run. To view previous runs, use [`dartunit log`](/cli/log).
