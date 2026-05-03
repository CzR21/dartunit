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
  testArch('Example: UI must not depend on data', (selector) {
    final ui = selector.classes(inFolder: 'lib/ui');
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

Generates `test_arch/clean_test_arch.dart` for a typical Flutter Clean Architecture. Assumes:

```
lib/
├── presentation/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── data/
└── services/
```

**Rules generated:**

| Group | Rule | Severity |
|-------|------|----------|
| Domain layer isolation | Domain must not depend on `lib/data` | error |
| | Domain must not depend on `lib/presentation` | error |
| | Domain must be Flutter-agnostic (no `flutter` package) | error |
| | Domain must not use HTTP packages (`dio`, `http`) | error |
| Presentation layer | Presentation must not access `lib/data` directly | error |
| Data layer | Data layer must not depend on `lib/presentation` | error |
| Repository contract | Classes matching `.*Repository$` in domain must be abstract | error |
| | Classes matching `.*RepositoryImpl$` must be concrete | error |
| | Repository implementations must not access presentation | error |
| Use cases | Classes matching `.*UseCase$` must not depend on `lib/data` | error |
| | Use cases must not depend on `lib/presentation` | error |
| | Use cases must be Flutter-agnostic | error |
| | Use cases must have at most 3 methods | **warning** |
| Domain entities | Classes matching `.*Entity$` in domain must have all-final fields | error |
| | Domain entities must not expose public mutable fields | error |
| Repository isolation | Repositories must not depend on other repositories | error |
| Services layer | Services must not depend on `lib/presentation`, `lib/data`, or `lib/domain` | error |
| | Classes matching `.*Service$` must have all-final fields | error |
| Data models | Classes matching `.*Model$` in data must have all-final fields | **warning** |
| | Data models must not expose public mutable fields | **warning** |

#### `bloc` — BLoC Pattern

```bash
dart run dartunit init --template bloc
```

Generates `test_arch/bloc_test_arch.dart` for the BLoC pattern. Assumes:

```
lib/
├── presentation/
├── blocs/
├── domain/
└── data/
```

**Rules generated:**

| Group | Rule | Severity |
|-------|------|----------|
| Presentation layer | Presentation widgets must not import from `lib/data` | error |
| Data layer | Data must not depend on `lib/presentation` | error |
| | Data must not depend on `lib/blocs` | error |
| Repository pattern | Classes matching `.*Repository$` must be abstract | error |
| | Classes matching `.*RepositoryImpl$` must be concrete | error |
| | Repository implementations must not import from presentation | error |
| State & Event immutability | Classes matching `.*State$` must have all-final fields | error |
| | Classes matching `.*Event$` must have all-final fields | error |
| Data models | Classes matching `.*Model$` in data must have all-final fields | **warning** |
| BLoC isolation | Classes matching `.*Bloc$` must not depend on `lib/blocs` (no Bloc-to-Bloc) | **critical** |
| | Classes matching `.*Cubit$` must not depend on `lib/blocs` | **critical** |
| Coupling limits | Classes matching `.*Bloc$` must have at most 15 imports | **warning** |
| | Classes matching `.*Cubit$` must have at most 15 imports | **warning** |

#### `mvc` — MVC Pattern

```bash
dart run dartunit init --template mvc
```

Generates `test_arch/mvc_test_arch.dart` for Model-View-Controller. Assumes:

```
lib/
├── views/
├── controllers/
├── models/
└── services/
```

**Rules generated:**

| Group | Rule | Severity |
|-------|------|----------|
| Model layer | Models must not depend on `lib/controllers` | error |
| | Models must not depend on `lib/views` | error |
| | Models must be Flutter-agnostic (no `flutter` package) | **warning** |
| View layer | Views must not access `lib/models` directly | error |
| | Views must not access `lib/services` directly | error |
| Service layer | Classes matching `.*Service$` must not depend on `lib/views` | error |
| | Services must not depend on `lib/controllers` | error |
| | Services must not depend on `lib/models` | error |
| Model immutability | All classes in `lib/models` must have all-final fields | **warning** |
| | Models must not expose public mutable fields | **warning** |
| Controller cohesion | Classes matching `.*Controller$` must have at most 15 public methods | **warning** |
| | Controllers must have at most 12 imports | **warning** |
| Controller isolation | Controllers must not depend on other controllers | error |
| Services stateless | Classes matching `.*Service$` must have all-final fields | error |

#### `mvvm` — MVVM Pattern

```bash
dart run dartunit init --template mvvm
```

Generates `test_arch/mvvm_test_arch.dart` for Model-View-ViewModel. Assumes:

```
lib/
├── views/
├── viewmodels/
├── repositories/
├── models/
└── services/
└── data/
```

**Rules generated:**

| Group | Rule | Severity |
|-------|------|----------|
| View layer | Views must not access `lib/data` directly | error |
| | Views must not access `lib/models` directly | error |
| | Views must not depend on `lib/services` directly | error |
| ViewModel layer | Classes matching `.*ViewModel$` must not access `lib/data` | error |
| | ViewModels must not depend on other ViewModels (`lib/viewmodels`) | error |
| Repository layer | Classes matching `.*Repository$` must not depend on `lib/views` | error |
| | Repositories must not depend on `lib/viewmodels` | error |
| | Repositories must not depend on other repositories | error |
| Service layer | Classes matching `.*Service$` must not depend on `lib/views` | error |
| | Services must not depend on `lib/viewmodels` | error |
| | Services must not depend on `lib/repositories` | error |
| Repository contracts | Classes matching `.*Repository$` (non-Impl) in `lib/repositories` must be abstract | error |
| | Classes matching `.*RepositoryImpl$` must be concrete | error |
| ViewModel cohesion | ViewModels must have at most 10 public methods | **warning** |
| | ViewModels must have at most 15 imports | **warning** |
| Models | All classes in `lib/models` must have all-final fields | error |
| | Models must not expose public mutable fields | error |
| Services stateless | Classes matching `.*Service$` must have all-final fields | error |

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
