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
  FutureOr<void> Function(ArchTester selector) body, {
  String projectRoot = '.',
  RuleSeverity? severity,
})
```

The `body` receives an `ArchTester` used to build selectors, which are then passed to `expect()` with an arch matcher:

```dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Domain must not depend on the data layer', (selector) {
    expect(selector.classes(inFolder: 'lib/domain'), doesNotDependOn('lib/data'));
  });
}
```

A single `testArch` can have multiple `expect` calls, each calls a different matcher on the same or different subjects:

```dart
testArch('Domain must not use external packages', (selector) {
  final domain = selector.classes(inFolder: 'lib/domain');
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
    testArch('Must not depend on data', (selector) {
      expect(selector.classes(inFolder: 'lib/domain'), doesNotDependOn('lib/data'));
    });
    testArch('Must not depend on presentation', (selector) {
      expect(selector.classes(inFolder: 'lib/domain'), doesNotDependOn('lib/presentation'));
    });
    testArch('Must be Flutter-agnostic', (selector) {
      expect(selector.classes(inFolder: 'lib/domain'), doesNotDependOnPackage('flutter'));
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
  testArch('Must not depend on data', (selector) { ... }); // inherits error
  testArch('Should have at most 3 methods per use case', (selector) {
    expect(selector.classes(matchingPattern: r'.*UseCase$'), hasMaxMethods(3));
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

### `selector.classes()`

Selects classes from the analyzed project.

```dart
selector.classes()                                              // all classes in lib/
selector.classes(inFolder: 'lib/domain')                       // classes in folder
selector.classes(matchingPattern: r'.*Repository$')            // classes by name regex
selector.classes(inFolder: 'lib/domain', matchingPattern: r'.*Entity$') // both
selector.classes(inFolder: 'lib/domain', exceptions: [
  'lib/domain/entities/legacy.dart',
])                                                             // with file exceptions
```

Use `hasSuffix` or `hasPrefix` as readable shortcuts for the most common name-filter patterns:

```dart
selector.classes(hasSuffix: 'UseCase')                        // .*UseCase$
selector.classes(hasPrefix: 'Abstract')                       // ^Abstract.*
selector.classes(hasSuffix: 'Repository')                     // .*Repository$
selector.classes(hasPrefix: 'I', hasSuffix: 'Service')        // ^I.*Service$
selector.classes(inFolder: 'lib/domain', hasSuffix: 'Entity') // folder + suffix
```

`hasSuffix`, `hasPrefix`, and `matchingPattern` are mutually exclusive — use `matchingPattern` for full regex control when a simple suffix or prefix is not enough.

### `selector.files()`

Selects files (for content-based rules).

```dart
selector.files()                               // all files in lib/
selector.files(inFolder: 'lib/src')            // files in a specific folder
selector.files(exceptions: ['lib/gen'])        // exclude generated code
selector.files(hasSuffix: '_datasource.dart') // files ending with _datasource.dart
selector.files(hasPrefix: 'base_')            // files starting with base_
```

### `selector.layer()`

Selects all classes in a named layer folder.

```dart
selector.layer('domain', inFolder: 'lib/domain')
```

## Exceptions

Pass `exceptions` to `selector.classes()` or `selector.files()` to exempt specific paths:

```dart
testArch('Domain entities must be immutable', (selector) {
  expect(
    selector.classes(
      inFolder: 'lib/domain/entities',
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
    testArch('Domain must not depend on the data layer', (selector) {
      expect(selector.classes(inFolder: 'lib/domain'), doesNotDependOn('lib/data'));
    });
    testArch('Presentation must not access data directly', (selector) {
      expect(selector.classes(inFolder: 'lib/presentation'), doesNotDependOn('lib/data'));
    });
  });
}
```

### Naming convention rule

Use `hasSuffix` or `hasPrefix` in `selector.classes()` to filter by name, and naming matchers to enforce conventions:

```dart
// Select classes ending with "Bloc" in the blocs folder
testArch('BLoC classes must not depend on data layer', (selector) {
  final blocs = selector.classes(inFolder: 'lib/bloc', hasSuffix: 'Bloc');
  expect(blocs, doesNotDependOn('lib/data'));
});

// Enforce prefix on service interfaces
testArch('Service interfaces must start with I', (selector) {
  final services = selector.classes(inFolder: 'lib/domain/services');
  expect(services, nameStartsWith('I'));
});

// Combine prefix and suffix to select a naming convention precisely
testArch('Abstract repository names must follow IXxxRepository pattern', (selector) {
  final repos = selector.classes(
    inFolder: 'lib/domain/repositories',
    hasPrefix: 'I',
    // hasSuffix: 'Repository',  // uncomment to also filter the selection
  );
  expect(repos, isAbstractClass());
});
```

### Immutability rule

```dart
testArch('Domain entities must have all final fields', (selector) {
  expect(
    selector.classes(inFolder: 'lib/domain/entities', matchingPattern: r'.*Entity$'),
    hasAllFinalFields(),
  );
});
```

### Repository abstraction rule

```dart
testArchGroup('Repository contracts', () {
  testArch('Repository interfaces must be abstract', (selector) {
    expect(
      selector.classes(inFolder: 'lib/domain/repositories', matchingPattern: r'.*Repository$'),
      isAbstractClass(),
    );
  });
  testArch('Repository implementations must not be abstract', (selector) {
    expect(selector.classes(matchingPattern: r'.*RepositoryImpl$'), isConcreteClass());
  });
});
```

### Ban debug calls rule

```dart
testArch('No print() or debugPrint() in production code', (selector) {
  final files = selector.files(exceptions: ['test']);
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
