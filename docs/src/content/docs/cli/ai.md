---
title: DartUnit ai
description: Configure one or more AI tools to generate architecture rules and analyze violations in your project.
sidebar:
  order: 6
---

The `ai` command configures AI tool integration for your project. It generates the configuration files each tool needs to understand DartUnit's API and operate on your codebase — both for generating rules and for interpreting violations.

## Usage

```bash
dart run dartunit ai [options]
```

## Options

| Option | Default | Description |
|--------|---------|-------------|
| `--path <dir>` | `.` (current directory) | Path to the project root |

## Supported providers

| Provider | Tool |
|----------|------|
| `Claude Code` | Anthropic's Claude Code CLI and IDE extension |
| `Gemini CLI` | Google's Gemini CLI |
| `Cursor` | Cursor IDE |
| `GitHub Copilot` | GitHub Copilot in VS Code |

## How it works

Running `dartunit ai` opens an interactive multi-select prompt. Use **space** to toggle providers and **enter** to confirm.

```
? Select your AI tools (space to toggle, enter to confirm):
  [x] Claude Code
  [ ] Gemini CLI
  [x] Cursor
  [ ] GitHub Copilot
```

You can select more than one provider — for example, Claude Code and Cursor at the same time.

When you re-run the command, the providers already configured in `.dartunit/dartunit.json` appear pre-selected. Toggle to add or remove providers and confirm to apply.

## What gets generated

Each provider receives a dedicated set of files tailored to how that tool reads context and instructions.

### Claude Code

```
.claude/
├── commands/
│   ├── dartunit-generate.md   ← /dartunit-generate slash command
│   └── dartunit-analyze.md    ← /dartunit-analyze slash command
└── agents/
    └── dartunit.md            ← dartunit specialist sub-agent
```

### Cursor

```
.cursor/
└── rules/
    ├── dartunit.mdc           ← specialist with full API reference
    ├── dartunit-generate.mdc  ← rule for generating architecture rules
    └── dartunit-analyze.mdc   ← rule for analyzing violations
```

### Gemini CLI

```
GEMINI.md   ← context file with generate and analyze workflows
```

### GitHub Copilot

```
.github/
├── copilot-instructions.md
└── instructions/
    ├── dartunit.instructions.md           ← full API reference
    ├── dartunit-generate.instructions.md  ← generate workflow
    └── dartunit-analyze.instructions.md   ← analyze workflow
```

## AI workflows

Each provider receives instructions for two distinct workflows.

### Generate rules

The AI scans `lib/`, reads `pubspec.yaml`, checks existing rules in `test_arch/`, identifies the architecture pattern, and writes 3–6 rule files to `test_arch/`.

- **Claude Code:** invoke with `/dartunit-generate`
- **Cursor:** ask "generate dartunit rules for this project"
- **Gemini CLI:** ask "generate DartUnit architecture rules"
- **GitHub Copilot:** ask "generate DartUnit architecture rules" in Copilot Chat

### Analyze violations

The AI runs `dartunit analyze --agent`, reads `.dartunit/agent_report.md`, groups violations by severity, and explains each one with a concrete fix suggestion.

- **Claude Code:** invoke with `/dartunit-analyze`
- **Cursor:** ask "analyze dartunit violations"
- **Gemini CLI:** ask "analyze DartUnit architecture violations"
- **GitHub Copilot:** ask "analyze DartUnit violations" in Copilot Chat

## Configuration file

The selected providers are saved to `.dartunit/dartunit.json`:

```json
{
  "ai": {
    "providers": ["claude_code", "cursor"]
  }
}
```

When providers are configured, `dartunit analyze` automatically generates `.dartunit/agent_report.md` at the end of each run — the same as passing `--agent` manually.

## Agent report

The agent report is a plain Markdown file at `.dartunit/agent_report.md`. It is designed to be read by any language model without special parsing.

```markdown
# DartUnit Analysis Report

Generated: 2024-01-01T00:00:00
Project: /path/to/project
Rule files:
- test_arch/domain_arch_test.dart

## Summary

- Rules analyzed: 4
- Total violations: 2
- Failures: 2
- Warnings: 0
- Info: 0
- Status: failed

## Violations

### error

Rule: Domain must not depend on the data layer
File: lib/domain/services/user_service.dart
Line: 3
Message: UserService imports from lib/data
```

## Skipping AI setup during init

When you run `dartunit init`, you are asked whether to configure an AI provider. If you skip it at that point, you can run `dartunit ai` at any time later to set it up.

```bash
dart run dartunit ai
```
