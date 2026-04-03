---
title: CLI Commands
description: Overview of all four commands in the DartUnit CLI.
sidebar:
  order: 1
---

DartUnit provides four commands for the complete architecture testing workflow.

## Commands

| Command | Description |
|---------|-------------|
| [`DartUnit init`](/cli/init) | Creates the `arch_test/` folder and generates starter rule files |
| [`DartUnit analyze`](/cli/analyze) | Discovers and runs all `*_arch_test.dart` files, reports violations |
| [`DartUnit generate <name>`](/cli/generate) | Scaffolds a new rule file ready to customize |
| [`DartUnit log`](/cli/log) | Shows the history of past analysis runs |

## Usage

```bash
dart run dartunit <command> [options]
```

## Quick Reference

```bash
# Initialize arch_test/ in the current project
dart run dartunit init

# Initialize with a pre-built architecture template
dart run dartunit init --template clean
dart run dartunit init --template bloc
dart run dartunit init --template mvc
dart run dartunit init --template mvvm

# Initialize in a different directory
dart run dartunit init --path /path/to/project

# Run all architecture rules
dart run dartunit analyze

# Run rules in a different directory
dart run dartunit analyze --path /path/to/project

# Run without terminal colors (for CI logs)
dart run dartunit analyze --no-color

# Generate a new rule file scaffold
dart run dartunit generate naming_conventions
dart run dartunit generate no_god_classes

# View history of the last 10 analysis runs
dart run dartunit log --last 10
```

## Running a Single Rule

Any rule file can be run directly during development without going through the `analyze` command:

```bash
dart run arch_test/my_rule_arch_test.dart
```

This is identical to how `analyze` runs it internally.

## Exit Codes

All commands follow the same exit code convention:

| Code | Meaning |
|------|---------|
| `0` | Success |
| `1` | Violations found (`error` or `critical` severity) |
| `2` | Configuration or runtime error |

See [Exit Codes](/reference/exit-codes) for details.
