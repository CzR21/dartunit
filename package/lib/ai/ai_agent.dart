/// Complete DartUnit API reference embedded in AI tool config files.
const String dartunitAgent = r'''
# DartUnit — Architecture Testing for Dart & Flutter

DartUnit enforces architecture rules in Dart/Flutter projects.
Rules run as standard `dart test` files inside `test_arch/`.

## Import

```dart
import 'package:dartunit/dartunit.dart';
import 'package:test/test.dart';
```

## Rule File Structure

Files live in `test_arch/` and are named `<rule_name>_arch_test.dart`.

```dart
// Single rule
void main() => testArch('UI must not access data layer', (selector) {
  final ui = selector.classes(inFolder: 'lib/ui');
  expect(ui, doesNotDependOn('lib/data'));
});

// Grouped rules — same severity, same topic
void main() => testArchGroup('BLoC layer integrity', () {
  testArch('BLoC must not depend on UI', (selector) {
    expect(selector.classes(inFolder: 'lib/bloc'), doesNotDependOn('lib/ui'));
  });
  testArch('BLoC must not depend on data', (selector) {
    expect(selector.classes(inFolder: 'lib/bloc'), doesNotDependOn('lib/data'));
  });
  testArch('BLoC classes must be named Bloc or Cubit', (selector) {
    expect(
      selector.classes(inFolder: 'lib/bloc'),
      nameMatchesPattern(r'.*(Bloc|Cubit)$'),
    );
  });
}, severity: RuleSeverity.error);
```

## Selectors

```dart
selector.classes()                            // all classes in the project
selector.classes(inFolder: 'lib/domain')      // recursive — includes subfolders
selector.classes(
  inFolder: 'lib/ui',
  exceptions: ['lib/ui/shared/base_screen.dart'],
)
selector.files()                              // all files
selector.files(inFolder: 'lib/data')
```

## Matchers

### Dependencies
```dart
doesNotDependOn('lib/data')                   // must not import from folder
dependsOn('lib/domain')                       // must import from folder
doesNotDependOnTransitive('lib/infra')        // no transitive imports either
dependsOnTransitive('lib/core')
doesNotDependOnPackage('dio')                 // must not use this pub package
dependsOnPackage('flutter_bloc')
onlyDependsOnFolders(['lib/domain', 'lib/core'])   // strict import whitelist
hasMaxImports(10)                             // at most N imports per file
hasNoCircularDependency()                     // no circular import chains
```

### Naming
```dart
nameEndsWith('Repository')
nameStartsWith('I')
nameContains('Service')
nameMatchesPattern(r'.*(Bloc|Cubit)$')        // full regex, anchored at end
```

### Annotations
```dart
hasAnnotation('injectable')
hasAnnotation('LazySingleton')
doesNotHaveAnnotation('deprecated')
```

### Inheritance
```dart
extendsClass('Equatable')
implementsInterface('Repository')
usesMixin('EquatableMixin')
```

### Structure
```dart
isAbstractClass()
isConcreteClass()
isEnumType()
isMixinType()
isExtensionType()
```

### Size
```dart
hasMaxMethods(10)
hasMinMethods(1)
hasMaxFields(5)
hasMinFields(1)
hasAllFinalFields()         // all instance fields are final
hasNoPublicFields()         // no public mutable fields
hasMethod('call')           // must declare a method named X
hasNoPublicMethods()
```

### Content (raw source matching)
```dart
hasContent(r'setState\(', description: 'uses setState')
hasNoContent(r'print\(')
hasNoContent(r'debugPrint\(')
hasNoContent(r'\.hardcoded')
```

## Presets

Presets are preferred over raw matchers when they cover the use case — they produce better error messages and handle edge cases.

### layeredArchitecture — declare all layers and their allowed access at once
```dart
void main() => layeredArchitecture(
  layers: [
    (name: 'ui',         folder: 'lib/ui',         canAccess: ['lib/bloc', 'lib/domain']),
    (name: 'bloc',       folder: 'lib/bloc',       canAccess: ['lib/domain']),
    (name: 'domain',     folder: 'lib/domain',     canAccess: []),
    (name: 'data',       folder: 'lib/data',       canAccess: ['lib/domain']),
    (name: 'core',       folder: 'lib/core',       canAccess: []),
  ],
);
```

### layerCannotDependOn — targeted forbidden dependency
```dart
void main() => layerCannotDependOn(
  from: 'lib/domain',
  to: ['lib/data', 'lib/ui', 'lib/bloc'],
);
```

### layerCanOnlyDependOn — strict whitelist
```dart
void main() => layerCanOnlyDependOn(
  layer: 'lib/domain',
  allowedLayers: ['lib/core'],
);
```

### namingClassConvention
```dart
// Auto-suffix from folder name: lib/service → must end with "Service"
void main() => namingClassConvention(
  folders: ['lib/service', 'lib/repository'],
);

// Explicit pattern — useful for multiple valid suffixes
void main() => namingClassConvention(
  folders: ['lib/bloc'],
  namePattern: r'.*(Bloc|Cubit)$',
);

// Interface convention: prefix I + suffix Repository
void main() => namingClassConvention(
  folders: ['lib/domain/repository'],
  prefix: 'I',
  suffix: 'Repository',
);
```

### mustBeAbstract
```dart
void main() => mustBeAbstract(
  folders: ['lib/domain/repository', 'lib/domain/usecase'],
);
```

### mustBeImmutable
```dart
void main() => mustBeImmutable(
  folders: ['lib/domain/entities', 'lib/domain/value_objects'],
);
```

### noPublicFields
```dart
void main() => noPublicFields(
  folders: ['lib/domain', 'lib/data'],
);
```

### noCircularDependencies
```dart
void main() => noCircularDependencies();
```

### annotationMustHave
```dart
void main() => annotationMustHave(
  folders: ['lib/data/repository'],
  annotation: 'injectable',
);
```

### annotationMustNotHave
```dart
void main() => annotationMustNotHave(
  folders: ['lib/domain'],
  annotation: 'deprecated',
);
```

### classSizeLimit
```dart
void main() => classSizeLimit(
  folders: ['lib/presentation', 'lib/ui'],
  maxMethods: 10,
  maxFields: 5,
);
```

### noExternalPackage — prevent a layer from touching a pub package
```dart
// Domain must be pure Dart — no infrastructure packages
void main() => noExternalPackage(
  folders: ['lib/domain'],
  packages: ['dio', 'http', 'sqflite', 'hive', 'shared_preferences'],
);
```

### noBannedCalls — ban raw source patterns
```dart
void main() => noBannedCalls(
  folders: ['lib/'],
  patterns: [r'print\(', r'debugPrint\(', r'\.hardcoded'],
);
```

## Severity

```dart
testArch('...', (s) { ... }, severity: RuleSeverity.error);    // default — fails test
testArch('...', (s) { ... }, severity: RuleSeverity.warning);  // logs, does not fail
testArch('...', (s) { ... }, severity: RuleSeverity.info);     // informational only
```

---

## Non-trivial rules — examples beyond the basics

These are the kinds of rules that reveal real architectural problems. Prefer these over generic dependency rules.

### Use cases must be abstract and single-method
```dart
void main() => testArchGroup('Use cases', () {
  testArch('Use cases must be abstract', (selector) {
    expect(selector.classes(inFolder: 'lib/domain/usecase'), isAbstractClass());
  });
  testArch('Use cases must declare a call method', (selector) {
    expect(selector.classes(inFolder: 'lib/domain/usecase'), hasMethod('call'));
  });
  testArch('Use cases must not exceed 2 methods', (selector) {
    expect(selector.classes(inFolder: 'lib/domain/usecase'), hasMaxMethods(2));
  });
});
```

### Entities must be pure and immutable
```dart
void main() => testArchGroup('Domain entities', () {
  testArch('Entities must have all-final fields', (selector) {
    expect(selector.classes(inFolder: 'lib/domain/entities'), hasAllFinalFields());
  });
  testArch('Entities must not import infrastructure packages', (selector) {
    expect(
      selector.classes(inFolder: 'lib/domain/entities'),
      doesNotDependOnPackage('dio'),
    );
  });
  testArch('Entities must not depend on any app layer', (selector) {
    expect(
      selector.classes(inFolder: 'lib/domain/entities'),
      onlyDependsOnFolders(['lib/core']),
    );
  });
});
```

### BLoC layer cannot bleed into other concerns
```dart
void main() => testArchGroup('BLoC isolation', () {
  testArch('Blocs must not import from UI', (selector) {
    expect(selector.classes(inFolder: 'lib/bloc'), doesNotDependOn('lib/ui'));
  });
  testArch('Blocs must not import from data layer', (selector) {
    expect(selector.classes(inFolder: 'lib/bloc'), doesNotDependOn('lib/data'));
  });
  testArch('Blocs must not use dio directly', (selector) {
    expect(selector.classes(inFolder: 'lib/bloc'), doesNotDependOnPackage('dio'));
  });
  testArch('Blocs must extend Bloc or Cubit', (selector) {
    expect(
      selector.classes(inFolder: 'lib/bloc'),
      nameMatchesPattern(r'.*(Bloc|Cubit)$'),
    );
  });
});
```

### Repository contract vs implementation separation
```dart
void main() => testArchGroup('Repository pattern', () {
  testArch('Domain repositories must be abstract', (selector) {
    expect(
      selector.classes(inFolder: 'lib/domain/repository'),
      isAbstractClass(),
    );
  });
  testArch('Domain repositories must follow interface naming', (selector) {
    expect(
      selector.classes(inFolder: 'lib/domain/repository'),
      nameStartsWith('I'),
    );
  });
  testArch('Data repositories must implement domain contracts', (selector) {
    // Implementations in data layer must be concrete
    expect(
      selector.classes(inFolder: 'lib/data/repository'),
      isConcreteClass(),
    );
  });
  testArch('Data repositories must be registered for injection', (selector) {
    expect(
      selector.classes(inFolder: 'lib/data/repository'),
      hasAnnotation('injectable'),
    );
  });
});
```

### Feature-first isolation (no cross-feature imports)
```dart
// Each feature in lib/features/<name>/ must not import from other features
void main() => testArchGroup('Feature isolation', () {
  testArch('Feature A must not import Feature B', (selector) {
    expect(
      selector.classes(inFolder: 'lib/features/auth'),
      doesNotDependOn('lib/features/profile'),
    );
  });
  testArch('Feature B must not import Feature A', (selector) {
    expect(
      selector.classes(inFolder: 'lib/features/profile'),
      doesNotDependOn('lib/features/auth'),
    );
  });
});
```

### Presentation layer hygiene
```dart
void main() => testArchGroup('Presentation hygiene', () {
  testArch('No print calls anywhere in lib/', (selector) {
    expect(selector.files(), hasNoContent(r'print\('));
  });
  testArch('Screens must not access repositories directly', (selector) {
    expect(
      selector.classes(inFolder: 'lib/ui'),
      doesNotDependOn('lib/data'),
    );
  });
  testArch('Screens must not exceed method complexity', (selector) {
    expect(
      selector.classes(inFolder: 'lib/ui'),
      hasMaxMethods(15),
    );
  });
});
```

### Dependency injection registration
```dart
void main() => testArchGroup('DI registration', () {
  testArch('All services must be annotated for injection', (selector) {
    expect(
      selector.classes(inFolder: 'lib/data/service'),
      hasAnnotation('injectable'),
    );
  });
  testArch('Domain layer must not use get_it directly', (selector) {
    expect(
      selector.classes(inFolder: 'lib/domain'),
      doesNotDependOnPackage('get_it'),
    );
  });
});
```

---

## Pattern Recognition Guide

### Detecting the project's architecture from `lib/` folder names

**BLoC + Clean Architecture**
- Folders: `bloc/`, `domain/`, `data/`, `ui/` or `presentation/`
- Non-obvious rules to add beyond layered deps:
  - BLoC naming convention (Bloc/Cubit suffix)
  - Domain repositories must be abstract
  - Data repos must be injectable
  - Domain must be free of infrastructure packages

**Riverpod**
- Folders: `providers/`, `domain/`, `data/`, `views/` or `screens/`
- Look for `@riverpod` annotation usage
- Non-obvious rules: providers must not access data layer directly, views must not hold business logic

**MVVM**
- Folders: `models/`, `views/`, `viewmodels/`
- Non-obvious rules: ViewModels must not import Flutter widgets, models must be immutable

**MVC**
- Folders: `models/`, `views/`, `controllers/`
- Non-obvious rules: controllers must not be abstract, views must not import controllers from other features

**Feature-first**
- Folders: `features/<name>/` with internal `bloc/`, `data/`, `domain/` subfolders
- Non-obvious rules: cross-feature imports must go through shared/, no direct feature-to-feature dependency

**GetX**
- Look for `GetxController` subclasses, `lib/controllers/` or `lib/bindings/`
- Non-obvious rules: controllers must extend GetxController, bindings must implement Bindings

---

## Choosing Between Presets and Raw Matchers

Use a **preset** when:
- The rule matches one of the named presets exactly
- You need better error messages (presets describe what was expected)
- The rule applies to multiple folders at once

Use **raw matchers** (`testArch` + `expect`) when:
- Combining multiple conditions in one group (`testArchGroup`)
- The rule is too specific for a preset (e.g., "use cases must be abstract AND have a `call` method")
- You need `exceptions` for specific files

## Generation Workflow

1. Scan `lib/` to discover all folders and their nesting
2. Read `pubspec.yaml` — identify packages (bloc, riverpod, get_it, injectable, dio, freezed, etc.)
3. List `test_arch/` to find existing rules and avoid duplicates
4. Identify the architecture pattern
5. Generate rules that go beyond the obvious — combine structural, naming, annotation, and dependency checks
6. Prefer `testArchGroup` to bundle related rules with a shared theme
7. Write each file to `test_arch/<name>_arch_test.dart`
''';
