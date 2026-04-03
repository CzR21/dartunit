---
title: Quality Presets
description: Presets for enforcing code quality rules — no public fields and no banned patterns.
sidebar:
  order: 5
---

## noPublicFieldsPreset

Enforces that classes in the specified folders have no public fields. A public field is any field not prefixed with an underscore (`_`).

### Function signature

```dart
ArchitectureRule noPublicFieldsPreset({
  required List<String> folders,
  RuleSeverity severity = RuleSeverity.warning,
  List<String> exceptions = const [],
})
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `folders` | `List<String>` | required | Folders where classes must have no public fields |
| `severity` | `RuleSeverity` | `RuleSeverity.warning` | Violation severity |
| `exceptions` | `List<String>` | `[]` | Exact class names to exempt |

### Why use it

Public fields break encapsulation. They allow any code to read and mutate state directly, bypassing validation or change notification logic. Using private fields with `final` or explicit getters enforces proper encapsulation.

### Example — BLoC and domain layers

```dart title="arch_test/encapsulation_arch_test.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(
  args,
  noPublicFieldsPreset(
    folders: ['lib/domain', 'lib/bloc'],
    severity: RuleSeverity.warning,
    exceptions: ['DataTransferObject'],
  ),
);
```

### Example — Strict enforcement on domain

```dart title="arch_test/domain_encapsulation_arch_test.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(
  args,
  noPublicFieldsPreset(
    folders: ['lib/domain'],
    severity: RuleSeverity.error,
  ),
);
```

### Violation output

```
WARNING | Classes in lib/bloc must not have public fields
        | lib/bloc/user_bloc.dart:1
        | Class "UserBloc" has public fields: repository, currentUser
```

### Correct vs incorrect

```dart
// Violation — public fields
class UserBloc extends Bloc<UserEvent, UserState> {
  UserRepository repository;   // public field
  User currentUser;            // public field
}

// Correct — private final fields
class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _repository;
  User? _currentUser;

  UserBloc(this._repository);
}
```

---

## noBannedCallsPreset

Bans specific text patterns from appearing in project files. Each pattern is a Dart regex applied to the full file content.

### Function signature

```dart
List<ArchitectureRule> noBannedCallsPreset({
  required List<String> patterns,
  List<String> excludeFolders = const [],
  RuleSeverity severity = RuleSeverity.warning,
})
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `patterns` | `List<String>` | required | List of Dart regexes to ban. Each pattern generates one rule. |
| `excludeFolders` | `List<String>` | `[]` | Folder path substrings to exclude from the check |
| `severity` | `RuleSeverity` | `RuleSeverity.warning` | Violation severity for all generated rules |

### Example — Ban debug output calls

```dart title="arch_test/no_debug_calls_arch_test.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) {
  final rules = noBannedCallsPreset(
    patterns: [
      r'print\s*\(',
      r'debugPrint\s*\(',
      r'developer\.log\s*\(',
    ],
    excludeFolders: ['test', 'integration_test'],
    severity: RuleSeverity.warning,
  );

  for (final rule in rules) {
    archTest(args, rule);
  }
}
```

### Example — Ban deprecated Flutter widgets

```dart title="arch_test/no_deprecated_widgets_arch_test.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) {
  final rules = noBannedCallsPreset(
    patterns: [
      r'WillPopScope',
      r'FlatButton',
      r'RaisedButton',
      r'Scaffold\.of\s*\(',
    ],
    severity: RuleSeverity.error,
  );

  for (final rule in rules) {
    archTest(args, rule);
  }
}
```

### Example — Ban hardcoded configuration strings

```dart title="arch_test/no_hardcoded_config_arch_test.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) {
  final rules = noBannedCallsPreset(
    patterns: [
      r'"http://',
      r'"https://api\.staging',
      r'localhost',
      r'127\.0\.0\.1',
    ],
    excludeFolders: ['test', 'lib/config/environments'],
    severity: RuleSeverity.error,
  );

  for (final rule in rules) {
    archTest(args, rule);
  }
}
```

### Example — Ban TODO/FIXME comments in production

```dart title="arch_test/no_todos_arch_test.dart"
import 'package:dartunit/dartunit.dart';

void main(List<String> args) {
  final rules = noBannedCallsPreset(
    patterns: [
      r'//\s*TODO',
      r'//\s*FIXME',
      r'//\s*HACK',
    ],
    excludeFolders: ['test'],
    severity: RuleSeverity.info,
  );

  for (final rule in rules) {
    archTest(args, rule);
  }
}
```

### Violation output

```
WARNING | No banned pattern: print\s*\(
        | lib/features/auth/login_page.dart
        | File contains banned pattern: print\s*\(

WARNING | No banned pattern: debugPrint\s*\(
        | lib/core/services/logger.dart
        | File contains banned pattern: debugPrint\s*\(
```

:::tip[Exclude test folders]
Debug calls in tests are completely normal. Always exclude `test` and `integration_test` from `noBannedCallsPreset` rules that target debug output.
:::

:::tip[Use single quotes for patterns in Dart strings]
Dart raw strings (`r'...'`) prevent double-escaping and make regex patterns more readable:
```dart
r'print\s*\('     // clear and readable
'print\\s*\\('    // same pattern, harder to read
```
:::
