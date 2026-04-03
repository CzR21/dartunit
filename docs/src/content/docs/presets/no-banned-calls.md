---
title: noBannedCallsPreset
description: Scan file content for forbidden patterns using regex. Ban debug prints, hardcoded URLs, deprecated APIs, or any text pattern that shouldn't exist in production.
sidebar:
  order: 11
---

`noBannedCallsPreset` scans the raw source text of Dart files for forbidden patterns defined as regular expressions. It returns a `List<ArchitectureRule>` — one rule per banned pattern — making it one of the most flexible presets in DartUnit's library.

Use this preset to enforce code hygiene rules that semantic analyzers and linters cannot catch: debug output left in production, hardcoded environment URLs, deprecated method calls, direct HTTP usage that bypasses the repository layer, or any textual pattern your team has agreed to prohibit.

## The Problem With Debug Artifacts in Production

Production code accumulates debug artifacts over time. A developer adds `print('DEBUG: user id is $userId')` to diagnose a bug, fixes the bug, but forgets to remove the print. The statement ships to production. Depending on what it prints, this can:

- **Leak sensitive data to device logs.** On Android and iOS, device logs are accessible to other apps with the `READ_LOGS` permission. User IDs, session tokens, email addresses, and PII should never appear in production logs.
- **Bloat production log output.** If your team monitors Crashlytics, Firebase, or a custom log aggregator, debug prints add noise that obscures real errors. Filtering becomes necessary and error rates become harder to interpret.
- **Expose internal architecture.** Stack traces and debug messages reveal class names, method signatures, and data structures to anyone with log access on a rooted device.

The `print()` function in Dart writes directly to stdout. `debugPrint()` throttles output but still writes to the debug console. Neither belongs in production code. The `noBannedCallsPreset` can ban both with a single configuration.

## Why Regex on Source Text is Powerful

Most static analysis tools — including the Dart analyzer and lint packages — operate on the Abstract Syntax Tree (AST). They understand the program's semantic structure: types, symbols, call graphs, scopes. This is powerful for many checks but has a blind spot: it cannot easily inspect the textual content of string literals, comments, or specific argument values.

Regex on raw source text operates at a different level. It does not understand semantics, but it sees everything:

- **String literal content:** A regex can find `'https://staging.api.mycompany.com'` in a string literal. The AST sees a string constant; the regex sees the prohibited URL.
- **Comment patterns:** A regex can find `// TODO:` or `// FIXME:` comments regardless of where they appear. The AST typically ignores comments entirely.
- **Specific argument values:** A regex can find `SharedPreferences.setString('debug_mode', ...)` to catch uses of a specific preference key.
- **Partial identifiers:** A regex can find `OldApiClient` anywhere it appears, even in variable names, type annotations, or import paths, without needing to resolve symbols.

This makes `noBannedCallsPreset` complementary to — not a replacement for — the Dart analyzer. Use both: the analyzer for semantic rules, `noBannedCallsPreset` for textual hygiene.

## Comparison with Dart Linter Rules

| Aspect | Dart Linter / Analyzer | `noBannedCallsPreset` |
|---|---|---|
| Checks | Semantic, type-aware | Textual, pattern-based |
| String contents | Cannot inspect | Can inspect |
| Comments | Ignores | Can match |
| Hardcoded values | Cannot detect | Can detect |
| Specific URLs | Cannot detect | Can detect |
| Custom messages | Limited | Full control |
| Scope control | Package-wide | Per-folder |

## Return Type: `List<ArchitectureRule>`

Unlike most presets that return a single `ArchitectureRule`, `noBannedCallsPreset` returns `List<ArchitectureRule>`. Each entry in the `patterns` map produces one rule. This allows DartUnit to report violations from each banned pattern as separate, independently named rules.

To use a preset returning a list, iterate over it in your rule file:

```dart
// arch_test/banned_calls.dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) {
  final rules = noBannedCallsPreset(
    patterns: {
      r'print\(': 'Use a logger instead of print()',
      r'debugPrint\(': 'Remove debugPrint() before committing to main',
    },
    folders: ['lib'],
  );

  for (final rule in rules) {
    archTest(args, rule);
  }
}
```

Or use a helper to reduce boilerplate if you have many rule files with list-returning presets:

```dart
// arch_test/banned_calls.dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) {
  archTestAll(args, noBannedCallsPreset(
    patterns: {
      r'print\(': 'Use a logger instead of print()',
      r'debugPrint\(': 'Remove debugPrint() before committing to main',
    },
  ));
}
```

## Function Signature

