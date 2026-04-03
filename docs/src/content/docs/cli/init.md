---
title: DartUnit init
description: Initialize the test_arch/ folder in your project with optional architecture templates.
sidebar:
  order: 2
---

The `init` command creates the `test_arch/` folder in your project and generates starter rule files. Run it once when setting up DartUnit for the first time.

## Usage

```bash
dart run dartunit init [options]
```

## Options

| Option | Default | Description |
|--------|---------|-------------|
| `--path <dir>` | `.` (current directory) | Path to the project root where `test_arch/` will be created |
| `--template <name>` | — | Generate pre-built rule files for a specific architecture pattern |

## Without a template

Running `init` without a template creates a single example rule file:

```bash
dart run dartunit init
```

Creates:

```
test_arch/
└── example_test_arch.dart
```

The `example_test_arch.dart` file is a working rule that you can use as a starting point:

```dart title="test_arch/example_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('Example: UI must not depend on data', (arch) {
    final ui = arch.classes(folder: 'lib/ui');
    expect(ui, doesNotDependOn('lib/data'));
  });
}
```

## With a template

The `--template` option generates a pre-built rule file tailored to a specific architecture. The generated file is immediately runnable and contains all rules inlined with folder constants at the top for easy customization.

```bash
dart run dartunit init --template <name>
```

### Available templates

#### `clean` — Clean Architecture

```bash
dart run dartunit init --template clean
```

Generates `test_arch/clean_test_arch.dart` with rules for a typical Flutter Clean Architecture:

- Domain layer isolated from data and presentation
- Presentation must not access data directly
- Repository interfaces abstract in domain, implementations in data
- Use cases single-responsibility and Flutter-agnostic
- Domain entities and data models immutable

Assumes:

```
lib/
├── presentation/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── data/
```

#### `bloc` — BLoC Pattern

```bash
dart run dartunit init --template bloc
```

Generates `test_arch/bloc_test_arch.dart` with rules for the BLoC pattern:

- BLoC/Cubit classes must not import from data layer
- Domain must not depend on presentation or BLoC layers
- State and Event classes must have all-final fields
- Coupling limits on BLoC/Cubit imports

Assumes:

```
lib/
├── presentation/
├── blocs/
├── domain/
└── data/
```

#### `mvc` — MVC Pattern

```bash
dart run dartunit init --template mvc
```

Generates `test_arch/mvc_test_arch.dart` with rules for Model-View-Controller:

- Model must not know about View or Controller
- View must communicate through Controller only
- Services must be UI-agnostic
- Model immutability and Controller cohesion limits

Assumes:

```
lib/
├── views/
├── controllers/
├── models/
└── services/
```

#### `mvvm` — MVVM Pattern

```bash
dart run dartunit init --template mvvm
```

Generates `test_arch/mvvm_test_arch.dart` with rules for Model-View-ViewModel:

- Views must not access data, models, or services directly
- ViewModels must be Flutter-agnostic and not access data layer
- Repository and Service layers must not reach into UI
- ViewModel cohesion limits (max methods and imports)

Assumes:

```
lib/
├── views/
├── viewmodels/
├── repositories/
├── models/
└── services/
```

### Customizing a template

Every generated file declares folder constants at the top. Edit them to match your project:

```dart title="test_arch/clean_test_arch.dart"
// Adjust these to match your project structure.
const _domain       = 'lib/domain';
const _data         = 'lib/data';
const _presentation = 'lib/presentation';

void main() {
  testArchGroup('Domain layer — isolated from all outer layers', () {
    ...
  });
  ...
}
```

## Initializing in another directory

Use `--path` to initialize a project that is not in the current directory:

```bash
dart run dartunit init --path /home/user/my_flutter_project
dart run dartunit init --path ../sibling_project
```

## Behavior

- If `test_arch/` already exists, `init` does not overwrite existing files.
- The generated rule files are immediately runnable — no manual edits required to run the first analysis.
- After `init`, run `dart run dartunit analyze` to verify everything works.

## Next Steps

After running `init`:

1. Review the generated rule files in `test_arch/`
2. Run `dart run dartunit analyze` to see the initial results
3. Customize the rules for your project's specific needs
4. Add more rules with `dart run dartunit generate <name>`
