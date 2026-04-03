---
title: Severities
description: The four severity levels in DartUnit and when to use each one.
sidebar:
  order: 4
---

DartUnit classifies every violation with one of four severity levels. Severity controls how violations are displayed, how they are sorted in reports, and whether they cause the analysis to fail.

## Severity Levels

| Value | Dart constant | Terminal color | Fails analysis (exit 1)? |
|-------|--------------|----------------|--------------------------|
| `info` | `RuleSeverity.info` | White | No |
| `warning` | `RuleSeverity.warning` | Yellow | No |
| `error` | `RuleSeverity.error` | Red | **Yes** |
| `critical` | `RuleSeverity.critical` | Magenta | **Yes** |

Only `error` and `critical` cause `dartunit analyze` to return exit code 1.

## When to Use Each Level

### RuleSeverity.info

Use `info` for observations you want to track without any impact on CI. Suitable for metrics that inform but do not enforce.

```dart
ArchitectureRule(
  description: 'High import count — possible coupling concern',
  severity: RuleSeverity.info,
  selector: ClassSelector(folder: 'lib'),
  predicate: MaxImportsPredicate(15),
)
```

**Appropriate use cases:**
- Coupling metrics for dashboard visibility
- Complexity indicators that inform refactoring decisions
- Rules in early evaluation that you are not yet confident enough to promote

### RuleSeverity.warning

Use `warning` for conventions that should be followed but where legitimate exceptions may exist. Warnings are visible in the report but do not block CI.

```dart
ArchitectureRule(
  description: 'Classes in lib/bloc must end with Bloc or Cubit',
  severity: RuleSeverity.warning,
  selector: ClassSelector(folder: 'lib/bloc'),
  predicate: OrPredicate([
    NameEndsWithPredicate('Bloc'),
    NameEndsWithPredicate('Cubit'),
  ]),
)
```

**Appropriate use cases:**
- Naming conventions
- Class size limits
- Banning `print()` in production (often acceptable during development)
- Rules being gradually introduced to an existing codebase

### RuleSeverity.error

Use `error` for architectural rules that must not be violated in production code. Errors fail the CI pipeline.

```dart
ArchitectureRule(
  description: 'Domain layer must not depend on data layer',
  severity: RuleSeverity.error,
  selector: LayerSelector('lib/domain'),
  predicate: NotPredicate(DependOnFolderPredicate('lib/data')),
)
```

**Appropriate use cases:**
- Prohibited layer dependencies
- Domain entity immutability
- Missing abstract interfaces
- External packages in restricted layers

### RuleSeverity.critical

Use `critical` for violations that represent serious risks to project integrity. Critical violations are sorted first in reports and have the strongest visual indicator.

```dart
ArchitectureRule(
  description: 'No circular dependencies',
  severity: RuleSeverity.critical,
  selector: ClassSelector(folder: 'lib'),
  predicate: NotPredicate(HasCircularDependencyPredicate()),
)
```

**Appropriate use cases:**
- Circular dependency chains
- Security-sensitive violations (e.g., hardcoded secrets)
- Violations that cause compilation or runtime failures
- Public API contract breaches

## Gradual Adoption Strategy

When adding DartUnit to an existing project with existing violations, use `warning` first to measure the scope without blocking CI, then promote to `error` after fixing the violations:

```dart
// Phase 1: discover the scope
ArchitectureRule(
  description: 'Domain must not depend on Flutter',
  severity: RuleSeverity.warning, // start here
  selector: LayerSelector('lib/domain'),
  predicate: NotPredicate(DependOnPackagePredicate('flutter')),
)

// Phase 2: enforce after violations are resolved
ArchitectureRule(
  description: 'Domain must not depend on Flutter',
  severity: RuleSeverity.error, // promote to error
  selector: LayerSelector('lib/domain'),
  predicate: NotPredicate(DependOnPackagePredicate('flutter')),
)
```

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
