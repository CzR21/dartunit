---
title: Metrics Presets
description: The classSizeLimit for controlling the size of classes in your project.
sidebar:
  order: 4
---

## classSizeLimit

Limits the maximum number of methods and/or fields per class, helping to prevent God Classes from accumulating.

### Function signature

```dart
ArchitectureRule classSizeLimit({
  required List<String> folders,
  int? maxMethods,
  int? maxFields,
  RuleSeverity severity = RuleSeverity.warning,
  List<String> exceptions = const [],
})
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `folders` | `List<String>` | required | Folders to apply the limit to |
| `maxMethods` | `int?` | `null` | Maximum allowed methods per class. At least one of `maxMethods` or `maxFields` must be provided. |
| `maxFields` | `int?` | `null` | Maximum allowed fields per class. |
| `severity` | `RuleSeverity` | `RuleSeverity.warning` | Violation severity |
| `exceptions` | `List<String>` | `[]` | Exact class names to exempt |

:::note
At least one of `maxMethods` or `maxFields` must be specified.
:::

### Example — Global size limit

```dart title="test_arch/class_size_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(
  args,
  classSizeLimit(
    folders: ['lib'],
    maxMethods: 20,
    maxFields: 15,
    severity: RuleSeverity.warning,
    exceptions: ['GeneratedAdapter', 'MockUserRepository'],
  ),
);
```

### Example — Stricter limits for the domain layer

```dart title="test_arch/class_size_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) {
  // General limit across the whole project
  archTest(
    args,
    classSizeLimit(
      folders: ['lib'],
      maxMethods: 25,
      severity: RuleSeverity.warning,
    ),
  );

  // Stricter limit for domain entities (should be small and focused)
  archTest(
    args,
    classSizeLimit(
      folders: ['lib/domain/entities'],
      maxFields: 8,
      severity: RuleSeverity.warning,
    ),
  );
}
```

### Example — Only limit fields (no method limit)

```dart title="test_arch/class_size_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(
  args,
  classSizeLimit(
    folders: ['lib/domain'],
    maxFields: 10,
    severity: RuleSeverity.info,
  ),
);
```

### Violation output

```
WARNING | Classes in lib/ must not exceed 20 methods
        | lib/bloc/user_bloc.dart:1
        | Class "UserBloc" has 28 methods (max: 20)

WARNING | Classes in lib/ must not exceed 15 fields
        | lib/data/models/user_model.dart:1
        | Class "UserModel" has 18 fields (max: 15)
```

### Why limit class size?

Large classes (God Classes) are a sign that a class has taken on too many responsibilities, violating the Single Responsibility Principle. Enforcing size limits:

1. Encourages splitting responsibilities across smaller, focused classes
2. Promotes extracting logic into services, helpers, and use cases
3. Keeps classes testable — smaller classes have fewer dependencies and fewer code paths
4. Makes code review faster and easier

:::tip[Start with generous limits]
When introducing metrics rules to an existing project, start with high limits (e.g., 30 methods, 20 fields) to surface only the most egregious cases. Tighten the limits gradually after refactoring.
:::
