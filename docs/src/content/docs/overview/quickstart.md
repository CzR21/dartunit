---
title: Quick Start
description: Set up DartUnit and run your first architecture rule in under 5 minutes.
sidebar:
  order: 2
---

This guide walks you through adding DartUnit to an existing Dart or Flutter project and running your first architectural rule check.

## Prerequisites

- Dart SDK >= 3.0

## 1. Add DartUnit to pubspec.yaml

In the `pubspec.yaml` file, add the DartUnit dependency:

```yaml title="pubspec.yaml"
dev_dependencies:
  dartunit: ^1.0.0
```

After adding the dependency, run the command below:

```bash
dart pub get
```

## 2. Initialize the test_arch/ folder

Run the `init` command at the root of your project:

```bash
dart run dartunit init
```

This creates the `test_arch/` folder with a working example rule file:

```
my_project/
├── test_arch/
│   └── example_test_arch.dart
├── lib/
│   └── ...
└── pubspec.yaml
```

For a Flutter project with a specific architecture pattern, use a template to get pre-built rules:

```bash
# Available templates: bloc, clean, mvc, mvvm
dart run dartunit init --template clean
```

## 3. Write your first rule

Open `test_arch/example_test_arch.dart` (or create a new file named `*_test_arch.dart`) and write your first rule.

Every rule file is a Dart `main()` that uses `testArch()`:

```dart title="test_arch/domain_layer_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Domain must not depend on the data layer', (arch) {
    expect(arch.classes(folder: 'lib/domain'), doesNotDependOn('lib/data'));
  });
}
```

To group related rules and share the analysis context across them, use `testArchGroup`:

```dart title="test_arch/domain_layer_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArchGroup('Domain layer rules', () {
    testArch('Must not depend on the data layer', (arch) {
      expect(arch.classes(folder: 'lib/domain'), doesNotDependOn('lib/data'));
    });
    testArch('Must be Flutter-agnostic', (arch) {
      expect(arch.classes(folder: 'lib/domain'), doesNotDependOnPackage('flutter'));
    });
  }, severity: RuleSeverity.error);
}
```

You can run a single rule file directly during development:

```bash
dart test test_arch/domain_layer_test_arch.dart
```

## 4. Run the full analysis

To run all rules in `test_arch/`:

```bash
dart run dartunit analyze
```

### Output — no violations

```
  ✓  Domain must not depend on the data layer
  ✓  Domain must be Flutter-agnostic

No architecture violations found.
```

### Output — with violations

```
  ✗  Domain must not depend on the data layer
       ✗ lib/domain/usecases/get_user_usecase.dart [error] — depends on lib/data

1 violation(s) found
```

An HTML report is also generated at `.dartunit/report.html` after every analysis run.

The command returns **exit code 1** if there are `error` or `critical` violations, automatically failing CI.

## 5. Add more rules

Use the `generate` command to scaffold additional rule files:

```bash
dart run dartunit generate naming_conventions
# Creates: test_arch/naming_conventions_test_arch.dart
```

Or use a preset for common patterns:

```dart title="test_arch/naming_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() => namingFolderSuffix(
  folders: ['lib/service', 'lib/repository'],
);
```

## 6. Integrate into CI

Add DartUnit to your pipeline:

```yaml title=".github/workflows/ci.yml"
- name: Check architecture rules
  run: dart run dartunit analyze --no-color
```

The `--no-color` flag produces clean output in CI logs where ANSI color codes are not rendered.

## Next Steps

- [How It Works](/fundamentals/how-it-works) — the full rule execution lifecycle
- [Creating Rules](/custom-rules/creating) — testArch, testArchGroup and matchers
- [Presets](/fundamentals/presets) — ready-made rule sets for common patterns
