---
title: Severities
description: The four severity levels in DartUnit and when to use each one.
sidebar:
  order: 4
---

DartUnit classifies every violation with one of four severity levels. Severity controls how violations are displayed, how they are sorted in reports, and whether they cause the analysis to fail.

## Severity Levels

| Value | Dart constant | Terminal color | Fails CI (exit 1)? |
|-------|--------------|----------------|---------------------|
| `info` | `RuleSeverity.info` | White | No |
| `warning` | `RuleSeverity.warning` | Yellow | No |
| `error` | `RuleSeverity.error` | Red | **Yes** |
| `critical` | `RuleSeverity.critical` | Magenta | **Yes** |

Only `error` and `critical` cause `dartunit analyze` to return exit code 1.

## Setting severity

Severity can be set at three levels, each overriding the one above it:

### 1. On a testArch call

```dart
testArch('Domain must not depend on data', (arch) {
  expect(arch.classes(folder: 'lib/domain'), doesNotDependOn('lib/data'));
}, severity: RuleSeverity.error);
```

### 2. On a testArchGroup (inherited by all testArch inside)

```dart
testArchGroup('Domain layer rules', () {
  testArch('Must not depend on data', (arch) { ... });       // inherits error
  testArch('Must not depend on presentation', (arch) { ... }); // inherits error

  testArch('Should have at most 5 methods', (arch) {
    expect(arch.classes(folder: 'lib/domain'), hasMaxMethods(5));
  }, severity: RuleSeverity.warning); // overrides to warning
}, severity: RuleSeverity.error);
```

### 3. On a preset call

```dart
namingClassSuffix(
  folders: ['lib/bloc'],
  severity: RuleSeverity.warning,
);

layerCannotDependOn(
  from: 'lib/domain',
  to: ['flutter', 'dio'],
  severity: RuleSeverity.critical,
);
```

## When to Use Each Level

### RuleSeverity.info

Use `info` for observations you want to track without any impact on CI. Suitable for metrics that inform but do not enforce.

```dart
testArch('Import count — coupling indicator', (arch) {
  expect(
    arch.classes(folder: 'lib'),
    hasMaxImports(15),
  );
}, severity: RuleSeverity.info);
```

**Appropriate use cases:**
- Coupling metrics for dashboard visibility
- Complexity indicators that inform refactoring decisions
- Rules in early evaluation that you are not yet confident enough to promote to warning

### RuleSeverity.warning

Use `warning` for conventions that should be followed but where legitimate exceptions may exist. Warnings are visible in the report but do not block CI.

```dart
testArchGroup('Naming conventions', () {
  testArch('BLoC classes must end with Bloc or Cubit', (arch) {
    expect(
      arch.classes(folder: 'lib/bloc'),
      nameMatchesPattern(r'.*(Bloc|Cubit)$'),
    );
  });
}, severity: RuleSeverity.warning);
```

**Appropriate use cases:**
- Naming conventions
- Class size limits
- Banning `print()` in production (often acceptable during development)
- Rules being gradually introduced to an existing codebase

### RuleSeverity.error

Use `error` for architectural rules that must not be violated in production code. Errors fail the CI pipeline.

```dart
testArchGroup('Domain isolation', () {
  testArch('Domain must not depend on data layer', (arch) {
    expect(arch.classes(folder: 'lib/domain'), doesNotDependOn('lib/data'));
  });
  testArch('Domain must not depend on Flutter', (arch) {
    expect(arch.classes(folder: 'lib/domain'), doesNotDependOnPackage('flutter'));
  });
}, severity: RuleSeverity.error);
```

**Appropriate use cases:**
- Prohibited layer dependencies
- Domain entity immutability
- Missing abstract interfaces in contract folders
- External packages in restricted layers

### RuleSeverity.critical

Use `critical` for violations that represent serious risks to project integrity. Critical violations are sorted first in reports and have the strongest visual indicator.

```dart
// Circular dependencies are critical — they can cause runtime failures
noCircularDependencies(severity: RuleSeverity.critical);

// Domain depending on Flutter is critical — it destroys testability
layerCannotDependOn(
  from: 'lib/domain',
  to: ['flutter'],
  severity: RuleSeverity.critical,
);
```

**Appropriate use cases:**
- Circular dependency chains
- Security-sensitive violations (e.g., hardcoded secrets in source files)
- Violations that cause compilation or runtime failures
- Public API contract breaches

## Gradual Adoption Strategy

When adding DartUnit to an existing project with existing violations, use `warning` first to measure the scope without blocking CI, then promote to `error` after fixing the violations:

```dart title="test_arch/domain_isolation_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() => layerCannotDependOn(
  from: 'lib/domain',
  to: ['lib/data', 'lib/presentation', 'flutter'],
  // Phase 1: discover the scope without breaking CI
  severity: RuleSeverity.warning,
  // Phase 2: after fixing all violations, promote:
  // severity: RuleSeverity.error,
);
```

Run `dart run dartunit analyze`, read the HTML report carefully, and fix violations systematically. Once the violation count reaches zero, change `severity` to `RuleSeverity.error` and commit. From that point on, CI prevents new violations from entering the codebase.

## Report Summary Line

The `analyze` output always ends with a summary that counts violations per severity:

```
5 violations found (1 critical, 2 errors, 1 warning, 1 info)
```

If only `warning` and `info` violations are present:

```
3 violations found (2 warnings, 1 info)
Exit code: 0
```

## Sort Order in Reports

Violations are always sorted from most severe to least severe in both console output and the HTML report:

```
┌──────────┬─────────────────────────────────────┬──────────────────────────────────┬──────┐
│ Severity │ Rule                                │ File                             │ Line │
├──────────┼─────────────────────────────────────┼──────────────────────────────────┼──────┤
│ CRITICAL │ No circular dependencies            │ lib/core/services/auth.dart      │   1  │
│ ERROR    │ Domain must not depend on data      │ lib/domain/usecases/get_user.dart│   3  │
│ WARNING  │ Classes in lib/bloc must end w/ Bloc│ lib/bloc/auth_manager.dart       │   1  │
│ INFO     │ High import count                   │ lib/core/utils/helpers.dart      │   1  │
└──────────┴─────────────────────────────────────┴──────────────────────────────────┴──────┘
```
