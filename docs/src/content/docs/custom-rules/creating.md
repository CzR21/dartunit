---
title: Creating Custom Rules
description: How to write architecture rule files using testArch and testArchGroup.
sidebar:
  order: 1
---

Every architecture rule in DartUnit is a plain Dart test file in the `test_arch/` folder. Rules are written using `testArch` and `testArchGroup` — an API analogous to Flutter's `testWidgets`.

## Rule File Structure

A rule file must:

1. Be named `*_test_arch.dart`
2. Be placed in the `test_arch/` folder
3. Have a `main()` that uses `testArch()` or `testArchGroup()`

```dart title="test_arch/my_rule_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Domain entities must have all final fields', (selector) {
    expect(
      selector.classes(inFolder: 'lib/domain/entities'),
      hasAllFinalFields(),
    );
  });
}
```

## Generating a Rule File

Use the `generate` command to create a scaffolded file:

```bash
dart run dartunit generate domain_immutability
# Creates: test_arch/domain_immutability_test_arch.dart
```

## Running a Rule During Development

Run any rule file directly to test it:

```bash
dart test test_arch/domain_immutability_test_arch.dart
```

## Practical Examples

### Layer dependency rule

```dart title="test_arch/clean_architecture_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArchGroup('Domain isolation', () {
    testArch('Domain must not depend on the data layer', (selector) {
      expect(selector.classes(inFolder: 'lib/domain'), doesNotDependOn('lib/data'));
    });
    testArch('Domain must not depend on Flutter', (selector) {
      expect(selector.classes(inFolder: 'lib/domain'), doesNotDependOnPackage('flutter'));
    });
  }, severity: RuleSeverity.error);
}
```

### Use case convention rule

```dart title="test_arch/usecase_convention_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Use cases must be abstract and declare a call() method', (selector) {
    final useCases = selector.classes(
      inFolder: 'lib/domain/usecases',
      matchingPattern: r'.*UseCase$',
    );
    expect(useCases, isAbstractClass());
    expect(useCases, hasMethod('call'));
  });
}
```

### Naming convention rule

```dart title="test_arch/naming_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArchGroup('Naming conventions', () {
    testArch('Repository implementations must end with RepositoryImpl', (selector) {
      expect(
        selector.classes(inFolder: 'lib/data/repositories'),
        nameEndsWith('RepositoryImpl'),
      );
    });
    testArch('Service classes must end with Service', (selector) {
      expect(selector.classes(inFolder: 'lib/services'), nameEndsWith('Service'));
    });
  }, severity: RuleSeverity.warning);
}
```

### Repository abstraction rule

```dart title="test_arch/repository_contracts_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArchGroup('Repository contracts', () {
    testArch('Domain repository interfaces must be abstract', (selector) {
      expect(
        selector.classes(
          inFolder: 'lib/domain/repositories',
          matchingPattern: r'^(?!.*Impl).*Repository$',
        ),
        isAbstractClass(),
      );
    });
    testArch('Repository implementations must implement their interface', (selector) {
      expect(
        selector.classes(
          inFolder: 'lib/data/repositories',
          matchingPattern: r'.*RepositoryImpl$',
        ),
        implementsInterface('Repository'),
      );
    });
  });
}
```

### Class size rule

```dart title="test_arch/class_size_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArchGroup('Class size limits', () {
    testArch('Classes must not exceed 25 methods', (selector) {
      expect(
        selector.classes(
          inFolder: 'lib',
          exceptions: ['lib/generated'],
        ),
        hasMaxMethods(25),
      );
    });
    testArch('Classes must not exceed 15 fields', (selector) {
      expect(selector.classes(inFolder: 'lib'), hasMaxFields(15));
    });
  }, severity: RuleSeverity.warning);
}
```

### Ban debug calls rule

```dart title="test_arch/code_quality_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('No print() or debugPrint() in production code', (selector) {
    final files = selector.files(exceptions: ['test']);
    expect(files, hasNoContent(r'print\s*\('));
    expect(files, hasNoContent(r'debugPrint\s*\('));
  }, severity: RuleSeverity.warning);
}
```

## Using Presets in Rule Files

For common patterns, call a preset directly:

```dart title="test_arch/domain_quality_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  mustBeImmutable(folders: ['lib/domain/entities']);
  mustBeAbstract(folders: ['lib/domain/repositories']);
  noPublicFields(folders: ['lib/domain']);

  // Mix with custom rules
  testArch('Use cases must declare a call() method', (selector) {
    expect(selector.classes(inFolder: 'lib/domain/usecases'), hasMethod('call'));
  });
}
```

## Exceptions

Pass `exceptions` to `selector.classes()` or `selector.files()` to exempt specific paths:

```dart
testArch('Domain entities must be immutable', (selector) {
  expect(
    selector.classes(
      inFolder: 'lib/domain/entities',
      exceptions: ['lib/domain/entities/legacy_mutable_entity.dart'],
    ),
    hasAllFinalFields(),
  );
});
```

## Organizing Rule Files

A common pattern is to group related rules by concern:

```
test_arch/
├── layer_dependencies_test_arch.dart   ← all layer rules
├── naming_conventions_test_arch.dart   ← all naming rules
├── domain_contracts_test_arch.dart     ← domain layer rules
├── code_quality_test_arch.dart         ← code quality rules
└── metrics_test_arch.dart              ← class size rules
```

All files are discovered and run automatically by `dartunit analyze`.
