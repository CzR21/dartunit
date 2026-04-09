---
title: Writing Rules
description: How to write architecture rules using testArch and testArchGroup.
sidebar:
  order: 2
---

Rules in DartUnit are written using `testArch` and `testArchGroup`, a Flutter-inspired API analogous to `testWidgets`. Each rule file is a standard `dart test` file placed in the `test_arch/` folder.

## testArch

Registers a single architecture test.

```dart
void testArch(
  String description,
  FutureOr<void> Function(ArchTester arch) body, {
  String projectRoot = '.',
  RuleSeverity? severity,
})
```

The `body` receives an `ArchTester` used to build selectors, which are then passed to `expect()` with an arch matcher:

```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Domain must not depend on the data layer', (arch) {
    expect(arch.classes(folder: 'lib/domain'), doesNotDependOn('lib/data'));
  });
}
```

A single `testArch` can have multiple `expect` calls, each calls a different matcher on the same or different subjects:

```dart
testArch('Domain must not use external packages', (arch) {
  final domain = arch.classes(folder: 'lib/domain');
  expect(domain, doesNotDependOnPackage('flutter'));
  expect(domain, doesNotDependOnPackage('dio'));
  expect(domain, doesNotDependOnPackage('http'));
});
```

## testArchGroup

Groups related `testArch` calls, analyzing the project **once** and sharing the context across all tests in the group.

```dart
void testArchGroup(
  String groupName,
  void Function() body, {
  String projectRoot = '.',
  RuleSeverity severity = RuleSeverity.error,
})
```

```dart
void main() {
  testArchGroup('Domain layer isolation', () {
    testArch('Must not depend on data', (arch) {
      expect(arch.classes(folder: 'lib/domain'), doesNotDependOn('lib/data'));
    });
    testArch('Must not depend on presentation', (arch) {
      expect(arch.classes(folder: 'lib/domain'), doesNotDependOn('lib/presentation'));
    });
    testArch('Must be Flutter-agnostic', (arch) {
      expect(arch.classes(folder: 'lib/domain'), doesNotDependOnPackage('flutter'));
    });
  }, severity: RuleSeverity.error);
}
```

## Severity

Severity can be set at two levels:

- **Group level** — all `testArch` inside the group inherit it
- **Test level** — can define a severity, but will be overridden by the group

```dart
testArchGroup('Domain rules', () {
  testArch('Must not depend on data', (arch) { ... }); // inherits error
  testArch('Should have at most 3 methods per use case', (arch) {
    expect(arch.classes(namePattern: r'.*UseCase$'), hasMaxMethods(3));
  }, severity: RuleSeverity.warning); // ignored — group severity wins (error)
}, severity: RuleSeverity.error);
```

| Value | Effect |
|-------|--------|
| `RuleSeverity.info` | Noted in report. Does not fail the analysis. |
| `RuleSeverity.warning` | Reported with a warning. Does not fail the analysis. |
| `RuleSeverity.error` | **Fails** the analysis (exit code 1). |
| `RuleSeverity.critical` | **Fails** the analysis (exit code 1). Sorted first in output. |

:::caution
Only `error` and `critical` cause `dartunit analyze` to return exit code 1, which causes CI to fail.
:::

## ArchTester

The `ArchTester` is passed to every `testArch` body. It provides factory methods to build `ArchSubject` selectors.

### `arch.classes()`

Selects classes from the analyzed project.

```dart
arch.classes()                                        // all classes in lib/
arch.classes(folder: 'lib/domain')                    // classes in folder
arch.classes(namePattern: r'.*Repository$')           // classes by name regex
arch.classes(folder: 'lib/domain', namePattern: r'.*Entity$') // both
arch.classes(folder: 'lib/domain', exceptions: [
  'lib/domain/entities/legacy.dart',
])                                                    // with file exceptions
```

Use `suffix` or `prefix` as readable shortcuts for the most common name-filter patterns:

```dart
arch.classes(suffix: 'UseCase')               // .*UseCase$
arch.classes(prefix: 'Abstract')              // ^Abstract.*
arch.classes(suffix: 'Repository')            // .*Repository$
arch.classes(prefix: 'I', suffix: 'Service')  // ^I.*Service$
arch.classes(folder: 'lib/domain', suffix: 'Entity') // folder + suffix
```

