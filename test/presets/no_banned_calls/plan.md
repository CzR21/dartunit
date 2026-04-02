# noBannedCalls Preset — Test Plan

## Purpose
Files must not contain any of the listed regex patterns.
Internally uses `NotPredicate(FileContentMatchesPredicate(pattern))`.

## Test Approach
Test via `NotPredicate(FileContentMatchesPredicate(...))` with real temp files.

## Valid Cases (passes — pattern not found)
| # | Scenario |
|---|----------|
| 1 | File has no print() |
| 2 | File has no debugPrint() |
| 3 | File has no TODO comments |
| 4 | Empty file |
| 5 | File uses logger, not print |

## Invalid Cases (fails — pattern found)
| # | Scenario |
|---|----------|
| 1 | File contains print() |
| 2 | File contains debugPrint() |
| 3 | File has TODO comment |
| 4 | print() in multiline file |
| 5 | Multiple occurrences still fails |

## Notes
- Uses real file I/O — requires temp directory
- Content-based: comments and strings are also matched