```dart
List<ArchitectureRule> noBannedCallsPreset({
  required Map<String, String> patterns,
  List<String> folders = const [],
  Severity severity = Severity.error,
  List<String> exceptions = const [],
})
```

## Parameters

### `patterns`

**Type:** `Map<String, String>` — required

A map where each key is a regular expression pattern (as a raw Dart string using `r'...'`) and each value is a human-readable description of why the pattern is banned. The description appears in the violation message to explain the rule to developers who encounter it.

```dart
patterns: {
  r'print\(':   'Avoid print() in production. Use AppLogger.log() instead.',
  r'http\.get\(': 'Do not call http.get() directly. Use ApiService.',
}
```

Patterns are matched against the full text of each file. A match anywhere in the file produces a violation. Use anchors, word boundaries, or specific context in your pattern to avoid false positives.

**Pattern writing tips:**

- Use raw strings (`r'...'`) to avoid double-escaping backslashes.
- Escape regex metacharacters in literal code patterns: `print(` becomes `r'print\('`.
- Use `\b` for word boundaries to avoid matching substrings: `r'\bprint\b'` matches `print` but not `footprint`.
- To match a URL prefix: `r'https://staging\.'` matches any staging URL.
- Use `.*` carefully — it matches across characters but not newlines by default.
- Test patterns against representative files before committing them.

### `folders`

**Type:** `List<String>` — default `[]`

When empty, the rule applies to all Dart files in the project. When specified, only files within the given folders are scanned.

Most teams apply different banned patterns to different folders. For example, `print()` bans apply to `lib/` but not `test/` (where print is fine for debugging tests). Hardcoded URL bans apply everywhere. Comment pattern bans might apply only to `lib/`.

### `severity`

**Type:** `Severity` — default `Severity.error`

`Severity.error` is appropriate for patterns that represent clear production risks: debug output, hardcoded credentials, removed deprecated APIs. `Severity.warning` is appropriate during migration periods when you're alerting developers to migrate away from a pattern but haven't yet made it mandatory.

### `exceptions`

**Type:** `List<String>` — default `[]`

File paths (relative to project root) or class names to exclude from all patterns in this preset. Use this for files that legitimately contain some of the banned patterns — for example, a logging utility class that wraps `print()` is the one place where `print()` is allowed.

```dart
noBannedCallsPreset(
  patterns: { r'print\(': 'Use AppLogger instead.' },
  exceptions: ['lib/core/logger.dart'], // The logger wraps print()
)
```

## Examples

### Example 1: Ban `print()` Calls in Production Code

The most common use case. Any `print()` call in `lib/` (but not in tests) should be replaced with a proper logging solution.

```dart
// arch_test/no_print.dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) {
  final rules = noBannedCallsPreset(
    patterns: {
      r'\bprint\(':
          'print() must not appear in production code. '
          'Use AppLogger.debug(), AppLogger.info(), or AppLogger.error() instead. '
          'See docs/logging.md for the logging guide.',
      r'\bdebugPrint\(':
          'debugPrint() must not appear in production code. '
          'Use AppLogger.debug() for debug-level messages.',
    },
    folders: ['lib'], // Not test/ — print() is fine in tests
    severity: Severity.error,
    exceptions: ['lib/core/logging/app_logger.dart'], // The logger itself uses print
  );

  for (final rule in rules) {
    archTest(args, rule);
  }
}
```

Violation output:

```
VIOLATION [error] noBannedCallsPreset[\bprint\(]
  File: lib/features/auth/auth_repository.dart
  Line 47: print('Login response: $response');
  Pattern: \bprint\(
  Reason: print() must not appear in production code.
          Use AppLogger.debug(), AppLogger.info(), or AppLogger.error() instead.
          See docs/logging.md for the logging guide.
```

### Example 2: Ban Hardcoded URLs

Hardcoded environment URLs — especially staging URLs — are a common cause of production incidents. A developer tests against staging, forgets to revert the URL, and commits to main. The production app now calls the staging API.

```dart
// arch_test/no_hardcoded_urls.dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) {
  final rules = noBannedCallsPreset(
    patterns: {
      r'https?://staging\.':
          'Hardcoded staging URL detected. '
          'Use AppConfig.apiBaseUrl instead, which reads from environment variables.',
      r'https?://localhost':
          'Hardcoded localhost URL detected. '
          'Use AppConfig.apiBaseUrl for environment-specific URLs.',
      r'https?://10\.0\.2\.2':
          'Hardcoded Android emulator localhost URL detected. '
          'Use AppConfig.apiBaseUrl instead.',
      r'https?://api\.dev\.':
          'Hardcoded development API URL detected. '
          'All URLs must come from AppConfig.',
    },
    folders: ['lib'],
    severity: Severity.error,
    exceptions: [
      'lib/config/app_config.dart',  // Config file defines these URLs — fine
      'lib/config/environment.dart', // Environment definitions
    ],
  );

  for (final rule in rules) {
    archTest(args, rule);
  }
}
```

