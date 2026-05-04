# dartunit

Architecture testing tool for Dart and Flutter projects, inspired by [ArchUnit](https://www.archunit.org/) and [ArchUnitNET](https://archunitnet.readthedocs.io/).

---

## What is dartunit?

dartunit lets you define **architecture rules** as Dart tests and validates them against your project's source code. Violations are reported to the console (and an HTML report), making it easy to enforce architectural boundaries in your CI pipeline.

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
  dartunit: ^1.0.0
```

Or activate globally to use the CLI without `dart run`:

```bash
dart pub global activate dartunit
```

---

## Quick Start

```bash
# 1. Scaffold the test_arch/ folder
dart run dartunit init

# 2. Edit test_arch/example_arch_test.dart with your rules

# 3. Run the analysis
dart run dartunit analyze
```

---

## CLI Commands

### `dartunit init`

Creates the `test_arch/` scaffold inside the target project:

```
test_arch/
└── example_arch_test.dart   # Ready-to-edit example rule
```

Use `--template` to scaffold a set of pre-built rules for a common architecture:

```bash
dart run dartunit init --template clean   # Clean Architecture
dart run dartunit init --template bloc    # BLoC pattern
dart run dartunit init --template mvc     # MVC
dart run dartunit init --template mvvm    # MVVM
```

Options:

| Flag | Description |
|------|-------------|
| `-p, --path` | Path to the target project (default: `.`) |
| `-t, --template` | Architecture template: `bloc`, `clean`, `mvc`, `mvvm` |

### `dartunit analyze`

Discovers all `*_arch_test.dart` files in `test_arch/`, runs them with `dart test`, and reports violations.

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

An HTML report is written to `.dartunit/report.html` after every run.

### `dartunit generate <rule_name>`

Scaffolds a new rule file in `test_arch/`.

```bash
dart run dartunit generate no_repository_in_ui
```

Creates `test_arch/no_repository_in_ui_arch_test.dart` with a ready-to-implement template.

### `dartunit log`

Shows the history of the last analysis runs stored in `.dartunit/log.ndjson`.

```bash
dart run dartunit log
dart run dartunit log --path /path/to/project
```

Options:

| Flag | Description |
|------|-------------|
| `-p, --path` | Path to the target project (default: `.`) |
| `--no-color` | Disable coloured output |

---

## Writing Architecture Tests

Rule files live in `test_arch/` and must end in `_arch_test.dart`. Each file is a standard Dart test file.

### Single test — `testArch`

```dart
// test_arch/domain_isolation_arch_test.dart
import 'package:dartunit/dartunit.dart';
import 'package:test/test.dart';

void main() => testArch('Domain must not depend on data layer', (selector) {
  final domain = selector.classes(inFolder: 'lib/domain');
  expect(domain, doesNotDependOn('lib/data'));
});
```

### Grouped tests — `testArchGroup`

Groups analyze the project **once** and share the context across all inner tests — faster than running each test independently.

```dart
void main() {
  testArchGroup('Domain isolation', () {
    testArch('must not depend on data', (selector) {
      expect(selector.classes(inFolder: 'lib/domain'), doesNotDependOn('lib/data'));
    });
    testArch('must be Flutter-agnostic', (selector) {
      expect(selector.classes(inFolder: 'lib/domain'), doesNotDependOnPackage('flutter'));
    });
  }, severity: RuleSeverity.error);
}
```

### `testArch` signature

```dart
void testArch(
  String description,
  FutureOr<void> Function(ArchTester selector) body, {
  String projectRoot = '.',
  RuleSeverity? severity,
})
```

### `testArchGroup` signature

```dart
void testArchGroup(
  String groupName,
  void Function() body, {
  String projectRoot = '.',
  RuleSeverity severity = RuleSeverity.error,
})
```

---

## Selectors

`ArchTester` (the `selector` parameter) provides three factory methods.

### `selector.classes()`

Selects Dart classes:

```dart
selector.classes(inFolder: 'lib/domain')
selector.classes(hasSuffix: 'Bloc')
selector.classes(hasPrefix: 'I', hasSuffix: 'Repository')
selector.classes(matchingPattern: r'.*Bloc$')
selector.classes(inFolder: 'lib/ui', exceptions: ['lib/ui/legacy/'])
```

| Parameter | Description |
|-----------|-------------|
| `inFolder` | Only classes inside this folder path |
| `hasPrefix` | Class name starts with this string |
| `hasSuffix` | Class name ends with this string |
| `matchingPattern` | Raw regex matched against the class name |
| `exceptions` | File path substrings exempt from the rule |

### `selector.files()`

Selects Dart source files:

```dart
selector.files(inFolder: 'lib')
selector.files(hasSuffix: '_service.dart')
selector.files(exceptions: ['test/'])
```

Same parameters as `classes()`.

### `selector.layer()`

Selects all classes belonging to a named architectural layer:

```dart
selector.layer('domain', inFolder: 'lib/domain')
selector.layer('ui', inFolder: 'lib/ui', exceptions: ['lib/ui/legacy/'])
```

---

## Matchers

Pass the subject to `expect()` with one of these matchers.

### Dependency

| Matcher | Description |
|---------|-------------|
| `doesNotDependOn(folder)` | Classes must NOT import from `folder` |
| `dependsOn(folder)` | Classes must import from `folder` |
| `doesNotDependOnTransitive(folder)` | Classes must NOT transitively import from `folder` |
| `dependsOnTransitive(folder)` | Classes must transitively import from `folder` |
| `doesNotDependOnPackage(pkg)` | Classes must NOT import `package:<pkg>/` |
| `dependsOnPackage(pkg)` | Classes must import `package:<pkg>/` |
| `onlyDependsOnFolders(folders)` | Classes may only import from the listed `folders` |
| `hasMaxImports(max)` | Classes have at most `max` imports |

### Circular dependencies

| Matcher | Description |
|---------|-------------|
| `hasNoCircularDependency()` | Files are NOT part of a circular import chain |
| `hasCircularDependency()` | Files ARE part of a circular import chain |

### Naming

| Matcher | Description |
|---------|-------------|
| `nameEndsWith(suffix)` | Name ends with `suffix` |
| `nameStartsWith(prefix)` | Name starts with `prefix` |
| `nameContains(substring)` | Name contains `substring` |
| `nameMatchesPattern(regex)` | Name matches the regular expression |

### Annotations

| Matcher | Description |
|---------|-------------|
| `hasAnnotation(name)` | Class carries `@name` |
| `doesNotHaveAnnotation(name)` | Class does NOT carry `@name` |

### Inheritance

| Matcher | Description |
|---------|-------------|
| `extendsClass(name)` | Class extends `name` |
| `implementsInterface(name)` | Class implements `name` |
| `usesMixin(name)` | Class uses mixin `name` |

### Structural kind

| Matcher | Description |
|---------|-------------|
| `isAbstractClass()` | Class is declared `abstract` |
| `isConcreteClass()` | Class is not abstract, mixin, enum, or extension |
| `isEnumType()` | Declared as an `enum` |
| `isMixinType()` | Declared as a `mixin` |
| `isExtensionType()` | Declared as an `extension` |

### Metrics

| Matcher | Description |
|---------|-------------|
| `hasMaxMethods(max)` | At most `max` methods |
| `hasMinMethods(min)` | At least `min` methods |
| `hasMaxFields(max)` | At most `max` fields |
| `hasMinFields(min)` | At least `min` fields |

### Fields & methods

| Matcher | Description |
|---------|-------------|
| `hasAllFinalFields()` | All instance fields are `final` |
| `hasNoPublicFields()` | No public instance fields |
| `hasMethod(name)` | Class declares a method named `name` |
| `hasNoPublicMethods()` | No public methods |

### File content

| Matcher | Description |
|---------|-------------|
| `hasContent(pattern, {description})` | File source matches the regex `pattern` |
| `hasNoContent(pattern)` | File source does NOT match the regex `pattern` |

---

## Rule Severity

Every `testArch` / `testArchGroup` call accepts a `severity` parameter.

| Level | Failing? | Description |
|-------|----------|-------------|
| `RuleSeverity.info` | No | Informational notice |
| `RuleSeverity.warning` | No | Should be fixed but does not fail the build |
| `RuleSeverity.error` | Yes | Fails the analysis run (default) |
| `RuleSeverity.critical` | Yes | Fundamental architecture breach |

`info` and `warning` violations are shown in the report but do not affect the exit code.

---

## Presets

Presets are one-call functions that register one or more `testArch` rules using a common pattern. Use them as your `main()` body.

### `layeredArchitecture`

Declares all layers and generates "must not depend on" rules for every forbidden pair:

```dart
void main() => layeredArchitecture(
  layers: [
    (name: 'ui',     folder: 'lib/ui',     canAccess: ['lib/bloc', 'lib/domain']),
    (name: 'bloc',   folder: 'lib/bloc',   canAccess: ['lib/domain']),
    (name: 'domain', folder: 'lib/domain', canAccess: []),
  ],
);
```

### `layerCannotDependOn`

A layer must NOT import from any of the listed folders:

```dart
void main() => layerCannotDependOn(
  from: 'lib/domain',
  to: ['lib/data', 'lib/ui'],
);
```

### `layerCanOnlyDependOn`

A layer may ONLY import from the listed folders:

```dart
void main() => layerCanOnlyDependOn(
  layer: 'lib/domain',
  allowed: ['lib/domain', 'lib/shared'],
);
```

### `noCircularDependencies`

No file in the project may be part of a circular import chain:

```dart
void main() => noCircularDependencies();
```

### `namingClassConvention`

Classes in each folder must match a naming pattern. By default the expected suffix is derived from the capitalised folder basename (`lib/service` → must end with `Service`):

```dart
// Auto-suffix from folder name
void main() => namingClassConvention(
  folders: ['lib/service', 'lib/repository'],
);

// Explicit suffix
void main() => namingClassConvention(
  folders: ['lib/bloc'],
  suffix: 'Bloc',
);

// Prefix + suffix
void main() => namingClassConvention(
  folders: ['lib/domain/repository'],
  prefix: 'I',
  suffix: 'Repository',
);

// Raw regex
void main() => namingClassConvention(
  folders: ['lib/bloc'],
  namePattern: r'.*(Bloc|Cubit)$',
);
```

### `namingFileConvention`

Files in each folder must match a naming pattern. By default the expected suffix is derived from the folder basename in snake_case (`lib/services` → must end with `_services.dart`):

```dart
void main() => namingFileConvention(
  folders: ['lib/services', 'lib/repositories'],
);
```

### `mustBeAbstract`

All classes in the listed folders must be declared `abstract`:

```dart
void main() => mustBeAbstract(
  folders: ['lib/domain/repository'],
);
```

### `mustBeImmutable`

All instance fields of classes in the listed folders must be `final`:

```dart
void main() => mustBeImmutable(
  folders: ['lib/domain/entities'],
);
```

### `noPublicFields`

Classes in the listed folders must not expose public instance fields:

```dart
void main() => noPublicFields(
  folders: ['lib/domain'],
);
```

### `annotationMustHave`

Classes in the listed folders must carry the given annotation:

```dart
void main() => annotationMustHave(
  annotation: 'injectable',
  folders: ['lib/data/repository'],
);
```

### `annotationMustNotHave`

Classes in the listed folders must NOT carry the given annotation:

```dart
void main() => annotationMustNotHave(
  annotation: 'deprecated',
  folders: ['lib/ui'],
);
```

### `classSizeLimit`

Limits the number of methods and/or fields per class. When `folders` is empty, applies to all classes:

```dart
void main() => classSizeLimit(
  maxMethods: 20,
  maxFields: 15,
  folders: ['lib'],
);
```

### `noExternalPackage`

Classes in the listed folders must not import any of the listed packages:

```dart
void main() => noExternalPackage(
  packages: ['http', 'dio'],
  folders: ['lib/domain'],
);
```

### `noBannedCalls`

No file in the project may contain any of the listed regex patterns. Suitable for banning `print()`, `debugPrint()`, TODO comments, etc.:

```dart
void main() => noBannedCalls(
  patterns: [r'print\s*\(', r'debugPrint\s*\('],
  excludeFolders: ['test'],
);
```

### `mvvmGoRouterInjection`

Enforces the MVVM + GoRouter dependency injection pattern described in the [Flutter app architecture case study](https://docs.flutter.dev/app-architecture/case-study/dependency-injection):

```dart
void main() => mvvmGoRouterInjection(
  viewsFolder:      'lib/ui/views',
  viewModelsFolder: 'lib/ui/viewmodels',
  routerFolder:     'lib/router',
);
```

This preset enforces:
- `*ViewModel` classes extend `ChangeNotifier`
- ViewModels have no public fields (dependencies are private)
- ViewModels do not import `go_router`
- Views do not inject repositories/services via `context.read`
- The router file instantiates ViewModels
- The router passes dependencies via `context.read()`

---

## Common Preset Options

All presets accept these optional named parameters:

| Parameter | Default | Description |
|-----------|---------|-------------|
| `severity` | `RuleSeverity.error` | Violation severity level |
| `exceptions` | `[]` | File/folder path substrings to exempt |
| `projectRoot` | `'.'` | Root of the project to analyze |

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
│   └── dartunit.dart              # CLI entry point
├── lib/
│   ├── dartunit.dart              # Barrel export — public API
│   ├── analyzer/
│   │   ├── context/
│   │   │   └── analysis_context.dart    # Query facade over analysis results
│   │   ├── graph/
│   │   │   └── dependency_graph.dart    # Directed import graph + cycle detection
│   │   ├── models/
│   │   │   ├── analyzed_class.dart
│   │   │   ├── analyzed_field.dart
│   │   │   ├── analyzed_file.dart
│   │   │   └── analyzed_method.dart
│   │   ├── parsers/                     # Regex-based Dart source parsers
│   │   └── project_analyzer.dart        # Orchestrates analysis
│   ├── cli/
│   │   ├── commands/
│   │   │   ├── init_command.dart        # dartunit init
│   │   │   ├── analyze_command.dart     # dartunit analyze
│   │   │   ├── generate_command.dart    # dartunit generate
│   │   │   └── log_command.dart         # dartunit log
│   │   └── templates/                   # Architecture rule templates
│   ├── core/
│   │   ├── entities/                    # Rule, Violation, Predicate, Selector…
│   │   ├── enums/                       # RuleSeverity, ExitCode…
│   │   ├── predicates/                  # 30+ predicate implementations
│   │   └── selectors/                   # ClassSelector, FileSelector, LayerSelector
│   ├── engine/
│   │   ├── rule_engine.dart             # Runs all rules, collects violations
│   │   ├── rule_executor.dart           # Runs a single rule safely
│   │   ├── analysis_logger.dart         # Persists run history
│   │   └── test_result_parser.dart      # Parses dart test JSON output
│   ├── presets/                         # 15 preset functions
│   ├── reporter/
│   │   ├── console_reporter.dart        # Coloured console output
│   │   └── html_report_writer.dart      # HTML report generator
│   └── runner/
│       ├── arch_runner.dart             # testArch + testArchGroup
│       ├── arch_tester.dart             # ArchTester + ArchSubject
│       └── arch_matchers.dart           # All matcher functions
└── test/
```

### Data flow

```
test_arch/*_arch_test.dart
         |
         v
   dart test (JSON reporter)
         |
         v
  TestResultParser  -->  List<Violation>
         |
         v
  ConsoleReporter   -->  stdout
         |
         v
  HtmlReportWriter  -->  .dartunit/report.html
         |
         v
  AnalysisLogger    -->  .dartunit/log.ndjson
```

---

## Known Limitations

- The analyzer uses **regex-based parsing**, which may over-count methods whose names appear in string literals.
- Transitive dependency analysis traverses the full import graph and may be slow on very large projects.

---

## License

MIT
