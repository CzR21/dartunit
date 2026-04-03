---
title: Installation
description: How to add DartUnit to your Dart or Flutter project.
sidebar:
  order: 3
---

## Requirements

| Requirement | Minimum version |
|-------------|----------------|
| Dart SDK    | >= 3.0.0       |
| Flutter     | >= 3.10.0 (Flutter projects only) |

## Add as a dev dependency

DartUnit is an analysis tool and should always be a `dev_dependency`. It is never part of your production build.

### From pub.dev

Add DartUnit to your `pubspec.yaml`:

```yaml title="pubspec.yaml"
dev_dependencies:
  dartunit: ^1.0.0
```

Then fetch dependencies:

```bash
dart pub get
```

### From a local path

If you are working with a local copy of DartUnit (for example, during development or testing a fork):

```yaml title="pubspec.yaml"
dev_dependencies:
  dartunit:
    path: ../dartunit
```

```bash
dart pub get
```

## Verify the installation

```bash
dart run dartunit --version
# dartunit 1.0.0
```

## Initialize your project

After installing, run `init` to create the `arch_test/` folder:

```bash
dart run dartunit init
```

This creates:

```
my_project/
├── arch_test/
│   └── example_arch_test.dart   ← working example rule
├── lib/
│   └── ...
└── pubspec.yaml
```

See [DartUnit init](/cli/init) for all available options, including architecture templates.

## IDE integration

DartUnit is a command-line tool and works with any editor. To run analysis without leaving your IDE:

### VS Code

Add a task to `.vscode/tasks.json`:

```json title=".vscode/tasks.json"
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "dartunit: analyze",
      "type": "shell",
      "command": "dart run dartunit analyze",
      "group": "test",
      "presentation": {
        "reveal": "always",
        "panel": "dedicated"
      },
      "problemMatcher": []
    }
  ]
}
```

Run it with **Terminal → Run Task → dartunit: analyze**.

### Android Studio / IntelliJ

Create a **Run Configuration** of type **Shell Script** with the command `dart run dartunit analyze`. Assign a keyboard shortcut under **Settings → Keymap**.

## CI integration

DartUnit integrates naturally into any CI pipeline. The `analyze` command returns exit code `1` when there are `error` or `critical` violations, automatically failing the build.

```yaml title=".github/workflows/ci.yml"
- name: Check architecture rules
  run: dart run dartunit analyze --no-color
```

See [DartUnit analyze](/cli/analyze) for the full list of options and exit codes.
