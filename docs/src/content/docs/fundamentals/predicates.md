---
title: Predicates (Predicate)
description: How predicates define conditions that selected elements must satisfy in DartUnit.
sidebar:
  order: 4
---

A **Predicate** defines the condition that each selected element must satisfy. When a predicate returns `false` for an element, DartUnit records a `Violation`.

## Positive Condition Model

:::important
Predicates describe a condition that, when **true**, means the element **passes**. DartUnit reports a violation when the predicate **fails**.

To express "must not do X", wrap the predicate in `NotPredicate`:
:::

```dart
// "Classes in lib/domain must depend on lib/data"
// (predicate passes when dependency exists)
predicate: DependOnFolderPredicate('lib/data')

// "Classes in lib/domain must NOT depend on lib/data"
// (predicate passes when dependency does NOT exist)
predicate: NotPredicate(DependOnFolderPredicate('lib/data'))
```

This consistent model applies to all predicates — the predicate always describes the positive case.

## Categories

DartUnit provides 28 predicates organized into six categories:

- **Dependency** — what a class imports
- **Naming** — what the class name looks like
- **Type** — what kind of declaration the class is
- **Annotation** — what annotations the class has
- **Metrics** — how many methods, fields, or imports
- **Quality** — immutability, encapsulation, file content

## Dependency Predicates

| Class | Description |
|-------|-------------|
| `DependOnFolderPredicate(folder)` | Passes if the class imports from a path containing `folder` |
| `DependOnPackagePredicate(package)` | Passes if the class imports from the given package |
| `OnlyDependOnFoldersPredicate(folders)` | Passes if **all** imports are from the listed folders |
| `HasCircularDependencyPredicate()` | Passes if the class is part of a circular import chain |

## Naming Predicates

| Class | Description |
|-------|-------------|
| `NameStartsWithPredicate(prefix)` | Passes if the class name starts with `prefix` |
| `NameEndsWithPredicate(suffix)` | Passes if the class name ends with `suffix` |
| `NameContainsPredicate(substring)` | Passes if the class name contains `substring` |
| `NameMatchesPatternPredicate(pattern)` | Passes if the class name matches the regex `pattern` |

## Type Predicates

| Class | Description |
|-------|-------------|
| `IsAbstractPredicate()` | Passes if the class is declared `abstract` |
| `IsConcreteClassPredicate()` | Passes if the class is concrete (not abstract, mixin, enum, or extension) |
| `IsEnumPredicate()` | Passes if the declaration is an `enum` |
| `IsMixinPredicate()` | Passes if the declaration is a `mixin` |
| `IsExtensionPredicate()` | Passes if the declaration is an `extension` |
| `ExtendsPredicate(type)` | Passes if the class `extends` the given type |
| `ImplementsPredicate(type)` | Passes if the class `implements` the given type |
| `UsesMixinPredicate(mixin)` | Passes if the class uses the given mixin |

## Annotation Predicates

| Class | Description |
|-------|-------------|
| `AnnotatedWithPredicate(annotation)` | Passes if the class has the given annotation (without `@`) |
| `NotAnnotatedWithPredicate(annotation)` | Passes if the class does NOT have the given annotation |

## Metrics Predicates

| Class | Description |
|-------|-------------|
| `MaxMethodsPredicate(max)` | Passes if the method count is <= `max` |
| `MinMethodsPredicate(min)` | Passes if the method count is >= `min` |
| `MaxFieldsPredicate(max)` | Passes if the field count is <= `max` |
| `MinFieldsPredicate(min)` | Passes if the field count is >= `min` |
| `MaxImportsPredicate(max)` | Passes if the import count is <= `max` |

## Quality Predicates

| Class | Description |
|-------|-------------|
| `HasAllFinalFieldsPredicate()` | Passes if all instance fields are `final` or `const` |
| `HasNoPublicFieldsPredicate()` | Passes if the class has no public fields (no fields without `_`) |
| `HasNoPublicMethodsPredicate()` | Passes if the class has no public methods |
| `HasMethodPredicate(methodName)` | Passes if the class declares a method named `methodName` |
| `FileContentMatchesPredicate(pattern, {description})` | Passes if the file content matches the regex `pattern` (use with `FileSelector`) |

## Composite Predicates

Predicates can be composed to express complex logic.

### NotPredicate — Logical NOT

Passes when the inner predicate **fails**.

```dart
// "Must NOT depend on lib/data"
NotPredicate(DependOnFolderPredicate('lib/data'))

// "Must NOT be annotated with @deprecated"
NotPredicate(AnnotatedWithPredicate('deprecated'))
```

### AndPredicate — Logical AND

Passes when **all** inner predicates pass. Uses short-circuit evaluation.

```dart
// Must end with "Service" AND have no public fields AND not depend on lib/ui
AndPredicate([
  NameEndsWithPredicate('Service'),
  HasNoPublicFieldsPredicate(),
  NotPredicate(DependOnFolderPredicate('lib/ui')),
])
```

### OrPredicate — Logical OR

Passes when **any** inner predicate passes. Uses short-circuit evaluation.

```dart
// Must end with "Bloc" OR "Cubit"
OrPredicate([
  NameEndsWithPredicate('Bloc'),
  NameEndsWithPredicate('Cubit'),
])
```

### Nested composition

Composites can be nested to express arbitrarily complex conditions:

```dart
// (ends with "Bloc" OR ends with "Cubit") AND NOT depends on lib/ui
AndPredicate([
  OrPredicate([
    NameEndsWithPredicate('Bloc'),
    NameEndsWithPredicate('Cubit'),
  ]),
  NotPredicate(DependOnFolderPredicate('lib/ui')),
])
```

## Convenience Methods

Every predicate exposes three convenience methods that build composite predicates without explicitly instantiating the composite classes:

```dart
// These are equivalent:
NotPredicate(DependOnFolderPredicate('lib/data'))
DependOnFolderPredicate('lib/data').not()

// These are equivalent:
AndPredicate([IsAbstractPredicate(), HasNoPublicFieldsPredicate()])
IsAbstractPredicate().and(HasNoPublicFieldsPredicate())

// These are equivalent:
OrPredicate([NameEndsWithPredicate('Bloc'), NameEndsWithPredicate('Cubit')])
NameEndsWithPredicate('Bloc').or(NameEndsWithPredicate('Cubit'))
```

The convenience methods produce identical behavior to explicit instantiation and can be chained:

```dart
// Must be abstract AND not depend on lib/data AND not depend on flutter
IsAbstractPredicate()
  .and(DependOnFolderPredicate('lib/data').not())
  .and(DependOnPackagePredicate('flutter').not())
```

## Usage in Rule Files

```dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(
  args,
  ArchitectureRule(
    description: 'Use cases must be abstract and declare a call() method',
    severity: RuleSeverity.error,
    selector: ClassSelector(
      folder: 'lib/domain/usecases',
      namePattern: r'.*UseCase$',
    ),
    predicate: AndPredicate([
      IsAbstractPredicate(),
      HasMethodPredicate('call'),
    ]),
  ),
);
```

## Complete Reference

For the full description of all 28 predicates with parameters and examples, see [Predicates — Reference](/reference/predicates).
