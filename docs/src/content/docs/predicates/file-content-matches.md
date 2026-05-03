---
title: hasContent / hasNoContent
description: Check whether file source content matches a regular expression. Used to ban print() calls, hardcoded URLs, TODO comments, and other patterns from production code.
sidebar:
  order: 28
---

## What it does

`hasContent(pattern)` passes when the file's raw source text **contains at least one match** for the given regular expression.

`hasNoContent(pattern)` is the inverse — it passes when the file's source text **does not match** the pattern.

These matchers operate on the **raw file content** as a string — they scan every character of the file, not just class declarations. They must be used with `selector.files()`, not `selector.classes()`.

---

## What problem it solves

Some code quality rules cannot be expressed in terms of class structure — they're about specific text patterns that should (or should not) appear in production files:

- `print()` calls left in production code produce noise in production logs and are a sign of debug code that was never cleaned up.
- Hardcoded URLs (`https://api.example.com/v1/`) are a configuration management problem — they should be in configuration files or environment variables, not scattered in source files.
- `TODO` comments signal incomplete work that was never tracked properly.
- `debugPrint` calls are another logging anti-pattern.
- Hardcoded secrets or API keys in source code are a security risk.

None of these can be detected by looking at class structure alone. `hasNoContent` (combined with `selector.files()`) fills this gap.

---

## Syntax

```dart
// File must match the pattern
expect(selector.files(inFolder: 'lib'), hasContent(r'pattern'));

// File must NOT match the pattern
expect(selector.files(inFolder: 'lib'), hasNoContent(r'pattern'));
```

:::caution
Use `selector.files()` (not `selector.classes()`) with these matchers. They operate at the file level, not the class level.
:::

---

## Parameters

**`hasContent(pattern, {String description = ''})`**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `pattern` | `String` | yes | A Dart regex matched against the full raw text of the file. |
| `description` | `String` | no | Optional human-readable label used in violation messages. Useful when the regex is complex and the violation message would be hard to understand. |

**`hasNoContent(pattern)`**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `pattern` | `String` | yes | A Dart regex matched against the full raw text of the file. |

---

## When to use

Use `hasNoContent()` to ban specific text patterns from production code:

- No `print()` or `debugPrint()` calls (use a proper logging solution)
- No hardcoded URLs (use constants or environment variables)
- No `TODO` or `FIXME` comments (use a proper issue tracker)
- No hardcoded secrets or passwords
- No `// ignore: ` lint comments without a documented reason

Use `hasContent()` to ensure files that must contain certain patterns actually do:

- All test files must contain `import 'package:flutter_test/flutter_test.dart'`
- Generated files must contain the generation banner comment

---

## Common use cases

- Ban `print()` calls from all production files in `lib/`
- Ban `debugPrint()` calls from all production files
- Ban hardcoded `https://` URLs
- Ban `TODO` and `FIXME` comments
- Ensure barrel files (`index.dart`) contain exports

---

## Examples

### No print() calls in production

This is the most common use of `hasNoContent`. Every production file must be free of debug print statements:

```dart title="test_arch/no_print_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('No print() calls in production code', (selector) {
    expect(
      selector.files(inFolder: 'lib'),
      hasNoContent(r'print\s*\('),
    );
  });
}
```

When the rule fails:

```
WARNING | No print() calls in production code
        | lib/data/repositories/cart_repository_impl.dart:42
        | File content matches: print\s*\(
```

---

### No hardcoded URLs

URLs hardcoded in source files are a configuration management problem — they can't be changed without recompiling and are invisible to configuration management systems:

```dart title="test_arch/no_hardcoded_urls_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArch('No hardcoded HTTP URLs in production code', (selector) {
    expect(
      selector.files(inFolder: 'lib'),
      hasNoContent(
        r'https?://[^\s\'"]+',
        description: 'contains a hardcoded URL',
      ),
    );
  });
}
```

---

### Comprehensive code quality rules

Ban multiple problematic patterns in a single group:

```dart title="test_arch/code_quality_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() {
  testArchGroup('Code quality rules', () {
    testArch('No print() calls', (selector) {
      expect(selector.files(inFolder: 'lib'), hasNoContent(r'print\s*\('));
    });

    testArch('No debugPrint() calls', (selector) {
      expect(selector.files(inFolder: 'lib'), hasNoContent(r'debugPrint\s*\('));
    });

    testArch('No TODO comments', (selector) {
      expect(
        selector.files(inFolder: 'lib'),
        hasNoContent(r'//\s*TODO', description: 'contains a TODO comment'),
      );
    });

    testArch('No FIXME comments', (selector) {
      expect(
        selector.files(inFolder: 'lib'),
        hasNoContent(r'//\s*FIXME'),
      );
    });

    testArch('No hardcoded URLs', (selector) {
      expect(
        selector.files(inFolder: 'lib'),
        hasNoContent(r'https?://[^\s\'"]+', description: 'contains a hardcoded URL'),
      );
    });
  }, severity: RuleSeverity.warning);
}
```

---

## Notes

- The regex is matched against the **entire raw file content as a single string**. Multiline patterns and `^`/`$` anchors behave accordingly.
- Always use raw strings (`r'...'`) in Dart to avoid double-escaping backslashes.
- The `description` parameter in `hasContent` improves the violation message when your regex is complex. Use it to describe what the pattern detects in plain language.
- These matchers operate at the **file level** — use them with `selector.files()`, not `selector.classes()`.
- Files excluded via the `exceptions` parameter of `selector.files()` are not checked.

---

## Related matchers

- [`nameMatchesPattern`](/predicates/name-matches-pattern/) — regex match against class names
- [`doesNotDependOn`](/predicates/depend-on-folder/) — check import statements at the structural level
- [`hasAnnotation`](/predicates/annotated-with/) — check annotations at the class level
