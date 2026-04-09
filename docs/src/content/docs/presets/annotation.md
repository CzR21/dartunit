---
title: Annotation Presets
description: Presets for enforcing or banning annotations on classes in specific folders.
sidebar:
  order: 7
---

The annotation presets ensure that certain annotations are present or absent in classes in specific folders. They are useful for enforcing dependency injection registration, preventing framework leakage into the domain, and ensuring compliance with architectural conventions.

---

## annotationMustHave

Enforces that all classes in a folder have a specific annotation.

### Function signature

```dart
ArchitectureRule annotationMustHave({
  required String folder,
  required String annotation,
  RuleSeverity severity = RuleSeverity.warning,
  List<String> exceptions = const [],
})
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `folder` | `String` | required | The folder to check (substring match) |
| `annotation` | `String` | required | Annotation name **without** the `@` prefix |
| `severity` | `RuleSeverity` | `RuleSeverity.warning` | Violation severity |
| `exceptions` | `List<String>` | `[]` | Exact class names to exempt |

### Example — Services must be registered with the DI container

```dart title="test_arch/di_registration_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(
  args,
  annotationMustHave(
    folder: 'lib/service',
    annotation: 'injectable',
    severity: RuleSeverity.warning,
    exceptions: ['MockAnalyticsService', 'TestNotificationService'],
  ),
);
```

### Example — Data repositories must be registered as lazy singletons

```dart title="test_arch/repository_registration_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(
  args,
  annotationMustHave(
    folder: 'lib/data/repositories',
    annotation: 'LazySingleton',
    severity: RuleSeverity.error,
    exceptions: ['InMemoryUserRepository'],
  ),
);
```

### Example — All use case implementations must be injectable

```dart title="test_arch/usecase_di_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(
  args,
  annotationMustHave(
    folder: 'lib/domain/usecases',
    annotation: 'injectable',
    severity: RuleSeverity.warning,
  ),
);
```

### Violation output

```
WARNING | Classes in lib/service must be annotated with @injectable
        | lib/service/notification_service.dart:1
        | Class "NotificationService" is not annotated with @injectable
```

---

## annotationMustNotHave

Enforces that classes in a folder do **not** have a specific annotation.

### Function signature

```dart
ArchitectureRule annotationMustNotHave({
  required String folder,
  required String annotation,
  RuleSeverity severity = RuleSeverity.warning,
  List<String> exceptions = const [],
})
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `folder` | `String` | required | The folder to check (substring match) |
| `annotation` | `String` | required | Annotation name **without** the `@` prefix |
| `severity` | `RuleSeverity` | `RuleSeverity.warning` | Violation severity |
| `exceptions` | `List<String>` | `[]` | Exact class names to exempt |

### Example — Domain entities must not have JSON serialization annotations

```dart title="test_arch/domain_purity_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) {
  // Entities must not be serializable (JSON belongs in data layer)
  archTest(
    args,
    annotationMustNotHave(
      folder: 'lib/domain/entities',
      annotation: 'JsonSerializable',
      severity: RuleSeverity.error,
    ),
  );

  // Entities must not be stored in Hive (persistence belongs in data layer)
  archTest(
    args,
    annotationMustNotHave(
      folder: 'lib/domain/entities',
      annotation: 'HiveType',
      severity: RuleSeverity.error,
    ),
  );
}
```

### Example — Domain classes must not use injectable annotations

```dart title="test_arch/domain_annotations_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) {
  archTest(
    args,
    annotationMustNotHave(
      folder: 'lib/domain',
      annotation: 'injectable',
      severity: RuleSeverity.warning,
      exceptions: ['DomainService'],
    ),
  );

  archTest(
    args,
    annotationMustNotHave(
      folder: 'lib/domain',
      annotation: 'LazySingleton',
      severity: RuleSeverity.warning,
    ),
  );
}
```

### Violation output

```
ERROR | Classes in lib/domain/entities must not be annotated with @JsonSerializable
      | lib/domain/entities/user_entity.dart:1
      | Class "UserEntity" is annotated with @JsonSerializable (should be in data layer)
```

---

## Using annotation predicates directly

For more flexibility (e.g., combining with other selector filters), use `AnnotatedWithPredicate` and `NotAnnotatedWithPredicate` directly in a custom rule:

```dart title="test_arch/injectable_services_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(
  args,
  ArchitectureRule(
    description: 'Concrete services ending with Service must be injectable',
    severity: RuleSeverity.warning,
    selector: ClassSelector(
      folder: 'lib/service',
      namePattern: r'.*Service$',       // only classes ending in Service
      excludeNames: ['AbstractService'],
    ),
    predicate: AnnotatedWithPredicate('injectable'),
  ),
);
```

Use presets for the simple case where all classes in a folder share the same annotation requirement. Use direct predicates when you need to combine annotation checks with other filters.
