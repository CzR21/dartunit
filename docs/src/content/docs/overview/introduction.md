---
title: Introduction to DartUnit
description: What DartUnit is and why architecture testing matters for Dart and Flutter projects.
sidebar:
  order: 1
---

**DartUnit** is an architecture testing tool for Dart and Flutter projects, inspired by [ArchUnit](https://www.archunit.org/) (Java) and [ArchUnitNET](https://archunitnet.readthedocs.io/) (.NET).

It lets you encode architectural decisions as **plain Dart test files** and run them automatically against your codebase — catching violations with exact file locations before they reach code review or production.

```
┌─────────────────────────────────────────────────────────────┐
│                        Your Project                         │
│                                                             │
│   lib/                        test_arch/                   │
│   ├── domain/           ───►  ├── domain_rules_test_arch   │
│   ├── data/             ───►  ├── naming_test_arch         │
│   └── presentation/    ───►  └── quality_test_arch        │
│                                                             │
│            dart run dartunit analyze                        │
│                         │                                   │
│                         ▼                                   │
│   ✓ Domain must not depend on data layer                   │
│   ✗ BLoC classes must end with Bloc                        │
│     lib/bloc/auth_manager.dart — "AuthManager" ≠ *Bloc     │
└─────────────────────────────────────────────────────────────┘
```

## The Core Problem

As projects grow, the architecture described in diagrams and documentation gradually diverges from the actual code. Layers that should be isolated start importing each other. Naming conventions drift. External packages appear in places they should never be.

These violations accumulate silently. Manual code reviews miss them. New team members learn from the violations instead of the rules. Six months later, your "Clean Architecture" project is a tightly coupled ball of dependencies.

**DartUnit solves this by turning architectural decisions into automated tests that run in CI.**

## How DartUnit Works

Architecture rules are written as ordinary Dart files in a `test_arch/` folder at the root of your project:

```dart title="test_arch/bloc_layer_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArchGroup('BLoC layer rules', () {
    testArch('BLoC classes must not depend on the view layer', (arch) {
      final blocSelector = arch.classes(namePattern: r'.*Bloc$');

      expect(blocSelector, doesNotDependOn('lib/view'));
    });

    testArch('BLoC classes must end with Bloc', (arch) {
      final blocSelector = arch.classes(folder: 'lib/bloc');

      expect(blocSelector, nameEndsWith('Bloc'));
    });
  }, severity: RuleSeverity.error);
}
```

Running `dart run dartunit analyze` discovers all `*_test_arch.dart` files, executes them via `dart test`, collects violations, and outputs results to the console alongside an HTML report.

## Key Features

### Rules as Dart code

No YAML, no configuration files. Rules are type-safe, navigable in your IDE, and version-controlled like any other code. Your architecture documentation lives in `test_arch/` and is always in sync with reality.

### `testArch` / `testArchGroup`

A Flutter-inspired API analogous to `testWidgets`. An `ArchTester` is passed as a callback parameter, providing `classes()`, `files()`, and `layer()` methods to build selectors. Violations are reported with the standard `expect()` + arch matchers.

### 30+ arch matchers

`doesNotDependOn`, `hasMaxMethods`, `isAbstractClass`, `hasAllFinalFields`, `nameEndsWith`, `implementsInterface`, `nameMatchesPattern`, and many more.

### 15 built-in presets

Callable functions that register complete rule sets for common patterns. One line replaces dozens of manual rules:

```dart title="test_arch/naming_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() => namingClassSuffix(
  folders: ['lib/bloc', 'lib/repository', 'lib/service'],
);
```

### 4 architecture templates

`dart run dartunit init --template clean/bloc/mvvm/mvc` generates a ready-to-run `*_test_arch.dart` file with all rules inlined and folder constants at the top for easy customization.

### HTML reports

Every analysis run produces a self-contained HTML report with a dark theme, summary cards, and a full violations table with severity badges. Zero external dependencies — works offline.

### CI-ready exit codes

Exit code `0` for pass, `1` for violations, `2` for errors. Integrates directly with GitHub Actions, GitLab CI, Bitbucket Pipelines, and any other CI system.

## Use Cases

**Layered architecture** — Ensure Presentation never imports from Data directly. Ensure Domain has no external dependencies. Automatically enforce the complete dependency graph with a single `layeredArchitecture()` call.

**Naming conventions** — Classes in `lib/bloc` must end with `Bloc`. Classes in `lib/domain/repositories` must be abstract. Files in `lib/data` must follow `*_datasource.dart` naming.

**Immutability** — Domain entities must have all `final` fields. No mutable state leaking into value objects.

**Size metrics** — No class may have more than 20 methods. Prevent God Classes before they accumulate.

**Code quality** — Ban `print()` and `debugPrint()` in production code. Ban deprecated APIs. Catch `async` anti-patterns.

**External dependencies** — The domain layer cannot import `flutter`, `dio`, `get_it`, or any other framework package.

## Philosophy

DartUnit is built on the principle that **undocumented architectural rules are ignored rules**. By encoding design decisions as executable tests, you ensure the entire team follows the same conventions — and violations become visible the moment they are introduced, not six months later during a refactoring effort.

:::tip[The architecture testing mindset]
Think of architecture tests as unit tests for your folder structure and dependency graph. Just as you test that a function returns the correct value, you test that a layer does not import from the wrong place.
:::

> "Architecture that is not tested is architecture that will degrade."

## Next Steps

- [Quick Start](/overview/quickstart) — set up DartUnit and write your first rule in 5 minutes
- [Installation](/overview/installation) — detailed installation options
- [How It Works](/fundamentals/how-it-works) — the full execution lifecycle
