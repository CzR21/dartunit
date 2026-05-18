import '../ai_file_generator.dart';
import '../ai_agent.dart';

class ClaudeCodeGenerator implements AiFileGenerator {
  @override
  List<GeneratedAiFile> get files => [
        GeneratedAiFile('.claude/commands/dartunit-generate.md', _generateCommand),
        GeneratedAiFile('.claude/commands/dartunit-analyze.md', _analyzeCommand),
        GeneratedAiFile('.claude/agents/dartunit.md', _agent),
      ];

  static const _generateCommand = '''
Analyze this Flutter/Dart project and generate DartUnit architecture rules tailored to its structure.

\$ARGUMENTS

## Instructions

1. Scan `lib/` with Glob to discover all folders and their structure
2. Read `pubspec.yaml` to identify packages (bloc, riverpod, get_it, dio, etc.)
3. List `test_arch/` to check for existing rules (avoid duplicates)
4. Identify the architecture pattern from the folder layout
5. Generate 3–6 impactful DartUnit rules that reflect this project's actual structure
6. Write each rule to `test_arch/<name>_arch_test.dart`
7. After writing, show a summary of what was created and why

Prefer presets (`layeredArchitecture`, `namingClassConvention`, etc.) over raw matchers when a preset fits the use case.

$dartunitAgent
''';

  static const _analyzeCommand = '''
Run DartUnit architecture analysis on this project and present the results to the user.

## Instructions

1. Run in the project root: `dartunit analyze --agent`
2. Read `.dartunit/agent_report.md`
3. Parse the report:
   - The **Summary** section shows: rules analyzed, total violations, failures, warnings, info, and status
   - The **Violations** section lists each violation with: severity, rule, file, optional line, and message
4. If status is `passed`, tell the user all architecture rules are satisfied — nothing to fix
5. Otherwise, present violations grouped by severity — errors and criticals first (blocking), then warnings, then info
6. For each violation:
   - State the violated rule and explain what architectural constraint it enforces
   - Identify the exact file and line (if present)
   - Suggest a concrete fix: move or rename the file/class, or explain if the rule itself may need adjustment
7. End with a numbered action list ordered by impact
''';

  static const _agent = '''---
name: dartunit
description: DartUnit architecture specialist. Use when generating, explaining, or debugging DartUnit rules for this project.
---

You are a DartUnit expert integrated into this Flutter/Dart project.

DartUnit is an architecture testing tool inspired by ArchUnit. It enforces structural rules using the standard `dart test` runner. Rules live in `test_arch/` and are regular Dart test files.

## Your Capabilities

- **Generate rules** — scan `lib/`, understand the architecture, write `test_arch/*.dart` files. Use `/dartunit-generate`.
- **Analyze violations** — run `dartunit analyze --agent`, read `.dartunit/agent_report.md`, explain each violation and suggest fixes. Use `/dartunit-analyze`.
- **Explain violations** — when `dartunit analyze` reports a violation, explain what it means and how to fix it
- **Suggest improvements** — review existing rules in `test_arch/` and propose more precise or useful ones
- **Debug rules** — identify why a rule is failing or not matching what the user expects

## How to Generate Rules

1. Glob `lib/**` to understand the folder structure
2. Read `pubspec.yaml` for package dependencies
3. List `test_arch/` for existing rules
4. Pick the architecture pattern
5. Generate targeted rules using presets when available
6. Write to `test_arch/<name>_arch_test.dart`

## How to Analyze Violations

1. Run `dartunit analyze --agent` in the project root
2. Read `.dartunit/agent_report.md`
3. Parse the **Summary** section — check `Status`, `Failures`, `Warnings`, and `Info` counts
4. For each violation in the **Violations** section, use the severity, rule, file, line, and message to explain what broke
5. Group violations by severity: errors and criticals first, then warnings, then info
6. Suggest either a code fix (move the file, rename the class) or a rule adjustment if the rule is too strict
7. End with a numbered action list ordered by impact

$dartunitAgent
''';
}
