# DependOnFolderPredicate — Test Plan

## Purpose
Passes if the class has at least one import that contains the given folder path as a substring.
This is a positive condition — it passes when the dependency IS found.
Use `NotPredicate(DependOnFolderPredicate(...))` to enforce "must NOT depend".

## Valid Cases (passes — dependency found)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | Single import matches folder | `imports: ['lib/data/user_dao.dart']`, folder: `'lib/data'` |
| 2 | One of multiple imports matches | Mixed imports, one from `lib/data` |
| 3 | Import contains folder as path prefix | `lib/data/repositories/user.dart` |
| 4 | Package URI import contains folder | `package:app/lib/domain/user.dart` |
| 5 | Pass message contains folder name | Result.message includes `lib/data` |
| 6 | Multiple imports match | Two imports both from `lib/data` |

## Invalid Cases (fails — no dependency found)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | No imports at all | `imports: []` |
| 2 | Imports don't contain folder | Only `lib/domain` imports |
| 3 | Similar but different path | `lib/database` instead of `lib/data` |
| 4 | Failure message contains class name | `PureClass does not depend on "lib/data"` |
| 5 | Completely unrelated import | `package:flutter/widgets.dart` |
| 6 | Empty imports list with message check | `does not depend on` in message |

## Edge Cases
- Folder matching is substring-based (using `String.contains`)
- `lib/data` would also match `lib/data_access` — this is by design

## Notes
- CRITICAL: This predicate PASSES when the dependency IS found (positive condition)
- Pair with `NotPredicate` to enforce "must NOT depend on folder"
- Pass message lists all matching imports for visibility
