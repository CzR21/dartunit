import '../ai_file_generator.dart';
import '../ai_agent.dart';

class CursorGenerator implements AiFileGenerator {
  @override
  List<GeneratedAiFile> get files => [
        GeneratedAiFile('.cursor/rules/dartunit.mdc', _specialist),
        GeneratedAiFile('.cursor/rules/dartunit-generate.mdc', _generateRule),
        GeneratedAiFile('.cursor/rules/dartunit-analyze.mdc', _analyzeRule),
      ];

  static const _specialist = '''---
description: DartUnit architecture specialist — API reference, preset docs, and examples for this project
globs:
  - test_arch/**/*.dart
alwaysApply: false
---

# DartUnit Architecture Specialist

This project uses **DartUnit** to enforce architecture rules. Files in `test_arch/` are standard Dart test files validated by `dartunit analyze`.

To generate rules, follow `.cursor/rules/dartunit-generate.mdc`.
To analyze violations, follow `.cursor/rules/dartunit-analyze.mdc`.

$dartunitAgent
''';

  static const _generateRule = '''---
description: Generate DartUnit architecture rules for this project based on its folder structure and packages
globs:
  - lib/**/*.dart
  - pubspec.yaml
alwaysApply: false
---

# Generate DartUnit Rules

When asked to create, generate, or scaffold architecture rules:

1. Scan `lib/` to discover folders and layout
2. Read `pubspec.yaml` for package dependencies
3. Check `test_arch/` for existing rules (avoid duplicates)
4. Identify the pattern (BLoC, Clean Arch, MVVM, etc.)
5. Generate 3–6 rule files named `test_arch/<name>_arch_test.dart`
6. After writing, show a summary of what was created and why

Prefer presets over raw matchers when a preset covers the use case.
''';

  static const _analyzeRule = '''---
description: Analyze DartUnit architecture violations — run dartunit analyze, read the report, and explain violations to the developer
globs:
  - .dartunit/agent_report.md
alwaysApply: false
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
