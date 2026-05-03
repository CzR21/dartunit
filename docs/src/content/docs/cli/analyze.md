---
title: DartUnit analyze
description: Run all architecture rules and generate a violation report.
sidebar:
  order: 4
---

The `analyze` command is the primary command in DartUnit. It discovers all rule files, runs them via `dart test`, collects violations, and produces both a console summary and an HTML report.

## Usage

```bash
dart run dartunit analyze [options]
```

## Options

| Option | Default | Description |
|--------|---------|-------------|
| `--path <dir>` | `.` (current directory) | Path to the project to analyze |
| `--no-color` | `false` | Disables ANSI color codes in console output |

## How it discovers rule files

`analyze` scans the `test_arch/` folder for all files matching the pattern `*_test_arch.dart`. Files that do not end with `_test_arch.dart` are ignored.

```
test_arch/
├── domain_layer_test_arch.dart       ← executed
├── naming_conventions_test_arch.dart ← executed
├── helpers.dart                       ← ignored
└── README.md                          ← ignored
```

All discovered files are passed to a single `dart test` invocation. Each `testArchGroup` within a file analyzes the project once and shares the context across its `testArch` calls.

## Execution flow

```
1. Discover all *_test_arch.dart files in test_arch/

2. Run: dart test <file1> <file2> ... --reporter json
   Each testArch registers a test that:
   └── Analyzes the project (or reuses group context)
   └── Builds a selector via selector.classes() / selector.files()
   └── Evaluates the matcher (predicate) on each selected element
   └── Emits DARTUNIT_RESULT: to stderr for dartunit analyze
   └── Prints ✓/✗ result to stdout for direct dart test runs

3. Collect violations from stderr (DARTUNIT_RESULT: lines)

4. Sort violations by severity (critical → error → warning → info)

5. Render summary to console

6. Generate HTML report at .dartunit/report.html
```

## Console output

### During rule execution (dart test output)

Each rule prints its result inline as tests run:

```
  ✓  Domain must not depend on the data layer
  ✓  Domain must be Flutter-agnostic
  ✗  Repository interfaces must be abstract
       ✗ lib/domain/repositories/product_repo.dart [error] — must be abstract
```

### Final summary — no violations

```
✓ Found 3 rule file(s)
✓ Rules analyzed

No architecture violations found.
```

### Final summary — with violations

```
  ┌──────┬──────────────────────────────┬──────────────────────────────────────┬──────┬────────────────────────────────────────┐
  │      │ Description                  │ File                                 │ Line │ Message                                │
  ├──────┼──────────────────────────────┼──────────────────────────────────────┼──────┼────────────────────────────────────────┤
  │ ERR  │ must have at most 10 methods │ lib/generated/intl/messages_en.dart  │ 18   │ MessageLookup has 14 methods — ma...   │
  │ ERR  │ must have at most 10 methods │ lib/generated/intl/messages_pt.dart  │ 18   │ MessageLookup has 14 methods — ma...   │
  │ ERR  │ must have at most 10 methods │ lib/generated/intl/messages_uk.dart  │ 18   │ MessageLookup has 14 methods — ma...   │
  │ ERR  │ must have at most 10 methods │ lib/generated/l10n.dart              │ 13   │ S has 15 methods — maximum allowe...   │
  │ ERR  │ must have at most 10 methods │ lib/l10n/app_localizations.dart      │ 65   │ AppLocalizations has 13 methods —...   │
  │ ERR  │ must have at most 10 methods │ lib/l10n/app_localizations_de.dart   │ 7    │ AppLocalizationsDe has 13 methods...   │
  │ ERR  │ must have at most 10 methods │ lib/l10n/app_localizations_en.dart   │ 7    │ AppLocalizationsEn has 13 methods...   │
  │ ERR  │ must have at most 10 methods │ lib/l10n/app_localizations_pt.dart   │ 7    │ AppLocalizationsPt has 13 methods...   │
  │ ERR  │ must have at most 10 methods │ lib/l10n/app_localizations_uk.dart   │ 7    │ AppLocalizationsUk has 13 methods...   │
  │ ERR  │ must have at most 10 methods │ lib/theme/style.dart                 │ 1    │ MaterialTheme has 25 methods — ma...   │
  └──────┴──────────────────────────────┴──────────────────────────────────────┴──────┴────────────────────────────────────────┘
10 violation(s)  ·  🚨  0 critical(s)  ·  ✖  10 error(s)  ·  ⚠️  0 warning(s)  ·  ℹ️  0 info
```

Violations are sorted by severity (critical → error → warning → info). The `Message` column is truncated in the console — the full message appears in the HTML report.

The full HTML report with a complete violations table is written to `.dartunit/report.html`.

## HTML report

After every `analyze` run, a self-contained HTML file is written to `.dartunit/report.html`. The report includes:

- Summary cards: total violations, critical, errors, warnings, info
- Full violations table with severity badges and file paths
- Dark theme, no external dependencies — works offline

The file is always regenerated on each run. To view past runs, use [`dartunit log`](/cli/log).

## Exit codes

| Code | Condition |
|------|-----------|
| `0` | No violations, or only `info` and `warning` violations |
| `1` | At least one `error` or `critical` violation |
| `2` | Error before analysis could start (e.g., `test_arch/` not found) |

## Examples

```bash
# Analyze the current project
dart run dartunit analyze

# Analyze a project in another directory
dart run dartunit analyze --path /home/user/my_project

# Output without colors (for CI logs)
dart run dartunit analyze --no-color
```

## CI integration

### GitHub Actions

```yaml title=".github/workflows/ci.yml"
name: Architecture Check

on: [push, pull_request]

jobs:
  dartunit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: dart-lang/setup-dart@v1
        with:
          sdk: stable
      - run: dart pub get
      - name: Check architecture rules
        run: dart run dartunit analyze --no-color
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

:::tip[Use --no-color in CI]
CI log systems generally do not render ANSI color codes. Use `--no-color` for clean, readable output in pipeline logs.
:::