This pattern catches:

```dart
// VIOLATION: hardcoded staging URL in repository
class ProductRepository {
  Future<List<Product>> getProducts() async {
    // This line will be flagged:
    final response = await http.get(Uri.parse('https://staging.api.mycompany.com/products'));
    ...
  }
}
```

### Example 3: Ban `TODO:` and `FIXME:` Comments in Release Code

`TODO` and `FIXME` comments are common markers during development. They indicate known problems or planned work. A policy of "no `TODO` or `FIXME` in code that reaches `main`" forces developers to either complete the work or convert the comment to a tracked issue.

```dart
// arch_test/no_pending_comments.dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) {
  final rules = noBannedCallsPreset(
    patterns: {
      r'//\s*TODO':
          'TODO comments are not allowed in production code. '
          'Create a GitHub issue and replace this comment with the issue URL.',
      r'//\s*FIXME':
          'FIXME comments indicate known bugs. '
          'Fix the issue before merging, or create a tracked GitHub issue.',
      r'//\s*HACK':
          'HACK comments indicate technical debt. '
          'Document the hack in the architecture decision record or create a refactoring issue.',
      r'//\s*XXX':
          'XXX comments must not be committed to main. '
          'Either address the concern or document it as a tracked issue.',
    },
    folders: ['lib'],
    severity: Severity.warning, // Warning rather than error — team may have exceptions
  );

  for (final rule in rules) {
    archTest(args, rule);
  }
}
```

This does not prevent `TODO` during development — it only becomes visible when `dartunit analyze` is run (e.g., in CI). The pattern `r'//\s*TODO'` matches `// TODO`, `//TODO`, and `// TODO:` variants.

### Example 4: Ban Deprecated API Usage

When your team deprecates an internal API and introduces a replacement, you want to ensure all callsites are migrated. Dart's `@deprecated` annotation helps, but if the old method is in a third-party package that hasn't removed it, or if it's a pattern (not just a method name), `noBannedCallsPreset` fills the gap.

```dart
// arch_test/no_deprecated_apis.dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) {
  final rules = noBannedCallsPreset(
    patterns: {
      r'\bOldApiClient\b':
          'OldApiClient is deprecated. Use NewApiClient from package:myapp/core/api_client.dart. '
          'Migration guide: docs/migrations/api-client-v2.md',
      r'\.fetchLegacy\(':
          '.fetchLegacy() is removed in API v2. '
          'Use .fetch() with the new RequestOptions parameter.',
      r'SharedPrefsHelper\.getInstance\(':
          'SharedPrefsHelper.getInstance() is deprecated. '
          'Use the injected IPreferencesRepository interface instead.',
      r'package:myapp/utils/old_utils\.dart':
          'old_utils.dart is deprecated. '
          'All utilities have been moved to package:myapp/core/utils/. '
          'Update your imports.',
    },
    folders: ['lib'],
    severity: Severity.error,
  );

  for (final rule in rules) {
    archTest(args, rule);
  }
}
```

The word boundary `\b` in `r'\bOldApiClient\b'` prevents matching `OldApiClientExtended` or `MyOldApiClient`. Use it whenever matching class or method names.

### Example 5: Ban Direct `http.get()` Calls

In a well-layered architecture, direct HTTP calls should only appear in the data layer (repositories, remote data sources, API clients). Widget, BLoC, and domain code should never call `http.get()` directly. This rule enforces that boundary:

```dart
// arch_test/no_direct_http.dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) {
  final rules = noBannedCallsPreset(
    patterns: {
      r'\bhttp\.get\(':
          'Direct http.get() calls are not allowed outside the data layer. '
          'Inject and use ApiService, which handles auth headers, retries, and error mapping.',
      r'\bhttp\.post\(':
          'Direct http.post() calls are not allowed outside the data layer. '
          'Use ApiService.post() instead.',
      r'\bDio\(\)':
          'Do not instantiate Dio() directly. '
          'Use the injected ApiService which provides a pre-configured Dio instance.',
      r'\bdio\.get\(':
          'Direct dio.get() calls are not allowed. Use ApiService.',
    },
    folders: [
      'lib/blocs',
      'lib/domain',
      'lib/application',
      'lib/ui',
      'lib/widgets',
      'lib/screens',
    ],
    // NOT targeting lib/data/ — that's where HTTP calls belong
    severity: Severity.error,
  );

  for (final rule in rules) {
    archTest(args, rule);
  }
}
```

