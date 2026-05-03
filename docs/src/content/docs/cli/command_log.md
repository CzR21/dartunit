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
| `--path <dir>` | `.` (current directory) | Path to the project root where the `.dartunit` log file is located |
| `--no-color` | `false` | Disable colored output |

## Examples

```bash
# Show all recorded runs
dart run dartunit log

# Show log for a project in another directory
dart run dartunit log --path /path/to/project

# Show log without colors (useful in CI)
dart run dartunit log --no-color
```

## Output format

Each run entry displays the execution timestamp, the result, and a summary of the violations found:

```
── Run #3  ·  05 Apr 2026  14:50  ·  2 rules ────

── Run #2  ·  06 Apr 2026  10:17  ·  2 rules ────

── Run #1  ·  07 Apr 2026  21:39  ·  2 rules ────
```

## The .dartunit log file

The `.dartunit` file is written by `dartunit analyze` at the project root after every run. It stores structured metadata about every run, including:

- Timestamp of the execution
- List of violations with descriptions
- Total number of analyzed rules

:::tip
Add `.dartunit` to your `.gitignore` if you do not want to track analysis history in version control, or commit it to maintain a shared history across the team.
:::
