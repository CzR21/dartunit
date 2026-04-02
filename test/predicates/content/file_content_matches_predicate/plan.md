# FileContentMatchesPredicate — Test Plan

## Purpose
Passes if the file's raw source content matches the given regex pattern.
Designed for file-level subjects (AnalyzedFile), not class subjects.

## Valid Cases (passes)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | Pattern found in file | File contains `print(...)`, pattern `print\s*\(` |
| 2 | Multiline content match | File has class definition, pattern matches class keyword |
| 3 | With description — message uses description | `description: 'uses debugPrint()'` |
| 4 | Literal string match | File contains 'TODO', pattern 'TODO' |
| 5 | Pattern matches at end of file | File ends with 'GENERATED', pattern 'GENERATED' |
| 6 | Pass message uses file name when no description | Verify message contains pattern |

## Invalid Cases (fails)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | Pattern not found in file | File has no `print()`, pattern `print\s*\(` |
| 2 | Empty file | Empty content, any pattern |
| 3 | File does not contain TODO | No TODO comment present |
| 4 | Non-existent file path | `Could not read file` error message |
| 5 | Case-sensitive mismatch | File has 'todo', pattern 'TODO' |
| 6 | Failure message contains pattern name | Message includes the pattern string |

## Edge Cases
- File is read from disk at analysis time
- Non-existent files → catch block returns fail with "Could not read file"
- Case sensitivity follows standard RegExp (case-sensitive by default)

## Notes
- Uses `AnalyzedFile` as subject element, not `AnalyzedClass`
- Pair with `NotPredicate` to ban patterns (e.g., no `print()` calls)
- Pattern is compiled once at construction time
