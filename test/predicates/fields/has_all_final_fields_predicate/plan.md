# HasAllFinalFieldsPredicate — Test Plan

## Purpose
Passes when all instance fields are final or const (no mutable instance fields).
Static fields are excluded from the check.

## Valid Cases (passes)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | No fields | `fields: []` |
| 2 | All final fields | `[finalField('name'), finalField('email')]` |
| 3 | Only static fields | `[staticField('instance')]` |
| 4 | Mix of final and static | `[finalField('id'), staticField('count')]` |
| 5 | Const field only | `AnalyzedField(isConst: true)` |
| 6 | Single final field | `[finalField('x')]` |

## Invalid Cases (fails)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | Single mutable field | `[mutableField('name')]` |
| 2 | One mutable among finals | `[finalField('id'), mutableField('name')]` |
| 3 | Class name in message | Verify class name |
| 4 | "mutable instance fields" in message | Verify message format |
| 5 | Multiple mutable fields listed | All mutable field names in message |
| 6 | Mutable among final and static | Only the mutable one triggers failure |

## Edge Cases
- Static fields (`isStatic: true`) are excluded from the mutable check
- Const fields (`isConst: true`) are excluded too
- The condition is: `!isStatic && !isFinal && !isConst` → mutable

## Notes
- Used by `mustBeImmutable` preset
- Message format: `ClassName has mutable instance fields: a, b`
