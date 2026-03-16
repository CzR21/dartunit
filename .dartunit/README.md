# dartunit — Quick Reference

Architecture testing tool for Dart and Flutter projects.
Inspired by ArchUnit / ArchUnitNET.

Full documentation: https://pub.dev/packages/dartunit

---

## Quick start

1. `dartunit init` — creates this folder (already done).
2. Edit `dartunit.yaml` to define your rules.
3. `dartunit analyze` — run the analysis from the project root.

---

## dartunit.yaml — Rule format

```yaml
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

### Selector types

| type  | description                              |
|-------|------------------------------------------|
| class | Selects Dart classes matching criteria   |
| file  | Selects Dart source files                |
| layer | Selects all classes inside a layer folder|

### `where` options

| option        | description                         |
|---------------|-------------------------------------|
| folder        | Match subjects inside this folder   |
| namePattern   | Regex matched against the class name|
| annotatedWith | Class must carry this annotation    |
| extends       | Class must extend this type         |
| implements    | Class must implement this interface |

---

## Predicates

Predicates express **positive conditions** (pass when the condition IS met).
Wrap with `not` to require the opposite.

### Dependency

| type                | value         | description                                              |
|---------------------|---------------|----------------------------------------------------------|
| dependOnFolder      | String        | Passes when the class imports from the given folder      |
| dependOnPackage     | String        | Passes when the class imports `package:<name>/`          |
| onlyDependOnFolders | List<String>  | Passes when every import belongs to one of the folders   |
| maxImports          | int           | Passes when total imports <= N                           |
| hasCircularDependency | —           | Passes when the file is part of a circular import chain  |

### Naming

| type               | value  | description                              |
|--------------------|--------|------------------------------------------|
| nameEndsWith       | String | Class name ends with the given suffix    |
| nameStartsWith     | String | Class name starts with the given prefix  |
| nameContains       | String | Class name contains the given substring  |
| nameMatchesPattern | String | Class name matches the regex             |

### Annotations

| type             | value  | description                              |
|------------------|--------|------------------------------------------|
| annotatedWith    | String | Class carries the given annotation       |
| notAnnotatedWith | String | Class does NOT carry the given annotation|

### Inheritance

| type       | value  | description                        |
|------------|--------|------------------------------------|
| extends    | String | Class extends the given type       |
| implements | String | Class implements the given interface|
| usesMixin  | String | Class uses the given mixin         |

### Structural kind

| type        | description                                              |
|-------------|----------------------------------------------------------|
| isAbstract  | Class is declared `abstract`                             |
| isMixin     | Declared as a `mixin`                                    |
| isExtension | Declared as an `extension`                               |
| isEnum      | Declared as an `enum`                                    |
| isConcrete  | Concrete class: not abstract, mixin, enum, or extension  |

### Metrics

| type       | value | description                      |
|------------|-------|----------------------------------|
| maxMethods | int   | Class has at most N methods      |
| minMethods | int   | Class has at least N methods     |
| maxFields  | int   | Class has at most N fields       |
| minFields  | int   | Class has at least N fields      |

### Fields

| type              | description                                          |
|-------------------|------------------------------------------------------|
| hasAllFinalFields | All instance fields are `final` or `const`           |
| hasNoPublicFields | No public (non-`_`) instance fields exposed          |

### Methods

| type              | value  | description                              |
|-------------------|--------|------------------------------------------|
| hasMethod         | String | Class declares a method with this name   |
| hasNoPublicMethods| —      | No public (non-`_`) methods exposed      |

### File content

| type               | value  | description                                                |
|--------------------|--------|------------------------------------------------------------|
| fileContentMatches | String | Raw file source matches the regex. Use with `not` to ban   |
|                    | (regex)| patterns such as `print(`. Best used with `FileSelector`.  |

---

## Composite predicates

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

## Custom rules

Generate a scaffold:

```
dartunit generate no_repository_in_ui
```

Implement `CustomArchitectureRule`:

```dart
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

Register in `dartunit.yaml`:

```yaml
rules:
  - id: CUSTOM_NO_REPOSITORY_IN_UI
    type: custom
    implementation: no_repository_in_ui_rule.dart
    description: UI must not access repositories directly
```

---

## CLI reference

| Command                        | Description                              |
|--------------------------------|------------------------------------------|
| `dartunit init`                | Scaffold `.dartunit/` in the project     |
| `dartunit analyze`             | Run all rules against the source code    |
| `dartunit analyze --no-color`  | Disable coloured output                  |
| `dartunit generate <name>`     | Scaffold a new custom rule file          |

Exit codes: `0` = pass, `1` = violations found, `2` = configuration error.

---

## CI integration

```yaml
- name: Architecture check
  run: dart run dartunit analyze
```

Returns exit code `1` if any `error` or `critical` violations are found.
