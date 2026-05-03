---
title: How It Works
description: The DartUnit rule execution lifecycle — from rule files to reported violations.
sidebar:
  order: 1
---

Understanding DartUnit's execution model helps you write efficient rules and diagnose unexpected behavior.

## The Execution Model

DartUnit integrates with `dart test` — rule files are standard Dart test files discovered and executed in a single `dart test` invocation. No custom test runner. No parallel process. Just plain Dart tests with architecture semantics.

```
dart run dartunit analyze
        │
        ▼
 AnalyzeCommand
  ├─ 1. Discover all *_test_arch.dart files in test_arch/
  ├─ 2. Run: dart test <file1> <file2> ... --reporter json
  │         └─ Each testArch call:
  │              ├─ Analyzes project source (or reuses group context)
  │              ├─ Selects elements via selector.classes() / selector.files()
  │              ├─ Evaluates matcher (predicate) on each element
  │              ├─ Emits DARTUNIT_RESULT:{json} to stderr
  │              └─ Prints ✓ or ✗ result to stdout
  ├─ 3. Collect violations from stderr (DARTUNIT_RESULT: protocol)
  ├─ 4. Sort violations by severity (critical → error → warning → info)
  ├─ 5. Render summary table to console
  └─ 6. Generate HTML report at .dartunit/report.html
```

## Inside a Rule File

Every rule file is a Dart test file with a `main()` function that uses `testArch()` or `testArchGroup()`:

```dart title="test_arch/repository_contracts_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArchGroup('Repository contracts', () {
    testArch('Repository interfaces in domain must be abstract', (selector) {
      expect(
        selector.classes(inFolder: 'lib/domain/repositories', matchingPattern: r'.*Repository$'),
        isAbstractClass(),
      );
    });

    testArch('Repository implementations must not be abstract', (selector) {
      expect(
        selector.classes(matchingPattern: r'.*RepositoryImpl$'),
        isConcreteClass(),
      );
    });
  }, severity: RuleSeverity.error);
}
```

Each `testArch` call:
1. Builds an `ArchSubject` from the `ArchTester` methods (`classes`, `files`, `layer`)
2. Passes it to `expect()` with an arch matcher
3. The matcher runs the predicate against each selected element, emits a `DARTUNIT_RESULT:` line to stderr, and prints the human-readable result to stdout

## The Select → Evaluate → Report Lifecycle

For each `testArch`, execution follows three stages:

### Stage 1: Select

`selector.classes(inFolder: 'lib/domain/repositories', matchingPattern: r'.*Repository$')` produces an `ArchSubject` wrapping:
- The `Selector` — which classes or files match
- The shared `AnalysisContext` — the pre-analyzed project graph
- The effective `RuleSeverity`

```
selector.classes(inFolder: 'lib/domain/repositories', matchingPattern: r'.*Repository$')
  │
  ▼
ArchSubject → [UserRepository, AuthRepository, ProductRepository]
                    ↑                ↑                 ↑
             abstract ✓         abstract ✓        concrete ✗
```

### Stage 2: Evaluate

When `expect(subject, isAbstractClass())` is called, the matcher applies the predicate to each selected element:

```
isAbstractClass()
  │
  ├─ UserRepository     → abstract class → PASS ✓
  ├─ AuthRepository     → abstract class → PASS ✓
  └─ ProductRepository  → concrete class → FAIL ✗ → Violation recorded
```

The semantics are **positive**: the matcher describes the condition a compliant element must satisfy. Use `doesNot*` / `Not*` predicates for "must not" rules.

### Stage 3: Report

The matcher always emits two outputs:

1. **stderr** — `DARTUNIT_RESULT:{json}` consumed by `dartunit analyze` to collect violations
2. **stdout** — Human-readable result for direct `dart test` runs:

```
  ✓  Repository interfaces in domain must be abstract
  ✗  Repository implementations must not be abstract
       ✗ lib/data/repositories/legacy_repo.dart [error] — must not be abstract
```

## Shared Context in testArchGroup

A key performance feature: `testArchGroup` analyzes the project **once** and shares the result across all `testArch` calls inside the group.

```dart
testArchGroup('Domain layer', () {
  // All three rules share the SAME AnalysisContext.
  // The project is parsed only once for the entire group.
  testArch('Must not depend on data', (selector) { ... });
  testArch('Must not depend on presentation', (selector) { ... });
  testArch('Must be Flutter-agnostic', (selector) { ... });
}, severity: RuleSeverity.error, projectRoot: '.');
```