### Example 6: Multiple Patterns in a Single Configuration

For a comprehensive code hygiene check, combine all patterns into one preset call. This is the typical production setup:

```dart
// arch_test/code_hygiene.dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) {
  final rules = noBannedCallsPreset(
    patterns: {
      // Debug output
      r'\bprint\(':
          'print() must not appear in production code. Use AppLogger.',
      r'\bdebugPrint\(':
          'debugPrint() must not appear in production code. Use AppLogger.',

      // Hardcoded credentials and URLs
      r'(?i)password\s*=\s*["\'][^"\']+["\']':
          'Hardcoded password detected. Use environment variables or secure storage.',
      r'(?i)api_?key\s*=\s*["\'][^"\']{8,}["\']':
          'Hardcoded API key detected. Use AppConfig or environment variables.',
      r'https?://staging\.':
          'Hardcoded staging URL. Use AppConfig.apiBaseUrl.',

      // Platform channel misuse
      r'MethodChannel\(':
          'Direct MethodChannel instantiation is not allowed in feature code. '
          'Use the platform service abstractions in lib/core/platform/.',

      // Test code in production
      r'package:flutter_test/flutter_test\.dart':
          'flutter_test imports must not appear in production lib/ code.',
      r'package:mockito/':
          'mockito imports must not appear in production lib/ code.',
    },
    folders: ['lib'],
    severity: Severity.error,
    exceptions: [
      'lib/core/logging/app_logger.dart',
      'lib/core/platform/', // Platform services wrap MethodChannel
    ],
  );

  for (final rule in rules) {
    archTest(args, rule);
  }
}
```

## Writing Effective Regex Patterns for Dart Source

Dart source files are UTF-8 text. Patterns are matched line by line within each file. Keep these guidelines in mind:

**Escape metacharacters in code patterns.** Parentheses, dots, and brackets are regex metacharacters. To match `print(`, write `r'print\('`. To match a dot in a package name, write `r'package:http\.'`.

**Use `\b` for whole-word matching.** `r'\bhttp\b'` matches the identifier `http` but not `httpClient`. This avoids false positives when a banned name appears as a substring.

**Use `(?i)` for case-insensitive matching.** `r'(?i)todo'` matches `TODO`, `Todo`, and `todo`. Useful for comment patterns.

**Avoid overly broad patterns.** `r'http'` would match any file containing the word "http" — including import statements, comments, and variable names like `httpStatusCode`. The more specific your pattern, the fewer false positives you'll encounter.

**Use negative lookahead for exclusions within a pattern.** To match `print(` but not `printer(` or `sprintf(`, use `r'\bprint\s*\('` to require that `print` is followed by optional whitespace and then `(`.

**Test patterns in isolation.** Use a Dart script or an online regex tester to verify your pattern against representative file contents before adding it to `noBannedCallsPreset`.

## The `description` Field in Violation Messages

The value associated with each pattern key is displayed verbatim in the violation message under `Reason:`. Write descriptions that:

1. **State what is wrong:** "print() must not appear in production code."
2. **Explain why:** "It leaks information to device logs."
3. **Provide the alternative:** "Use AppLogger.log() instead."
4. **Link to documentation if available:** "See docs/logging.md."

A developer encountering a violation for the first time should understand what to do without asking anyone. Invest in clear, actionable descriptions.

```
VIOLATION [error] noBannedCallsPreset[\\bprint\\(]
  File: lib/features/cart/cart_service.dart
  Line 89: print('Cart updated: ${cart.items.length} items, total: ${cart.total}');
  Pattern: \bprint\(
  Reason: print() must not appear in production code. It leaks user data to device logs.
          Use AppLogger.log() instead. See docs/logging.md.
```

## Integrating With CI

Add DartUnit to your CI pipeline to catch banned patterns before they merge:

```yaml
# .github/workflows/architecture.yml
name: Architecture Check

on:
  pull_request:
    branches: [main, develop]

jobs:
  dartunit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: dart-lang/setup-dart@v1
      - run: dart pub get
      - run: dart run dartunit analyze
```

The exit code of `dart run dartunit analyze` is non-zero when any `Severity.error` rule has violations, which causes the CI check to fail and prevents the PR from being merged.

## Related Presets

- [`noExternalPackagePreset`](/presets/no-external-package) — Prevent importing specific packages in specific layers
- [`classSizeLimitPreset`](/presets/class-size-limit) — Control class complexity
- [`noPublicFieldsPreset`](/presets/no-public-fields) — Enforce encapsulation through structural rules rather than textual pattern matching
