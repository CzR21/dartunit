import '../ai_file_generator.dart';
import '../ai_agent.dart';

class GeminiCliGenerator implements AiFileGenerator {
  @override
  List<GeneratedAiFile> get files => [
        GeneratedAiFile('GEMINI.md', _geminiMd),
      ];

  static const _geminiMd = '''
# DartUnit — Architecture Testing

This project uses **DartUnit** to enforce architecture rules. Rules live in `test_arch/` as standard Dart test files and are validated with `dartunit analyze`.

---

## Generate Rules

When asked to generate or scaffold architecture rules:

1. List folders under `lib/` to understand the project structure
2. Read `pubspec.yaml` to identify packages in use
3. Check `test_arch/` for existing rules (avoid duplicates)
4. Identify the architecture pattern from folder names
5. Generate 3–6 relevant rule files in `test_arch/<name>_arch_test.dart`
6. After writing, show a summary of what was created and why

Prefer presets over raw matchers when a preset covers the use case.

---

## Analyze Violations

When asked to analyze architecture violations:

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

---

$dartunitAgent
''';
}