:::tip[Performance tip]
Prefer `testArchGroup` over multiple standalone `testArch` calls when rules share the same project root. Each standalone `testArch` re-analyzes the project independently.
:::

Standalone `testArch` calls (outside a group) each analyze the project independently.

## Severity

Severity can be set at two levels:

- **Group level** (`testArchGroup(..., severity: RuleSeverity.error)`) — inherited by all `testArch` inside the group
- **Test level** (`testArch(..., severity: RuleSeverity.warning)`) — overrides the group severity for that specific test

```dart
testArchGroup('Domain rules', () {
  testArch('Must not depend on data', (selector) { ... });  // inherits error

  testArch('Should have at most 3 methods per use case', (selector) {
    expect(selector.classes(matchingPattern: r'.*UseCase$'), hasMaxMethods(3));
  }, severity: RuleSeverity.warning);  // override to warning
}, severity: RuleSeverity.error);
```

| Severity | Terminal color | Fails CI? |
|----------|---------------|-----------|
| `RuleSeverity.info` | White | No |
| `RuleSeverity.warning` | Yellow | No |
| `RuleSeverity.error` | Red | **Yes** (exit code 1) |
| `RuleSeverity.critical` | Magenta | **Yes** (exit code 1) |

## Source Code Analysis

DartUnit analyzes your project source using **regular expressions** — not the Dart compiler or the analysis server. This keeps analysis fast and dependency-free.

For each `.dart` file, the parser extracts:

```
lib/domain/usecases/get_user_usecase.dart
  │
  ▼
  Imports  ──────────────► DependencyGraph (who imports whom)
  Classes  ──────────────► AnalyzedClass
    ├── Annotations        (e.g., @injectable, @freezed)
    ├── extends / implements / with
    ├── Methods            (name, visibility, static, abstract)
    └── Fields             (name, type, final, const, public)
```

The result is an `AnalysisContext` — an immutable snapshot of your project's structure that all selectors and predicates query.

:::note[Known limitation]
Because the parser uses regex rather than the Dart compiler, code embedded in multiline string literals may be misidentified in rare edge cases. This does not affect typical projects.
:::

## Running a Single Rule During Development

While developing a new rule, run it directly without triggering the full analysis:

```bash
dart test test_arch/my_rule_test_arch.dart
```

The output is identical to what `dartunit analyze` shows for that file. When you're satisfied, the rule is automatically picked up by:

```bash
dart run dartunit analyze
```

## Key Components

| Component | Responsibility |
|-----------|---------------|
| `testArch()` | Registers a single architecture test |
| `testArchGroup()` | Groups tests, analyzes project once, propagates severity |
| `ArchTester` | Passed to each `testArch` body; builds selectors via `classes()`, `files()`, `layer()` |
| `ArchSubject` | Carries the selector, context, and severity — passed to `expect()` |
| Arch matcher | Evaluates predicate, emits `DARTUNIT_RESULT:`, prints ✓/✗ |
| `Violation` | A single detected rule breach with file path, line, and message |
| Preset function | Calls `testArchGroup`/`testArch` internally for a common architectural pattern |

## File Discovery

`dartunit analyze` scans the `test_arch/` folder for files matching `*_test_arch.dart`. Files without this suffix are silently ignored.

```
test_arch/
├── domain_layer_test_arch.dart        ← discovered ✓
├── naming_conventions_test_arch.dart  ← discovered ✓
├── helpers.dart                        ← ignored (no suffix match)
└── README.md                           ← ignored
```

All discovered files are passed to a single `dart test` invocation. This means:
- Tests across files can run in parallel (controlled by `dart test`)
- Each `testArchGroup` within a file analyzes the project **once** for its group
- Standalone `testArch` calls each analyze the project independently

## HTML Report

After every `analyze` run, a self-contained HTML file is generated at `.dartunit/report.html`. It includes:

- **Summary cards**: total violations, critical, errors, warnings, info
- **Full violations table**: severity badges, file paths, rule descriptions, and line numbers
- **Dark theme**: no external dependencies — works completely offline

The report is regenerated on each run. To view a historical run, use [`dartunit log`](/cli/log).
