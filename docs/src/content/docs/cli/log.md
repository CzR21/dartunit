---
title: DartUnit log
description: View the history of past DartUnit analyze runs stored in the .dartunit log.
sidebar:
  order: 5
---

The `log` command displays the history of past `dartunit analyze` runs. DartUnit stores a summary of each run in a `.dartunit` log file at the project root, which `log` reads and formats for display.

## Usage

```bash
dart run dartunit log [options]
```

## Options

| Option | Default | Description |
|--------|---------|-------------|
| `--last <N>` | All entries | Limit output to the last `N` runs |

## Examples

```bash
# Show all recorded runs
dart run dartunit log

# Show only the last 5 runs
dart run dartunit log --last 5

# Show only the most recent run
dart run dartunit log --last 1
```

## Output format

Each entry shows the timestamp, result, and a summary of violations found:

```
Run #12 — 2026-03-24 14:32:10
  Result:     FAIL (exit 1)
  Violations: 3 (1 critical, 2 errors)

Run #11 — 2026-03-23 09:15:44
  Result:     PASS (exit 0)
  Violations: 0

Run #10 — 2026-03-22 17:48:02
  Result:     FAIL (exit 1)
  Violations: 5 (3 errors, 2 warnings)
```

## The .dartunit log file

The `.dartunit` file is written by `dartunit analyze` at the project root after every run. It stores structured metadata about each execution, including:

- Timestamp
- Exit code
- Violation counts per severity level
- Number of rules evaluated

:::tip
Add `.dartunit` to your `.gitignore` if you do not want to track analysis history in version control, or commit it to maintain a shared history across the team.
:::
