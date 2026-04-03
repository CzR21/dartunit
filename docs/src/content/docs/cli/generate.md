---
title: DartUnit generate
description: Scaffold a new rule file with a pre-filled template ready to customize.
sidebar:
  order: 4
---

The `generate` command creates a new `*_test_arch.dart` file in the `test_arch/` folder with the required structure already in place, so you can focus on writing the rule logic rather than the boilerplate.

## Usage

```bash
dart run dartunit generate <name>
```

The `<name>` should be in `snake_case`. It becomes the filename and is used to derive the rule description.

## Examples

```bash
dart run dartunit generate naming_conventions
# Creates: test_arch/naming_conventions_test_arch.dart

dart run dartunit generate no_god_classes
# Creates: test_arch/no_god_classes_test_arch.dart

dart run dartunit generate domain_purity
# Creates: test_arch/domain_purity_test_arch.dart
```

## What is generated

Running `dart run dartunit generate no_god_classes` creates `test_arch/no_god_classes_test_arch.dart`:

```dart title="test_arch/no_god_classes_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('No God Classes', (arch) {
    expect(
      arch.classes(folder: 'lib'),
      hasMaxMethods(20), // TODO: configure your rule
    );
  });
}
```

The generated file is immediately runnable:

```bash
dart test test_arch/no_god_classes_test_arch.dart
```

## Customizing the generated file

Edit the generated file to implement your rule:

```dart title="test_arch/no_god_classes_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArchGroup('Class size limits', () {
    testArch('Classes must not exceed 25 methods', (arch) {
      expect(
        arch.classes(
          folder: 'lib',
          exceptions: ['lib/generated', 'lib/mocks'],
        ),
        hasMaxMethods(25),
      );
    }, severity: RuleSeverity.warning);

    testArch('Classes must not exceed 15 fields', (arch) {
      expect(arch.classes(folder: 'lib'), hasMaxFields(15));
    }, severity: RuleSeverity.warning);
  });
}
```

## Running the rule

During development, run the rule directly to check it:

```bash
dart test test_arch/no_god_classes_test_arch.dart
```

When satisfied, the rule is automatically picked up by `dartunit analyze`:

```bash
dart run dartunit analyze
```

## Tips

- Name the file after what the rule enforces, not what it forbids: `domain_purity` rather than `no_bad_imports`.
- Use `testArchGroup` to group related rules and share the analysis context — it avoids re-analyzing the project for each `testArch`.
- The `generate` command will not overwrite an existing file with the same name.
