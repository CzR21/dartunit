# MaxFieldsPredicate — Test Plan

## Purpose
Passes if the class has at most `maxFields` fields (count <= max).

## Valid Cases (passes)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | No fields, max = 5 | `fields: []` |
| 2 | Count equals max | 3 fields, max = 3 |
| 3 | Count below max | 2 fields, max = 10 |
| 4 | Max = 0, no fields | `fields: []`, `MaxFieldsPredicate(0)` |
| 5 | Single field, max = 1 | 1 field, max = 1 |
| 6 | Large max | 15 fields, max = 100 |

## Invalid Cases (fails)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | Count exceeds max | 3 fields, max = 2 |
| 2 | One over max | 4 fields, max = 3 |
| 3 | Class name in message | Verify |
| 4 | "maximum allowed" in message | Verify message format |
| 5 | Max = 0, 1 field | 1 field exceeds max of 0 |
| 6 | Actual count and max in message | `9 fields — maximum allowed is 5` |

## Edge Cases
- Count includes ALL fields (static, final, mutable)
- Equality (count == max) passes

## Notes
- Message format: `ClassName has N fields — maximum allowed is M`
