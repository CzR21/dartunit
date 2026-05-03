---
title: hasAnnotation / doesNotHaveAnnotation
description: Check whether classes carry a specific annotation. Used to enforce DI registration, serialization setup, or ban testing annotations from production code.
sidebar:
  order: 17
---

## What it does

`hasAnnotation(name)` passes when the class has a `@Name` annotation on its declaration.

`doesNotHaveAnnotation(name)` is the inverse — it passes when the class does **not** have that annotation.

Both matchers accept the annotation name **without** the `@` symbol. Pass `'injectable'`, not `'@injectable'`.

---

## What problem it solves

Annotations in Dart are how code generation tools, DI containers, and serialization libraries discover and configure classes. For this to work reliably, the right annotations must be applied to the right classes consistently:

- Every service class should be registered with the DI container via `@injectable` — a missing annotation means the service won't be available for injection.
- No domain class should have `@JsonSerializable` — serialization is a data-layer concern, and allowing it in the domain layer couples the domain to the persistence format.
- No production class should have `@visibleForTesting` — that annotation is meant for test infrastructure.

Without enforcement, these annotation rules are easy to forget or violate accidentally — especially as a codebase grows and new developers join.

---

## Syntax

```dart
// Class must have the annotation
expect(subject, hasAnnotation('annotationName'));

// Class must NOT have the annotation
expect(subject, doesNotHaveAnnotation('annotationName'));
```

---

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `name` | `String` | yes | The annotation name **without** the `@` symbol. Case-sensitive. The match is exact — `'injectable'` will not match `'lazySingleton'` even though both come from the same package. |

---

## When to use

Use `hasAnnotation()` to enforce that classes carry required annotations for code generation or DI:

- Services must be annotated with `@injectable` to be registered in the DI container
- Data models must have `@JsonSerializable` for code generation to work
- REST data sources must have `@RestApi` (for Retrofit-style clients)

Use `doesNotHaveAnnotation()` to protect layers from annotations that don't belong there:

- Domain classes must not have `@JsonSerializable` (serialization belongs in the data layer)
- Domain classes must not have `@HiveType` or `@HiveField` (persistence annotations)
- Production classes must not have `@visibleForTesting` (test infrastructure)
- Production code must not use `@deprecated` without intention

---

## Common use cases

**Enforcing required annotations:**
- Services in `lib/services/` must have `@injectable`
- Data models must have `@JsonSerializable`
- REST data source clients must have `@RestApi`

**Banning annotations from wrong layers:**
- Domain entities must not have `@JsonSerializable`
- Domain entities must not have `@HiveType`
- Production `lib/` code must not have `@visibleForTesting`
- `lib/` code must not have `@deprecated`

---

## Examples

### Services must be registered for DI

All service classes must be annotated with `@injectable` so the DI container knows about them. A missing annotation means the service is invisible to the DI framework:

```dart title="test_arch/services_injectable_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Service classes must be annotated with @injectable', (selector) {
    expect(
      selector.classes(inFolder: 'lib/services'),
      hasAnnotation('injectable'),
    );
  });
}
```

---

### Domain must not have serialization annotations

Serialization is a data-layer concern. Domain classes should be pure business objects with no knowledge of JSON, Hive, or any storage format:

```dart title="test_arch/domain_no_serialization_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArchGroup('Domain layer must be free from persistence annotations', () {
    testArch('Domain classes must not have @JsonSerializable', (selector) {
      expect(
        selector.classes(inFolder: 'lib/domain'),
        doesNotHaveAnnotation('JsonSerializable'),
      );
    });

    testArch('Domain classes must not have @HiveType', (selector) {
      expect(
        selector.classes(inFolder: 'lib/domain'),
        doesNotHaveAnnotation('HiveType'),
      );
    });
  }, severity: RuleSeverity.error);
}
```

---

### Ban testing annotations from production code

`@visibleForTesting` is a signal that code has been made accessible for test purposes. It should not appear in production code:

```dart title="test_arch/no_test_annotations_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArchGroup('No testing infrastructure in production code', () {
    testArch('Production classes must not have @visibleForTesting', (selector) {
      expect(
        selector.classes(inFolder: 'lib'),
        doesNotHaveAnnotation('visibleForTesting'),
      );
    });

    testArch('Production classes must not have @deprecated', (selector) {
      expect(
        selector.classes(inFolder: 'lib'),
        doesNotHaveAnnotation('deprecated'),
      );
    });
  }, severity: RuleSeverity.warning);
}
```

---

## Notes

- Do not include the `@` symbol in the annotation name: use `'injectable'`, not `'@injectable'`.
- The match is **exact**: `'injectable'` will not match `'lazySingleton'` or `'singleton'` even though they all come from the `injectable` package. Each annotation name must be specified separately.
- To require **one of several** acceptable annotations (OR condition), run multiple tests with different annotation names and combine with separate `testArch` calls, or restructure the rule using `namePattern` to select subsets.

---

## Related matchers

- [`doesNotDependOnPackage`](/predicates/depend-on-package/) — ban package imports from a layer
- [`hasAllFinalFields`](/predicates/has-all-final-fields/) — enforce immutability (alternative to `@immutable`)
- [`nameEndsWith`](/predicates/name-ends-with/) — combine naming with annotation checks
