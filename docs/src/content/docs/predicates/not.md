---
title: Combining matchers — NOT
description: How to express "must NOT satisfy a condition" in DartUnit rules. DartUnit provides dedicated doesNot/hasNo matchers for every common NOT condition.
sidebar:
  order: 31
---

## What it does

In DartUnit, **NOT conditions** are expressed through **dedicated matchers** that have the `doesNot` or `hasNo` prefix. There is no manual negation wrapper in the test API — each NOT condition has its own named matcher.

This makes rules more readable: `doesNotDependOn('lib/data')` is clearer than `not(dependsOn('lib/data'))`.

---

## Complete NOT matcher list

| Positive condition | NOT version |
|-------------------|-------------|
| `dependsOn(folder)` | `doesNotDependOn(folder)` |
| `dependsOnPackage(pkg)` | `doesNotDependOnPackage(pkg)` |
| `hasAnnotation(name)` | `doesNotHaveAnnotation(name)` |
| `hasCircularDependency()` | `hasNoCircularDependency()` |
| `hasContent(pattern)` | `hasNoContent(pattern)` |
| `hasPublicFields` (implicit) | `hasNoPublicFields()` |
| `hasPublicMethods` (implicit) | `hasNoPublicMethods()` |

For conditions without a dedicated NOT matcher (like `isAbstractClass`, `extendsClass`, `nameEndsWith`), you invert the logic by **adjusting the selector** — select only the classes that should satisfy the condition, not all classes in the folder.

---

## What problem it solves

"Must not" rules are the backbone of layer isolation in architecture testing:

- Domain must **not** import from data
- Domain must **not** depend on Flutter
- Production code must **not** contain `print()` calls
- Domain classes must **not** have serialization annotations

These "must not" conditions are so common that DartUnit provides dedicated matchers for all of them, so the rules read naturally in plain English.

---

## Examples

### doesNotDependOn — layer boundary enforcement

```dart title="test_arch/layer_boundaries_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArchGroup('Layer isolation rules', () {
    testArch('Domain must not import from data', (selector) {
      expect(selector.classes(inFolder: 'lib/domain'), doesNotDependOn('lib/data'));
    });

    testArch('Domain must not import from presentation', (selector) {
      expect(selector.classes(inFolder: 'lib/domain'), doesNotDependOn('lib/presentation'));
    });

    testArch('Data must not import from presentation', (selector) {
      expect(selector.classes(inFolder: 'lib/data'), doesNotDependOn('lib/presentation'));
    });
  }, severity: RuleSeverity.critical);
}
```

---

### doesNotDependOnPackage — package isolation

```dart title="test_arch/domain_no_packages_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArchGroup('Domain must be infrastructure-free', () {
    testArch('Domain must not use Flutter', (selector) {
      expect(selector.classes(inFolder: 'lib/domain'), doesNotDependOnPackage('flutter'));
    });

    testArch('Domain must not use Dio', (selector) {
      expect(selector.classes(inFolder: 'lib/domain'), doesNotDependOnPackage('dio'));
    });

    testArch('Domain must not use Hive', (selector) {
      expect(selector.classes(inFolder: 'lib/domain'), doesNotDependOnPackage('hive'));
    });
  }, severity: RuleSeverity.critical);
}
```

---

### doesNotHaveAnnotation — protecting layers from wrong annotations

```dart title="test_arch/domain_annotations_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Domain classes must not have persistence annotations', (selector) {
    final domain = selector.classes(inFolder: 'lib/domain');
    expect(domain, doesNotHaveAnnotation('JsonSerializable'));
    expect(domain, doesNotHaveAnnotation('HiveType'));
  });
}
```

---

### hasNoCircularDependency — ban cycles

```dart title="test_arch/no_cycles_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('No circular dependencies anywhere in the codebase', (selector) {
    expect(selector.classes(inFolder: 'lib'), hasNoCircularDependency());
  });
}
```

---

### hasNoContent — ban patterns in file content

```dart title="test_arch/code_quality_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArchGroup('Code quality — banned patterns', () {
    testArch('No print() calls in production', (selector) {
      expect(selector.files(inFolder: 'lib'), hasNoContent(r'print\s*\('));
    });

    testArch('No TODO comments in production', (selector) {
      expect(selector.files(inFolder: 'lib'), hasNoContent(r'//\s*TODO'));
    });

    testArch('No hardcoded URLs', (selector) {
      expect(selector.files(inFolder: 'lib'), hasNoContent(r'https?://[^\s\'"]+'));
    });
  }, severity: RuleSeverity.warning);
}
```

---

### hasNoPublicFields — encapsulation

```dart title="test_arch/encapsulation_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('BLoC classes must not expose public state fields', (selector) {
    expect(
      selector.classes(inFolder: 'lib/bloc'),
      hasNoPublicFields(),
    );
  });
}
```

---

## Related pages

- [AND conditions](/predicates/and/) — how to express "condition A AND condition B"
- [OR conditions](/predicates/or/) — how to express "condition A OR condition B"
- [`doesNotDependOn`](/predicates/depend-on-folder/) — layer boundary enforcement
- [`doesNotDependOnPackage`](/predicates/depend-on-package/) — package isolation
- [`hasNoCircularDependency`](/predicates/has-circular-dependency/) — ban circular imports
- [`hasNoContent`](/predicates/file-content-matches/) — ban patterns in file content
