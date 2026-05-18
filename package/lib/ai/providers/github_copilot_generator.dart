import '../ai_file_generator.dart';
import '../ai_agent.dart';

class GithubCopilotGenerator implements AiFileGenerator {
  @override
  List<GeneratedAiFile> get files => [
        GeneratedAiFile(
          '.github/copilot-instructions.md',
          _copilotInstructions,
        ),
        GeneratedAiFile(
          '.github/instructions/dartunit.instructions.md',
          _dartunitInstructions,
        ),
        GeneratedAiFile(
          '.github/instructions/dartunit-generate.instructions.md',
          _generateInstructions,
        ),
        GeneratedAiFile(
          '.github/instructions/dartunit-analyze.instructions.md',
          _analyzeInstructions,
        ),
      ];

  static const _copilotInstructions = '''
# GitHub Copilot Instructions

This project uses **DartUnit** to enforce architecture rules. Architecture tests live in `test_arch/` and run with `dartunit analyze`.

- To generate architecture rules, follow `.github/instructions/dartunit-generate.instructions.md`.
- To analyze violations, follow `.github/instructions/dartunit-analyze.instructions.md`.
- For the full DartUnit API reference, see `.github/instructions/dartunit.instructions.md`.
''';

  static const _dartunitInstructions = '''---
applyTo: test_arch/**/*.dart
---

# DartUnit Architecture Specialist

This project uses **DartUnit** to enforce architecture rules. Files in `test_arch/` are standard Dart test files validated by `dartunit analyze`.

$dartunitAgent
''';

  static const _generateInstructions = '''---
applyTo: test_arch/**/*.dart
---

# Generate DartUnit Rules

When asked to create, generate, or scaffold architecture rules:

1. Scan `lib/` to discover folders and structure
2. Read `pubspec.yaml` for package dependencies
3. Check `test_arch/` for existing rules (avoid duplicates)
4. Identify the architecture pattern (BLoC, Clean Arch, MVVM, etc.)
5. Generate 3–6 rule files named `test_arch/<name>_arch_test.dart`
6. After writing, show a summary of what was created and why

Prefer presets over raw matchers when a preset covers the use case.
''';

  static const _analyzeInstructions = '''---
applyTo: "**"
---

# Analyze DartUnit Violations

When asked to analyze or review architecture violations:

1. Run: `dartunit analyze --agent`
2. Read `.dartunit/agent_report.md`
3. Parse the **Summary** section — check `Status`, `Failures`, `Warnings`, and `Info` counts
4. If status is `passed`, report that all rules are satisfied
5. Otherwise, present violations grouped by severity — errors and criticals first (blocking), then warnings, then info
6. For each violation:
   - State the violated rule and explain what architectural constraint it enforces
   - Identify the exact file and line (if present)
   - Suggest a concrete fix: move or rename the file/class, or explain if the rule itself may need adjustment
7. End with a numbered action list ordered by impact
''';
}
