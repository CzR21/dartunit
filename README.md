# dartunit

Architecture testing tool for Dart and Flutter projects, inspired by [ArchUnit](https://www.archunit.org/) and [ArchUnitNET](https://archunitnet.readthedocs.io/).

---

## What is dartunit?

dartunit lets you define **architecture rules** in YAML (or pure Dart) and validates them against your project's source code. Violations are reported to the console, making it easy to enforce architectural boundaries in your CI pipeline.

Typical use cases:

- Prevent the domain layer from importing the data layer
- Enforce naming conventions (`*Repository`, `*Bloc`, `*Cubit`)
- Detect circular imports
- Limit class complexity (max methods, max fields)
- Require all fields in value objects to be `final`
- Ban `print()` calls across the codebase

---

## Installation

Add as a dev dependency:

```yaml
# pubspec.yaml
dev_dependencies:
  dartunit: ^0.1.0
```

Or activate globally to use the CLI without `dart run`:

```bash
dart pub global activate dartunit
```

---

## Quick Start

```bash
# 1. Scaffold the configuration folder
dart run dartunit init

# 2. Edit .dartunit/dartunit.yaml with your rules

# 3. Run the analysis
dart run dartunit analyze
```

---

## CLI Commands

### `dartunit init`

Creates the `.dartunit/` scaffold inside the target project:

```
.dartunit/
├── dartunit.yaml          # Rule configuration
├── README.md              # Quick-reference documentation
└── custom_rules/
    └── example_rule.dart  # Example custom rule
```

Options:

| Flag | Description |
|------|-------------|
| `-p, --path` | Path to the target project (default: `.`) |

### `dartunit analyze`

Analyzes the project source code against all configured rules.

```bash
dart run dartunit analyze
dart run dartunit analyze --path /path/to/project
dart run dartunit analyze --config /path/to/dartunit.yaml
dart run dartunit analyze --no-color
```

Options:

| Flag | Description |
|------|-------------|
| `-p, --path` | Path to the target project (default: `.`) |
| `-c, --config` | Path to `dartunit.yaml` (default: `.dartunit/dartunit.yaml`) |
| `--no-color` | Disable coloured output |

Exit codes:

| Code | Meaning |
|------|---------|
| `0` | All rules passed |
| `1` | One or more `error` or `critical` violations found |
| `2` | Configuration error or unexpected exception |

### `dartunit generate <rule_name>`

Scaffolds a new custom rule file and appends a placeholder entry to `dartunit.yaml`.

```bash
dart run dartunit generate no_repository_in_ui
```

Creates `.dartunit/custom_rules/no_repository_in_ui_rule.dart` with a ready-to-implement template.

---

## YAML Rule Format

```yaml
# .dartunit/dartunit.yaml
rules:
  - id: R001
    description: Domain layer must not depend on Data layer
    severity: error        # info | warning | error | critical
    selector:
      type: class          # class | file | layer
      where:
        folder: lib/domain
    predicate:
      not:
        type: dependOnFolder
        value: lib/data
```

---

## Selectors

Selectors determine **which subjects** a rule applies to.

### Selector types

| type | Description |
|------|-------------|
| `class` | Selects Dart classes matching the `where` criteria |
| `file` | Selects Dart source files matching the `where` criteria |
| `layer` | Selects all classes inside a named layer folder |

### `where` options

| Option | Description |
|--------|-------------|
| `folder` | Match subjects inside this folder path |
| `namePattern` | Regex matched against the class name |
| `annotatedWith` | Class must carry this annotation |
| `extends` | Class must extend this type |
| `implements` | Class must implement this interface |

---

## Predicates

Predicates express **positive conditions** — they pass when the condition IS met. Use `not` to invert.

### Dependency

| type | value | Description |
|------|-------|-------------|
| `dependOnFolder` | `String` | Passes when the class has at least one import from the given folder path. Use with `not` to forbid a dependency. |
| `dependOnPackage` | `String` | Passes when the class imports any path starting with `package:<name>/`. |
| `onlyDependOnFolders` | `List<String>` | Passes when every import belongs to one of the listed folders. Fails and reports any forbidden import. |
| `maxImports` | `int` | Passes when the total number of imports is at most N. |
| `hasCircularDependency` | — | Passes when the file is part of a circular import chain. Use with `not` to forbid cycles. |

### Naming

| type | value | Description |
|------|-------|-------------|
| `nameEndsWith` | `String` | Class name ends with the given suffix. |
| `nameStartsWith` | `String` | Class name starts with the given prefix. |
| `nameContains` | `String` | Class name contains the given substring. |
| `nameMatchesPattern` | `String` (regex) | Class name matches the regular expression. |

### Annotations

| type | value | Description |
|------|-------|-------------|
| `annotatedWith` | `String` | Class carries the given annotation (without the leading `@`). |
| `notAnnotatedWith` | `String` | Class does NOT carry the given annotation. |

### Inheritance

| type | value | Description |
|------|-------|-------------|
| `extends` | `String` | Class extends the given type. |
| `implements` | `String` | Class implements the given interface. |
| `usesMixin` | `String` | Class uses the given mixin. |

### Structural kind

| type | value | Description |
|------|-------|-------------|
| `isAbstract` | — | Class is declared `abstract`. |
| `isMixin` | — | Declared as a `mixin`. |
| `isExtension` | — | Declared as an `extension`. |
| `isEnum` | — | Declared as an `enum`. |
| `isConcrete` | — | Concrete class: not abstract, mixin, enum, or extension. |

### Metrics

| type | value | Description |
|------|-------|-------------|
| `maxMethods` | `int` | Class has at most N methods. |
| `minMethods` | `int` | Class has at least N methods. |
| `maxFields` | `int` | Class has at most N fields. |
| `minFields` | `int` | Class has at least N fields. |

### Fields

| type | value | Description |
|------|-------|-------------|
| `hasAllFinalFields` | — | All instance fields are `final` or `const` (no mutable state). |
| `hasNoPublicFields` | — | No public (non-`_`) instance fields exposed. |

### Methods

| type | value | Description |
|------|-------|-------------|
| `hasMethod` | `String` | Class declares a method with the given name. |
| `hasNoPublicMethods` | — | No public (non-`_`) methods exposed. |

### File content

| type | value | Description |
|------|-------|-------------|
| `fileContentMatches` | `String` (regex) | Raw file source matches the pattern. Designed for use with `FileSelector`. Use with `not` to ban patterns such as `print(`. |

---

## Composite Predicates

```yaml
# Negation — passes when inner predicate FAILS
predicate:
  not:
    type: dependOnFolder
    value: lib/data

# AND — all conditions must pass
predicate:
  and:
    - type: nameEndsWith
      value: Repository
    - type: dependOnFolder
      value: lib/data

# OR — at least one condition must pass
predicate:
  or:
    - type: nameEndsWith
      value: Bloc
    - type: nameEndsWith
      value: Cubit
```

---

## Example Rules

```yaml
rules:

  # Domain layer must not import Data layer
  - id: R001
    description: Domain layer must not depend on Data layer
    severity: error
    selector:
      type: class
      where:
        folder: lib/domain
    predicate:
      not:
        type: dependOnFolder
        value: lib/data

  # No circular imports anywhere
  - id: R002
    description: No circular dependencies allowed
    severity: critical
    selector:
      type: file
    predicate:
      not:
        type: hasCircularDependency

  # Value objects must be immutable
  - id: R003
    description: Value objects must have all final fields
    severity: warning
    selector:
      type: class
      where:
        folder: lib/domain/value_objects
    predicate:
      type: hasAllFinalFields

  # God-class guard
  - id: R004
    description: Classes must not exceed 10 methods
    severity: warning
    selector:
      type: class
    predicate:
      type: maxMethods
      value: 10

  # Ban print() in production code
  - id: R005
    description: No print() calls in lib/
    severity: error
    selector:
      type: file
      where:
        folder: lib
    predicate:
      not:
        type: fileContentMatches
        value: "print\\("
```

---

## Custom Rules

For rules that require logic beyond what YAML supports, implement `CustomArchitectureRule` in Dart.

### Generate a scaffold

```bash
dart run dartunit generate no_repository_in_ui
```

### Implement the rule

```dart
// .dartunit/custom_rules/no_repository_in_ui_rule.dart
import 'package:dartunit/dartunit.dart';

class NoRepositoryInUiRule implements CustomArchitectureRule {
  @override
  String get id => 'CUSTOM_NO_REPOSITORY_IN_UI';

  @override
  String get description => 'UI layer must not access repositories directly';

  @override
  ArchitectureRule build() {
    return ArchitectureRule(
      id: id,
      description: description,
      severity: RuleSeverity.error,
      selector: ClassSelector(folder: 'lib/ui'),
      predicate: NotPredicate(DependOnFolderPredicate('lib/data')),
    );
  }
}
```

### Register in `dartunit.yaml`

```yaml
rules:
  - id: CUSTOM_NO_REPOSITORY_IN_UI
    type: custom
    implementation: no_repository_in_ui_rule.dart
    description: UI must not access repositories directly
```

---

## Predicate Semantics

Predicates express **positive conditions** (the condition IS met):

- `DependOnFolderPredicate('lib/data')` **passes** when the class imports from `lib/data`.
- Wrap with `NotPredicate` to enforce "must NOT":

```dart
// Violation when a domain class imports lib/data
NotPredicate(DependOnFolderPredicate('lib/data'))
```

`PredicateResult.pass(message)` carries a description that `NotPredicate` reuses as the violation message, so the output is always informative.

---

## CI Integration

```yaml
# .github/workflows/ci.yml
- name: Architecture check
  run: dart run dartunit analyze
```

Returns exit code `1` if any `error` or `critical` violations are found, making the CI step fail automatically.

---

## Architecture Overview

```
dartunit/
├── bin/
│   └── dartunit.dart              # CLI entry point
├── lib/
│   ├── dartunit.dart              # Barrel export — public API
│   ├── cli/
│   │   ├── dartunit_cli.dart      # CommandRunner wrapper
│   │   └── commands/
│   │       ├── init_command.dart      # dartunit init
│   │       ├── analyze_command.dart   # dartunit analyze
│   │       └── generate_command.dart  # dartunit generate
│   ├── core/
│   │   ├── rule/
│   │   │   ├── architecture_rule.dart # Rule model + evaluation logic
│   │   │   ├── rule_violation.dart    # Violation model
│   │   │   └── rule_severity.dart     # Severity enum
│   │   ├── selector/
│   │   │   ├── selector.dart          # Selector base + Subject
│   │   │   ├── class_selector.dart    # Filters by class attributes
│   │   │   ├── file_selector.dart     # Filters by file attributes
│   │   │   └── layer_selector.dart    # Filters by layer folder
│   │   └── predicate/
│   │       ├── predicate.dart         # Predicate base + PredicateResult
│   │       ├── dependency_predicate.dart
│   │       ├── naming_predicate.dart
│   │       ├── annotation_predicate.dart
│   │       ├── inheritance_predicate.dart
│   │       ├── metrics_predicate.dart
│   │       └── composite/
│   │           ├── and_predicate.dart
│   │           ├── or_predicate.dart
│   │           └── not_predicate.dart
│   ├── analyzer/
│   │   ├── project_analyzer.dart      # Regex-based Dart source parser
│   │   ├── analysis_context.dart      # Query facade over analysis results
│   │   ├── models/
│   │   │   ├── analyzed_class.dart
│   │   │   ├── analyzed_file.dart
│   │   │   ├── analyzed_method.dart
│   │   │   └── analyzed_field.dart
│   │   └── graph/
│   │       └── dependency_graph.dart  # Directed import graph + cycle detection
│   ├── engine/
│   │   ├── rule_engine.dart           # Runs all rules, collects violations
│   │   ├── rule_executor.dart         # Runs a single rule safely
│   │   └── custom_rule_loader.dart    # Discovers custom rule files
│   ├── yaml/
│   │   └── yaml_rule_parser.dart      # Parses dartunit.yaml into rule objects
│   └── reporter/
│       └── console_reporter.dart      # Coloured console output
└── test/
    └── ...                            # 54 unit tests
```

### Data flow

```
dartunit.yaml
      |
      v
 YamlRuleParser  -->  List<ArchitectureRule>
                                |
                                v
 ProjectAnalyzer -->  AnalysisContext (classes, files, graph)
                                |
                                v
     RuleEngine  -->  List<RuleViolation>
                                |
                                v
   ConsoleReporter  -->  stdout / exit code
```

---

## Known Limitations

- The analyzer uses **regex-based parsing**, which may over-count methods whose names appear in string literals.
- Custom rules are **discovered but not dynamically loaded** at runtime (Dart does not support `dart:mirrors` in AOT mode). Register rules in a custom runner instead.
- SDK version is pinned to `^3.0.0` to match the available `analyzer` package version.

---

## License

MIT
