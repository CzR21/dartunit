# MaxImportsPredicate — Test Plan

## Purpose
Passes if the class has at most `maxImports` imports (count <= max).

## Valid Cases (passes)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | No imports, max = 5 | `imports: []`, `MaxImportsPredicate(5)` |
| 2 | Import count equals max | 3 imports, max = 3 |
| 3 | Import count below max | 2 imports, max = 10 |
| 4 | Max = 0, no imports | `imports: []`, `MaxImportsPredicate(0)` |
| 5 | Exactly 1 import, max = 1 | 1 import, max = 1 |
| 6 | Large max, many imports | 20 imports, max = 100 |

## Invalid Cases (fails)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | Import count exceeds max | 3 imports, max = 2 |
| 2 | One over max | 4 imports, max = 3 |
| 3 | Class name in failure message | Verify class name present |
| 4 | Actual count and max in message | `8 imports — maximum allowed is 5` |
| 5 | Max = 0, 1 import | 1 import exceeds max of 0 |
| 6 | Message contains "maximum allowed" | Verify message format |

## Edge Cases
- Equality (count == max) passes
- Max = 0 is valid and means no imports allowed

## Notes
- Count is `cls.imports.length`, includes all import strings
- Message format: `ClassName has N imports — maximum allowed is M`
