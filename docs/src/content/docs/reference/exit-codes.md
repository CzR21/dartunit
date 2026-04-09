---
title: Exit Codes
description: Exit codes returned by DartUnit analyze and how to use them in CI/CD.
sidebar:
  order: 5
---

`dartunit analyze` returns one of three exit codes. These codes allow CI/CD pipelines to automatically detect violations and fail the build when necessary.

## Exit Codes

| Code | Condition | Description |
|------|-----------|-------------|
| `0` | Success | No violations found, or only `info` and `warning` violations |
| `1` | Violations | At least one `error` or `critical` violation was found |
| `2` | Error | A problem occurred before analysis could complete |

## Details

### Exit Code 0 — Pass

The analysis completed successfully with no blocking violations. The pipeline should continue.

```bash
dart run dartunit analyze
echo $?  # → 0
```

This happens when:
- No violations were found at all
- Only `info` or `warning` violations were found

### Exit Code 1 — Violations Found

At least one rule with severity `error` or `critical` was violated. The pipeline should be blocked.

```bash
dart run dartunit analyze
# ERROR | Domain must not depend on data layer | lib/domain/...
echo $?  # → 1
```

### Exit Code 2 — Configuration or Runtime Error

A problem occurred before analysis could start. Common causes:

- `test_arch/` folder not found (run `dart run dartunit init` first)
- A rule file has a syntax error that prevents it from being compiled
- The `--path` directory does not exist

```bash
dart run dartunit analyze --path /nonexistent/path
# Error: project directory not found
echo $?  # → 2
```

## CI/CD Integration

### GitHub Actions

```yaml title=".github/workflows/architecture.yml"
name: Architecture Check

on:
  push:
    branches: [main, develop]
  pull_request:

jobs:
  dartunit:
    name: Architecture Rules
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: dart-lang/setup-dart@v1
        with:
          sdk: stable
      - name: Install dependencies
        run: dart pub get
      - name: Run architecture check
        run: dart run dartunit analyze --no-color
      # The step fails automatically if exit code != 0
```

### GitLab CI

```yaml title=".gitlab-ci.yml"
architecture:
  stage: test
  image: dart:stable
  script:
    - dart pub get
    - dart run dartunit analyze --no-color
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
    - if: $CI_COMMIT_BRANCH == "main"
```

### Makefile

```makefile
.PHONY: arch arch-ci

arch:
	dart run dartunit analyze

arch-ci:
	dart run dartunit analyze --no-color
```

### Shell script with explicit handling

```bash title="scripts/arch_check.sh"
#!/bin/bash
set -e

dart run dartunit analyze --no-color
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
  echo "Architecture check passed."
elif [ $EXIT_CODE -eq 1 ]; then
  echo "Architecture violations found. Fix them before merging."
  exit 1
elif [ $EXIT_CODE -eq 2 ]; then
  echo "dartunit configuration error. Check your test_arch/ folder."
  exit 2
fi
```

## Treating Warnings as Errors

By default, `warning` violations do not cause exit code 1. To enforce warnings, change their severity to `error` in the rule definition — there is no `--warnings-as-errors` flag.

```dart
// Change severity in the rule file:
ArchitectureRule(
  description: 'Classes in lib/bloc must end with Bloc or Cubit',
  severity: RuleSeverity.error, // was: warning
  selector: ClassSelector(folder: 'lib/bloc'),
  predicate: OrPredicate([
    NameEndsWithPredicate('Bloc'),
    NameEndsWithPredicate('Cubit'),
  ]),
)
```
