---
title: doesNotHaveAnnotation
description: Passes when a class does not carry the specified annotation. See hasAnnotation / doesNotHaveAnnotation for the complete reference.
sidebar:
  order: 18
---

`doesNotHaveAnnotation` is documented together with `hasAnnotation` on the [hasAnnotation / doesNotHaveAnnotation](/predicates/annotated-with/) page, which covers both matchers in full detail including syntax, parameters, use cases, and examples.

---

## Quick reference

```dart
// Passes when the class does NOT have @AnnotationName
expect(subject, doesNotHaveAnnotation('annotationName'));
```

Common uses:

```dart
// Domain must not have serialization annotations
expect(selector.classes(inFolder: 'lib/domain'), doesNotHaveAnnotation('JsonSerializable'));
expect(selector.classes(inFolder: 'lib/domain'), doesNotHaveAnnotation('HiveType'));

// Production code must not have test infrastructure annotations
expect(selector.classes(inFolder: 'lib'), doesNotHaveAnnotation('visibleForTesting'));
expect(selector.classes(inFolder: 'lib'), doesNotHaveAnnotation('deprecated'));
```

---

[View full documentation →](/predicates/annotated-with/)