`suffix`, `prefix`, and `namePattern` are mutually exclusive — use `namePattern` for full regex control when a simple suffix or prefix is not enough.

### `arch.files()`

Selects files (for content-based rules).

```dart
arch.files()                              // all files in lib/
arch.files(folder: 'lib/src')             // files in a specific folder
arch.files(exceptions: ['lib/gen'])       // exclude generated code
arch.files(suffix: '_datasource.dart')   // files ending with _datasource.dart
arch.files(prefix: 'base_')              // files starting with base_
```

### `arch.layer()`

Selects all classes in a named layer folder.

```dart
arch.layer('domain', folder: 'lib/domain')
```

## Exceptions

Pass `exceptions` to `arch.classes()` or `arch.files()` to exempt specific paths:

```dart
testArch('Domain entities must be immutable', (arch) {
  expect(
    arch.classes(
      folder: 'lib/domain/entities',
      exceptions: ['lib/domain/entities/legacy_entity.dart'],
    ),
    hasAllFinalFields(),
  );
});
```

## Practical Examples

### Layer dependency rule

```dart
void main() {
  testArchGroup('Dependency rules', () {
    testArch('Domain must not depend on the data layer', (arch) {
      expect(arch.classes(folder: 'lib/domain'), doesNotDependOn('lib/data'));
    });
    testArch('Presentation must not access data directly', (arch) {
      expect(arch.classes(folder: 'lib/presentation'), doesNotDependOn('lib/data'));
    });
  });
}
```

### Naming convention rule

Use `suffix` or `prefix` in `arch.classes()` to filter by name, and naming matchers to enforce conventions:

```dart
// Select classes ending with "Bloc" in the blocs folder
testArch('BLoC classes must not depend on data layer', (arch) {
  final blocs = arch.classes(folder: 'lib/bloc', suffix: 'Bloc');
  expect(blocs, doesNotDependOn('lib/data'));
});

// Enforce prefix on service interfaces
testArch('Service interfaces must start with I', (arch) {
  final services = arch.classes(folder: 'lib/domain/services');
  expect(services, nameStartsWith('I'));
});

// Combine prefix and suffix to select a naming convention precisely
testArch('Abstract repository names must follow IXxxRepository pattern', (arch) {
  final repos = arch.classes(
    folder: 'lib/domain/repositories',
    prefix: 'I',
    // suffix: 'Repository',  // uncomment to also filter the selection
  );
  expect(repos, isAbstractClass());
});
```

### Immutability rule

```dart
testArch('Domain entities must have all final fields', (arch) {
  expect(
    arch.classes(folder: 'lib/domain/entities', namePattern: r'.*Entity$'),
    hasAllFinalFields(),
  );
});
```

### Repository abstraction rule

```dart
testArchGroup('Repository contracts', () {
  testArch('Repository interfaces must be abstract', (arch) {
    expect(
      arch.classes(folder: 'lib/domain/repositories', namePattern: r'.*Repository$'),
      isAbstractClass(),
    );
  });
  testArch('Repository implementations must not be abstract', (arch) {
    expect(arch.classes(namePattern: r'.*RepositoryImpl$'), isConcreteClass());
  });
});
```

### Ban debug calls rule

```dart
testArch('No print() or debugPrint() in production code', (arch) {
  final files = arch.files(exceptions: ['test']);
  expect(files, hasNoContent(r'print\s*\('));
  expect(files, hasNoContent(r'debugPrint\s*\('));
}, severity: RuleSeverity.warning);
```

## Organizing Rule Files

A common pattern is to group related rules in one file using `testArchGroup`:

```
test_arch/
├── layer_dependencies_test_arch.dart   ← all layer rules
├── naming_conventions_test_arch.dart   ← all naming rules
├── domain_contracts_test_arch.dart     ← repository/entity contracts
├── code_quality_test_arch.dart         ← quality rules
└── metrics_test_arch.dart              ← class size rules
```

All files are discovered and run automatically by `dartunit analyze`.

## Running a Single Rule During Development

```bash
dart test test_arch/domain_contracts_test_arch.dart
```

When satisfied, the rule is automatically picked up by `dartunit analyze`:

```bash
dart run dartunit analyze
```
