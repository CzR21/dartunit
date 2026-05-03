---
title: Predicates
description: Conditions that selected elements must satisfy in DartUnit rules.
sidebar:
  order: 4
---

A **predicate** defines the condition that each selected element must satisfy. In `testArch` and `testArchGroup`, predicates are expressed through **arch matchers** — the functions you pass to `expect()`.

```dart
testArch('Domain must not depend on data', (selector) {
  expect(selector.classes(inFolder: 'lib/domain'), doesNotDependOn('lib/data'));
  //                                         ^^^^ arch matcher
});
```

When the matcher's condition is not met for an element, DartUnit records a `Violation` for it.

## Arch Matchers Reference

### Dependency

| Matcher | Passes when |
|---------|-------------|
| `doesNotDependOn(folder)` | Class does NOT import from `folder` |
| `dependsOn(folder)` | Class imports from `folder` |
| `doesNotDependOnTransitive(folder)` | Class does not transitively depend on `folder` |
| `dependsOnTransitive(folder)` | Class transitively depends on `folder` |
| `doesNotDependOnPackage(package)` | Class does NOT import `package` |
| `dependsOnPackage(package)` | Class imports `package` |
| `onlyDependsOnFolders(folders)` | Class only imports from the listed `folders` |
| `hasNoCircularDependency()` | Class is not part of a circular import chain |
| `hasCircularDependency()` | Class is part of a circular import chain |

### Naming

| Matcher | Passes when |
|---------|-------------|
| `nameEndsWith(suffix)` | Class name ends with `suffix` |
| `nameStartsWith(prefix)` | Class name starts with `prefix` |
| `nameContains(substring)` | Class name contains `substring` |
| `nameMatchesPattern(pattern)` | Class name matches the regex `pattern` |

### Type

| Matcher | Passes when |
|---------|-------------|
| `isAbstractClass()` | Class is declared `abstract` |
| `isConcreteClass()` | Class is concrete (not abstract, mixin, enum, or extension) |
| `isEnumType()` | Declaration is an `enum` |
| `isMixinType()` | Declaration is a `mixin` |
| `isExtensionType()` | Declaration is an `extension` |
| `extendsClass(className)` | Class `extends` the given type |
| `implementsInterface(interfaceName)` | Class `implements` the given interface |
| `usesMixin(mixinName)` | Class uses the given mixin via `with` |

### Annotation

| Matcher | Passes when |
|---------|-------------|
| `hasAnnotation(name)` | Class has `@name` annotation (without the `@`) |
| `doesNotHaveAnnotation(name)` | Class does NOT have `@name` annotation |

### Metrics

| Matcher | Passes when |
|---------|-------------|
| `hasMaxMethods(max)` | Method count ≤ `max` |
| `hasMinMethods(min)` | Method count ≥ `min` |
| `hasMaxFields(max)` | Field count ≤ `max` |
| `hasMinFields(min)` | Field count ≥ `min` |
| `hasMaxImports(max)` | Import count ≤ `max` |

### Quality

| Matcher | Passes when |
|---------|-------------|
| `hasAllFinalFields()` | All instance fields are `final` or `const` |
| `hasNoPublicFields()` | No public fields (all start with `_`) |
| `hasNoPublicMethods()` | No public methods (all start with `_`) |
| `hasMethod(methodName)` | Class declares a method named `methodName` |
| `hasContent(pattern)` | File content matches the regex `pattern` |
| `hasNoContent(pattern)` | File content does NOT match the regex `pattern` |

:::note
`hasContent` and `hasNoContent` are used with `selector.files()`, not `selector.classes()`.
:::

## Expressing Logic

### AND — multiple `expect()` calls

Multiple `expect()` calls inside one `testArch` are combined with AND: every condition must pass. This is the most common pattern.

```dart
testArch('BLoC classes must be clean', (selector) {
  final blocs = selector.classes(hasSuffix: 'Bloc');
  expect(blocs, doesNotDependOn('lib/data'));   // AND
  expect(blocs, hasAllFinalFields());           // AND
  expect(blocs, hasMaxImports(15));             // AND
});
```

### NOT — dedicated matchers

Every "must not" condition has a dedicated matcher with the `doesNot` or `hasNo` prefix. You do not need to negate anything manually:

```dart
expect(domain, doesNotDependOn('lib/data'));          // not + dependsOn
expect(domain, doesNotDependOnPackage('flutter'));     // not + dependsOnPackage
expect(classes, doesNotHaveAnnotation('deprecated')); // not + hasAnnotation
expect(classes, hasNoPublicFields());                 // not + public fields
expect(classes, hasNoContent(r'print\s*\('));         // not + content match
```

### OR — regex alternation

For OR conditions on names, use `nameMatchesPattern()` with a regex alternation, or include the OR condition directly in the `namePattern` of the selector:

```dart
// "Must end with 'Bloc' OR 'Cubit'"
testArch('State managers must be Bloc or Cubit', (selector) {
  final stateManagers = selector.classes(inFolder: 'lib/blocs');
  expect(stateManagers, nameMatchesPattern(r'.*(Bloc|Cubit)$'));
});
```

```dart
// Use namePattern in the selector to restrict which classes are evaluated
testArch('Bloc/Cubit must not access data directly', (selector) {
  final blocs = selector.classes(
    inFolder: 'lib/blocs',
    matchingPattern: r'.*(Bloc|Cubit)$',  // selects Blocs OR Cubits
  );
  expect(blocs, doesNotDependOn('lib/data'));
});
```

## Advanced: Predicate Composition

When building custom rules via the `CustomRule` interface, predicates can be composed directly using `AndPredicate`, `OrPredicate`, and `NotPredicate`, or through the convenience methods `.and()`, `.or()`, and `.not()` available on any predicate.

```dart
// Inside CustomRule.build():
Rule(
  selector: ClassSelector(folder: 'lib/domain'),
  predicate: AndPredicate([
    IsAbstractPredicate(),
    HasMethodPredicate('call'),
    DependOnFolderPredicate('lib/data').not(),
  ]),
  ...
)
```

**Convenience methods** on any predicate produce the same result:

```dart
// .not() — invert
DependOnFolderPredicate('lib/data').not()

// .and() — both must pass
IsAbstractPredicate().and(HasNoPublicFieldsPredicate())

// .or() — at least one must pass
NameEndsWithPredicate('Bloc').or(NameEndsWithPredicate('Cubit'))

// Chain as needed
IsAbstractPredicate()
  .and(DependOnFolderPredicate('lib/data').not())
  .and(DependOnPackagePredicate('flutter').not())
```

:::caution
Predicate composition is for building `CustomRule` implementations (low-level API). In regular `testArch` rules, use multiple `expect()` calls for AND, dedicated `doesNot`/`hasNo` matchers for NOT, and `nameMatchesPattern()` for OR.
:::

## Complete Reference

For the full matcher list with parameters and examples, see [Predicates — Reference](/reference/predicates).
