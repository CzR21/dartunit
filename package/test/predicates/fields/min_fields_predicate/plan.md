# MinFieldsPredicate — Test Plan

## Purpose
Passes if the class has at least `minFields` fields (count >= min).

## Valid Cases (passes)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | Count equals min | 2 fields, min = 2 |
| 2 | Count exceeds min | 3 fields, min = 2 |
| 3 | Min = 0, no fields | `fields: []`, min = 0 |
| 4 | Min = 0, several fields | Always passes with min = 0 |
| 5 | Min = 1, one field | 1 field, min = 1 |
| 6 | Large min satisfied | 10 fields, min = 5 |

## Invalid Cases (fails)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | No fields, min = 1 | `fields: []`, min = 1 |
| 2 | Count below min | 2 fields, min = 5 |
| 3 | Class name in message | Verify |
| 4 | "minimum required" in message | Verify message format |
| 5 | Exactly one below min | 3 fields, min = 4 |
| 6 | Actual count and min in message | `1 fields — minimum required is 5` |

## Edge Cases
- Equality (count == min) passes
- Min = 0 always passes

## Notes
- Message format: `ClassName has N fields — minimum required is M`
