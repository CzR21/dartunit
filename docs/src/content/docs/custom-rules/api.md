---
title: API Reference — Rule Files
description: testArch, testArchGroup, ArchTester, and all arch matchers.
sidebar:
  order: 2
---

## testArch()

Registers a single architecture test. Analogous to `test()` in `package:test`.

```dart
void testArch(
  String description,
  FutureOr<void> Function(ArchTester arch) body, {
  String projectRoot = '.',
  RuleSeverity? severity,
})
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `description` | `String` | Test name shown in output |
| `body` | `Function(ArchTester)` | Test body; receives an `ArchTester` to build selectors |
| `projectRoot` | `String` | Project root to analyze (default: current directory) |
| `severity` | `RuleSeverity?` | Overrides group severity; defaults to `RuleSeverity.error` if outside a group |

```dart
testArch('Domain must not depend on data', (arch) {
  expect(arch.classes(folder: 'lib/domain'), doesNotDependOn('lib/data'));
});
```

---

## testArchGroup()

Groups related `testArch` calls, analyzing the project **once** and sharing context across all tests in the group.

```dart
void testArchGroup(
  String groupName,
  void Function() body, {
  String projectRoot = '.',
  RuleSeverity severity = RuleSeverity.error,
})
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `groupName` | `String` | Group label shown in output |
| `body` | `Function()` | Registers `testArch` calls |
| `projectRoot` | `String` | Project root to analyze |
| `severity` | `RuleSeverity` | Default severity for all tests in the group |

```dart
testArchGroup('Domain layer rules', () {
  testArch('Must not depend on data', (arch) { ... });
  testArch('Must be Flutter-agnostic', (arch) { ... });
}, severity: RuleSeverity.error);
```

---

## ArchTester

Passed to every `testArch` body. Provides factory methods that return `ArchSubject` objects for use with `expect()`.

### `arch.classes()`

```dart
ArchSubject classes({
  String? folder,
  String? namePattern,
  List<String> exceptions = const [],
})
```

Selects classes from the analyzed project.

```dart
arch.classes()                                              // all classes in lib/
arch.classes(folder: 'lib/domain')                         // by folder
arch.classes(namePattern: r'.*Repository$')                // by name regex
arch.classes(folder: 'lib/domain', namePattern: r'.*Entity$') // both
arch.classes(folder: 'lib/domain', exceptions: ['lib/domain/entities/legacy.dart'])
```

### `arch.files()`

```dart
ArchSubject files({
  String? folder,
  List<String> exceptions = const [],
})
```

Selects files for content-based rules.

```dart
arch.files()                        // all files in lib/
arch.files(folder: 'lib/src')
arch.files(exceptions: ['lib/gen']) // exclude generated code
```

### `arch.layer()`

```dart
ArchSubject layer(String name, {required String folder})
```

Selects all classes in a named layer folder.

```dart
arch.layer('domain', folder: 'lib/domain')
```

---

## Arch Matchers

All matchers are passed to `expect(subject, matcher)`.

### Dependency

```dart
doesNotDependOn(String folder)            // must NOT import from folder
dependsOn(String folder)                  // must import from folder
doesNotDependOnPackage(String package)    // must NOT import package
dependsOnPackage(String package)          // must import package
onlyDependsOnFolders(List<String> folders) // may only import from these folders
hasMaxImports(int max)                    // at most N imports
hasNoCircularDependency()                 // not in a circular import chain
hasCircularDependency()                   // is in a circular import chain
```

### Naming

```dart
nameEndsWith(String suffix)
nameStartsWith(String prefix)
nameContains(String substring)
nameMatchesPattern(String pattern)        // regex
```

### Annotation

```dart
hasAnnotation(String name)
doesNotHaveAnnotation(String name)
```

### Inheritance

```dart
extendsClass(String className)
implementsInterface(String interfaceName)
usesMixin(String mixinName)
```

### Type kind

```dart
isAbstractClass()
isConcreteClass()
isEnumType()
isMixinType()
isExtensionType()
```

### Metrics

```dart
hasMaxMethods(int max)
hasMinMethods(int min)
hasMaxFields(int max)
hasMinFields(int min)
```

### Immutability / encapsulation

```dart
hasAllFinalFields()
hasNoPublicFields()
hasMethod(String methodName)
hasNoPublicMethods()
```

### Content

```dart
hasContent(String pattern, {String description = ''})   // file must match regex
hasNoContent(String pattern)                             // file must NOT match regex
```

---

## RuleSeverity

```dart
RuleSeverity.info      // noted, does not fail
RuleSeverity.warning   // noted, does not fail
RuleSeverity.error     // fails analysis (exit code 1)
RuleSeverity.critical  // fails analysis (exit code 1), sorted first
```

---

## Preset functions

All presets are imported from `package:dartunit/dartunit.dart` and called directly in `main()`.

```dart
namingClassSuffix({required List<String> folders, String? suffix, String? prefix, String? namePattern, RuleSeverity severity, List<String> exceptions})
namingFileSuffix({required List<String> folders, String? suffix, String? prefix, String? namePattern, RuleSeverity severity, List<String> exceptions})
mustBeAbstract({required List<String> folders, RuleSeverity severity, List<String> exceptions})
mustBeImmutable({required List<String> folders, RuleSeverity severity, List<String> exceptions})
noPublicFields({required List<String> folders, RuleSeverity severity, List<String> exceptions})
noCircularDependencies({RuleSeverity severity})
layerCannotDependOn({required String from, required List<String> to, RuleSeverity severity, List<String> exceptions})
layerCanOnlyDependOn({required String layer, required List<String> allowed, RuleSeverity severity, List<String> exceptions})
layeredArchitecture({required List<({String name, String folder, List<String> canAccess})> layers, RuleSeverity severity, List<String> exceptions})
annotationMustHave({required String annotation, required List<String> folders, RuleSeverity severity, List<String> exceptions})
annotationMustNotHave({required String annotation, required List<String> folders, RuleSeverity severity, List<String> exceptions})
classSizeLimit({int? maxMethods, int? maxFields, List<String> folders, RuleSeverity severity, List<String> exceptions})
noExternalPackage({required List<String> packages, required List<String> folders, RuleSeverity severity, List<String> exceptions})
noBannedCalls({required List<String> patterns, List<String> excludeFolders, RuleSeverity severity})
```

---

## Complete Example

```dart title="test_arch/strict_service_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArchGroup('Service layer contracts', () {
    testArch('Services must end with Service', (arch) {
      expect(arch.classes(folder: 'lib/service'), nameEndsWith('Service'));
    });
    testArch('Services must be injectable', (arch) {
      expect(
        arch.classes(
          folder: 'lib/service',
          exceptions: ['lib/service/abstract_service.dart'],
        ),
        hasAnnotation('injectable'),
      );
    });
    testArch('Services must have no public fields', (arch) {
      expect(arch.classes(folder: 'lib/service'), hasNoPublicFields());
    });
    testArch('Services must not depend on UI', (arch) {
      expect(arch.classes(folder: 'lib/service'), doesNotDependOn('lib/ui'));
    });
  }, severity: RuleSeverity.error);
}
```
