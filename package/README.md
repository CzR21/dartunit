# dartunit

Architecture testing tool for Dart and Flutter projects, inspired by [ArchUnit](https://www.archunit.org/) and [ArchUnitNET](https://archunitnet.readthedocs.io/).

---

## What is dartunit?

dartunit lets you define **architecture rules as Dart test files** and validates them against your project's source code. Violations are reported to the console (and saved as an HTML report), making it easy to enforce architectural boundaries in CI.

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

Or activate globally:

```bash
dart pub global activate dartunit
```

---

## Quick Start

```bash
# 1. Scaffold the test_arch/ folder
dart run dartunit init

# 2. Edit test_arch/example_test_arch.dart with your rules

# 3. Run the analysis
dart run dartunit analyze
```

---

## Writing Rules

Rules live in `test_arch/` as regular Dart files ending with `_arch_test.dart`.  
They use the `testArch` function — analogous to `testWidgets` in Flutter.

```dart
// test_arch/domain_arch_test.dart
import 'package:dartunit/dartunit.dart';
import 'package:test/test.dart';

void main() => testArch('Domain must not depend on Data', (arch) {
  final domain = arch.classes(folder: 'lib/domain');
  expect(domain, doesNotDependOn('lib/data'));
});
```

You can also group related rules to share a single analysis pass:

```dart
void main() => testArchGroup('Naming conventions', (arch) {
  testArch('Blocs must end with Bloc', (arch) {
    expect(arch.classes(folder: 'lib/bloc'), nameEndsWith('Bloc'));
  });
  testArch('Repositories must end with Repository', (arch) {
    expect(arch.classes(folder: 'lib/data'), nameEndsWith('Repository'));
  });
}, severity: RuleSeverity.warning);
```

---

## CLI Commands

### `dartunit init`

Creates the `test_arch/` folder with an example rule.

```bash
dart run dartunit init
dart run dartunit init --template clean   # scaffold from a preset template
```

Options:

| Flag | Description |
|------|-------------|
| `-p, --path` | Path to the target project (default: `.`) |
| `-t, --template` | Pre-set template: `bloc`, `clean`, `mvc`, `mvvm` |

### `dartunit analyze`

Runs all `*_arch_test.dart` files in `test_arch/` and reports violations.

```bash
dart run dartunit analyze
dart run dartunit analyze --path /path/to/project
dart run dartunit analyze --no-color
```

Options:

| Flag | Description |
|------|-------------|
| `-p, --path` | Path to the target project (default: `.`) |
| `--no-color` | Disable coloured output |

Exit codes:

| Code | Meaning |
|------|---------|
| `0` | All rules passed |
| `1` | One or more `error` or `critical` violations found |
| `2` | Configuration error or unexpected exception |

After each run, an HTML report is saved to `.dartunit/report.html`.

### `dartunit generate <rule_name>`

Scaffolds a new rule file in `test_arch/`.

```bash
dart run dartunit generate no_repository_in_ui
# Creates test_arch/no_repository_in_ui_arch_test.dart
```

### `dartunit log`

Shows the history of the last analysis runs.

```bash
dart run dartunit log
dart run dartunit log --no-color
```

---

## Selectors

Inside a `testArch` body, `arch` is an `ArchTester` that provides three selectors:

```dart
// Select classes
arch.classes(folder: 'lib/domain')
arch.classes(suffix: 'Bloc')
arch.classes(prefix: 'Base', folder: 'lib/core')
arch.classes(namePattern: r'.*Impl$')

// Select files
arch.files(folder: 'lib/data')
arch.files(suffix: '_test.dart')

// Select a named architectural layer
arch.layer('Domain', folder: 'lib/domain')
```

All selectors accept an `exceptions` list — file path substrings exempt from the rule:

```dart
arch.classes(folder: 'lib/ui', exceptions: ['lib/ui/legacy/'])
```

---

## Matchers

### Dependency

| Matcher | Description |
|---------|-------------|
| `doesNotDependOn(folder)` | Class must NOT import from folder |
| `dependsOn(folder)` | Class must import from folder |
| `doesNotDependOnTransitive(folder)` | No transitive dependency on folder |
| `dependsOnTransitive(folder)` | Must transitively depend on folder |
| `doesNotDependOnPackage(pkg)` | Must NOT import from package |
| `dependsOnPackage(pkg)` | Must import from package |
| `onlyDependsOnFolders([...])` | May only import from listed folders |
| `hasMaxImports(n)` | At most N imports |
| `hasCircularDependency()` | Is part of a circular import chain |
| `hasNoCircularDependency()` | Must NOT be part of any cycle |

### Naming

| Matcher | Description |
|---------|-------------|
| `nameEndsWith(suffix)` | Name ends with suffix |
| `nameStartsWith(prefix)` | Name starts with prefix |
| `nameContains(substring)` | Name contains substring |
| `nameMatchesPattern(regex)` | Name matches regex |

### Annotations

| Matcher | Description |
|---------|-------------|
| `hasAnnotation(name)` | Must carry `@name` |
| `doesNotHaveAnnotation(name)` | Must NOT carry `@name` |

### Inheritance

| Matcher | Description |
|---------|-------------|
| `extendsClass(name)` | Must extend class |
| `implementsInterface(name)` | Must implement interface |
| `usesMixin(name)` | Must use mixin |

### Structural kind

| Matcher | Description |
|---------|-------------|
| `isAbstractClass()` | Must be `abstract` |
| `isConcreteClass()` | Must be a concrete class |
| `isEnumType()` | Must be an `enum` |
| `isMixinType()` | Must be a `mixin` |
| `isExtensionType()` | Must be an `extension` |

### Metrics

| Matcher | Description |
|---------|-------------|
| `hasMaxMethods(n)` | At most N methods |
| `hasMinMethods(n)` | At least N methods |
| `hasMaxFields(n)` | At most N fields |
| `hasMinFields(n)` | At least N fields |

### Fields & Methods

| Matcher | Description |
|---------|-------------|
| `hasAllFinalFields()` | All instance fields must be `final` |
| `hasNoPublicFields()` | No public (non-`_`) fields |
| `hasMethod(name)` | Must declare a method with this name |
| `hasNoPublicMethods()` | No public methods |

### File content

| Matcher | Description |
|---------|-------------|
| `hasContent(pattern)` | File source matches regex |
| `hasNoContent(pattern)` | File source must NOT match regex |

---

## Severity

Each test inherits its severity from `testArchGroup`, or defaults to `RuleSeverity.error`.  
Override per test:

```dart
testArch('...', (arch) { ... }, severity: RuleSeverity.warning);
```

| Severity | Fails build? | Colour |
|----------|-------------|--------|
| `info` | No | Cyan |
| `warning` | No | Yellow |
| `error` | Yes (exit 1) | Red |
| `critical` | Yes (exit 1) | Magenta |

---

## Example Rule File

```dart
// test_arch/layered_arch_test.dart
import 'package:dartunit/dartunit.dart';
import 'package:test/test.dart';

void main() => testArchGroup('Layered Architecture', (arch) {
  testArch('Domain must not depend on Data', (arch) {
    expect(arch.layer('Domain', folder: 'lib/domain'),
        doesNotDependOn('lib/data'));
  });

  testArch('Domain must not depend on Presentation', (arch) {
    expect(arch.layer('Domain', folder: 'lib/domain'),
        doesNotDependOn('lib/presentation'));
  });

  testArch('No circular dependencies', (arch) {
    expect(arch.files(), hasNoCircularDependency());
  });

  testArch('Value objects must be immutable', (arch) {
    expect(arch.classes(folder: 'lib/domain/value_objects'),
        hasAllFinalFields());
  });

  testArch('No print() calls in lib/', (arch) {
    expect(arch.files(folder: 'lib'), hasNoContent(r'print\s*\('));
  });
}, severity: RuleSeverity.error);
```

---

## Preset Rule Factories

For common patterns you can use preset factories instead of writing matchers manually:

```dart
import 'package:dartunit/dartunit.dart';

// Naming: all classes in lib/bloc must end with "Bloc"
final rules = namingFolderSuffix(folders: ['lib/bloc', 'lib/repository']);

// Layered architecture (generates N² rules)
final rules = layeredArchitecture(layers: [
  LayerDef(name: 'Presentation', folder: 'lib/presentation',
      canAccess: ['lib/bloc', 'lib/domain']),
  LayerDef(name: 'Bloc', folder: 'lib/bloc', canAccess: ['lib/domain']),
  LayerDef(name: 'Domain', folder: 'lib/domain', canAccess: []),
]);
```

---

## CI Integration

```yaml
# .github/workflows/ci.yml
- name: Architecture check
  run: dart run dartunit analyze
```

Returns exit code `1` if any `error` or `critical` violations are found.

---

## Architecture Overview

```
dartunit/
├── bin/
│   └── dartunit.dart                  # CLI entry point
├── lib/
│   ├── dartunit.dart                  # Barrel export — public API
│   ├── cli/
│   │   ├── dartunit_cli.dart          # CommandRunner
│   │   ├── commands/
│   │   │   ├── init_command.dart      # dartunit init
│   │   │   ├── analyze_command.dart   # dartunit analyze
│   │   │   ├── generate_command.dart  # dartunit generate
│   │   │   └── log_command.dart       # dartunit log
│   │   └── templates/                 # bloc / clean / mvc / mvvm scaffolds
│   ├── runner/
│   │   ├── arch_runner.dart           # testArch / testArchGroup
│   │   ├── arch_tester.dart           # ArchTester + ArchSubject
│   │   └── arch_matchers.dart         # All matcher functions
│   ├── core/
│   │   ├── entities/                  # Rule, Predicate, Selector, Violation …
│   │   ├── predicates/                # 25+ predicate implementations
│   │   ├── selectors/                 # ClassSelector, FileSelector, LayerSelector
│   │   └── enums/                     # RuleSeverity, ExitCode, ArchTemplate …
│   ├── analyzer/
│   │   ├── project_analyzer.dart      # Regex-based Dart source parser
│   │   ├── context/                   # AnalysisContext
│   │   ├── models/                    # AnalyzedClass, AnalyzedFile …
│   │   ├── parsers/                   # ImportParser, ClassParser
│   │   └── graph/                     # DependencyGraph + cycle detection
│   ├── engine/
│   │   ├── rule_engine.dart           # Runs all rules, collects violations
│   │   ├── rule_executor.dart         # Runs a single rule safely
│   │   ├── analysis_logger.dart       # Persists run history to disk
│   │   └── custom_rule_loader.dart
│   ├── presets/                       # Preset rule factories (14 presets)
│   └── reporter/
│       ├── console_reporter.dart      # Coloured table output
│       └── html_reporter.dart         # HTML report at .dartunit/report.html
└── test_arch/                         # Your architecture rules live here
    └── *_arch_test.dart
```

### Data flow

```
test_arch/*_arch_test.dart
        │
        ▼  dart test (subprocess)
  testArch / testArchGroup
        │
        ├─ ProjectAnalyzer  →  AnalysisContext
        │
        ├─ ArchTester.classes/files/layer  →  ArchSubject
        │
        ├─ expect(subject, matcher)
        │       └─ ArchMatcher → RuleExecutor → List<Violation>
        │               └─ DARTUNIT_RESULT:{…}  (stderr, JSON)
        │
        ▼
  AnalyzeCommand (parent process)
        ├─ ConsoleReporter  →  stdout table
        ├─ AnalysisLogger   →  .dartunit/log.json
        └─ HtmlReporter     →  .dartunit/report.html
```

---

## Known Limitations

- The analyzer uses **regex-based parsing**, which may over-count in edge cases (e.g. code inside string literals).
- Custom rules are **not dynamically loaded** at runtime (Dart does not support `dart:mirrors` in AOT mode). Write them directly as `_arch_test.dart` files instead.

---

## License

MIT
