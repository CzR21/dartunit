---
title: CLI Commands
description: Overview of all five commands in the DartUnit CLI.
sidebar:
  order: 1
---

DartUnit provides five CLI commands for the complete architecture testing workflow.

```
dart run dartunit <command> [options]
```

## Commands

| Command | Description |
|---------|-------------|
| [`dartunit init`](/cli/init) | Creates the `test_arch/` folder and generates starter rule files |
| [`dartunit analyze`](/cli/analyze) | Discovers and runs all `*_arch_test.dart` files, reports violations |
| [`dartunit generate <name>`](/cli/generate) | Scaffolds a new rule file ready to customize |
| [`dartunit log`](/cli/log) | Shows the history of past analysis runs |
| [`dartunit ai`](/cli/ai) | Configures AI tool integration for rule generation and violation analysis |

## Quick Reference

```bash
# ── Setup ──────────────────────────────────────────────────
# Initialize test_arch/ in the current project
dart run dartunit init

# Initialize with a pre-built architecture template
dart run dartunit init --template clean
dart run dartunit init --template bloc
dart run dartunit init --template mvc
dart run dartunit init --template mvvm

# Initialize in a different directory
dart run dartunit init --path /path/to/project


# ── Analysis ───────────────────────────────────────────────
# Run all architecture rules
dart run dartunit analyze

# Run rules in a different directory
dart run dartunit analyze --path /path/to/project

# Run without terminal colors (for CI logs)
dart run dartunit analyze --no-color

# Run and generate an AI-readable report at .dartunit/agent_report.md
dart run dartunit analyze --agent


# ── Development ────────────────────────────────────────────
# Generate a new rule file scaffold
dart run dartunit generate naming_conventions
dart run dartunit generate no_god_classes

# Run a single rule file during development
dart test test_arch/my_rule_arch_test.dart


# ── History ────────────────────────────────────────────────
# View history of all analysis runs
dart run dartunit log


# ── AI Integration ─────────────────────────────────────────
# Configure one or more AI tools for this project
dart run dartunit ai
```

## File Discovery

The `analyze` command discovers rule files by scanning the `test_arch/` folder for files matching `*_arch_test.dart`:

```
test_arch/
├── domain_layer_arch_test.dart        ← discovered ✓
├── naming_conventions_arch_test.dart  ← discovered ✓
├── helpers.dart                        ← ignored
└── README.md                           ← ignored
```

## Exit Codes

All commands follow the same exit code convention:

| Code | Meaning |
|------|---------|
| `0` | Success — no violations, or only `info`/`warning` |
| `1` | Violations found (`error` or `critical` severity) |
| `2` | Configuration or runtime error |

See [Exit Codes](/reference/exit-codes) for details.

