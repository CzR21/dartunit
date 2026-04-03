# HasNoPublicFieldsPredicate — Test Plan

## Purpose
Passes when the class has no public instance fields.
Public = non-static AND name does not start with `_`.

## Valid Cases (passes)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | No fields | `fields: []` |
| 2 | All private fields | `_name`, `_email` |
| 3 | Only static fields | `staticField('instance')` |
| 4 | Public static field (excluded) | `isStatic: true, name: 'shared'` |
| 5 | Mix of private and static | `_repo`, `_cache`, static `instance` |
| 6 | Single private field | `_value` |

## Invalid Cases (fails)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | Single public instance field | `AnalyzedField(name: 'name')` |
| 2 | One public among private | `_private` + `publicField` |
| 3 | Class name in message | Verify class name |
| 4 | "public instance fields" in message | Verify message format |
| 5 | Multiple public fields listed | `x`, `y` both in message |
| 6 | Public final field (final != private) | `finalField('name')` is still public |

## Edge Cases
- Static fields are excluded regardless of name visibility
- `final` fields are NOT automatically private — a `final name` is still public
- Privacy is determined solely by `_` prefix

## Notes
- Used by `noPublicFields` preset
- Message format: `ClassName exposes public instance fields: a, b`
