# OnlyDependOnFoldersPredicate — Test Plan

## Purpose
Passes if ALL class imports are within the given allowed folders.
Any import not matching any allowed folder is a violation.

## Valid Cases (passes)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | No imports | `imports: []` with any allowed list |
| 2 | All imports in single allowed folder | `imports: ['lib/domain/x.dart']`, allowed: `['lib/domain']` |
| 3 | Imports span multiple allowed folders | Domain + shared imports, both allowed |
| 4 | Single import in first of two allowed | `lib/data/dao.dart`, allowed: `['lib/data', 'lib/domain']` |
| 5 | Empty allowed folders and no imports | Both empty — technically passes |
| 6 | Deep path within allowed folder | `lib/domain/entities/user.dart` with `lib/domain` allowed |

## Invalid Cases (fails)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | Import from forbidden folder | `lib/data/dao.dart` when only `lib/domain` allowed |
| 2 | One forbidden among multiple | Mixed good/bad imports |
| 3 | Class name in failure message | Verify class name in message |
| 4 | Message contains "disallowed locations" | Verify message format |
| 5 | Empty allowed folders with any import | No folders allowed, class has imports |
| 6 | Allowed folders listed in message | Failure message shows `Allowed: lib/domain, lib/shared` |

## Edge Cases
- Matching is substring-based: `lib/domain` matches `lib/domain/entities/user.dart`
- Empty allowed list means absolutely no imports are permitted

## Notes
- Used by `layerCanOnlyDependOn` preset
- Message format: `ClassName imports from disallowed locations:\n  <paths>\nAllowed: <list>`
