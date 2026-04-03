---
title: Introduction to DartUnit
description: What DartUnit is and why architecture testing matters for Dart and Flutter projects.
sidebar:
  order: 1
---

**DartUnit** is an architecture testing tool for Dart and Flutter projects, inspired by [ArchUnit](https://www.archunit.org/) from the Java ecosystem.

It lets you encode architectural decisions as **plain Dart files** and run them automatically against your codebase, catching violations with exact file locations before they reach code review or production.

## The Core Problem

As projects grow, the architecture described in diagrams and documentation gradually diverges from the code. Layers that should be isolated start importing each other. Naming conventions drift. External packages appear in places they should never be.

These violations accumulate silently. Manual code reviews miss them. New team members learn from the violations instead of the rules.

DartUnit solves this by turning architectural decisions into **automated tests that run in CI**.

## How DartUnit Works

Rules are written as ordinary Dart files in a `test_arch/` folder at the root of your project:

```dart
// test_arch/bloc_layer_test_arch.dart
import 'package:dartunit/dartunit.dart';

void main() {
  testArchGroup('BLoC layer rules', () {
    testArch('BLoC classes must not depend on the view layer', (arch) {
      expect(
        arch.classes(namePattern: r'.*Bloc$'),
        doesNotDependOn('lib/view'),
      );
    });
  }, severity: RuleSeverity.error);
}
```

Running `dart run dartunit analyze` discovers all `*_test_arch.dart` files, executes them via `dart test`, collects violations, and outputs results to the console alongside an HTML report.

## Key Features

**Rules as Dart code** — No YAML, no configuration files. Rules are type-safe, navigable in your IDE, and version-controlled like any other code.

**`testArch` / `testArchGroup`** — A Flutter-inspired API analogous to `testWidgets`. An `ArchTester` is passed as a callback parameter, providing `classes()`, `files()`, and `layer()` methods to build selectors. Violations are reported with `expect()` and arch matchers.

**30+ arch matchers** — `doesNotDependOn`, `hasMaxMethods`, `isAbstractClass`, `hasAllFinalFields`, `nameEndsWith`, and more.

**14 presets** — Callable functions that register complete rule sets for common patterns like layered architecture, naming conventions, and immutability. Just call them directly in `main()`.

**4 architecture templates** — `init --template clean/bloc/mvvm/mvc` generates a ready-to-run `*_test_arch.dart` file with all rules inlined and folder constants at the top for easy customization.

**4 CLI commands** — `init`, `analyze`, `generate`, and `log` cover the full workflow from setup to ongoing monitoring.

**HTML reports** — Every analysis run produces a self-contained HTML report with a dark theme, summary cards, and a full violations table with severity badges.

**CI-ready exit codes** — Exit code `0` for pass, `1` for violations, `2` for errors. Integrates directly with GitHub Actions, GitLab CI, and any other pipeline.

## Use Cases

**Layered architecture** — Ensure Presentation never imports from Data directly. Ensure Domain has no external dependencies.

**Naming conventions** — Classes in `lib/bloc` must end with `Bloc` or `Cubit`. Classes in `lib/domain/repositories` must be abstract.

**Immutability** — Domain entities must have all `final` fields. No mutable state in value objects.

**Size metrics** — No class may have more than 20 methods. Prevents God Classes from accumulating.

**Code quality** — Ban `print()` and `debugPrint()` in production code. Ban deprecated Flutter widgets.

**External dependencies** — The domain layer cannot import `flutter`, `dio`, `get_it`, or any other framework package.

## Philosophy

DartUnit is built on the principle that **undocumented architectural rules are ignored rules**. By encoding design decisions as executable tests, you ensure the entire team follows the same conventions — and violations become visible the moment they are introduced.

> "Architecture that is not tested is architecture that will degrade."

## Next Steps

- [Quick Start](/overview/quickstart) — set up DartUnit and write your first rule in 5 minutes
- [Installation](/overview/installation) — detailed installation options
- [How It Works](/fundamentals/how-it-works) — the full execution lifecycle
