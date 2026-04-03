# MaxMethodsPredicate — Test Plan

## Purpose
Passes if the class has at most `maxMethods` methods (count <= max).

## Valid Cases (passes)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | No methods | `methods: []` |
| 2 | Count equals max | 3 methods, max = 3 |
| 3 | Count below max | 2 methods, max = 10 |
| 4 | Max = 0, no methods | `MaxMethodsPredicate(0)`, `methods: []` |
| 5 | Single method, max = 1 | 1 method, max = 1 |
| 6 | Large max | 20 methods, max = 100 |

## Invalid Cases (fails)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | Count exceeds max | 3 methods, max = 2 |
| 2 | One over max | 4 methods, max = 3 |
| 3 | Class name in message | Verify |
| 4 | "maximum allowed" in message | Verify format |
| 5 | Max = 0, class has methods | 1 method exceeds max of 0 |
| 6 | Actual count and max in message | `9 methods — maximum allowed is 5` |

## Notes
- Message format: `ClassName has N methods — maximum allowed is M`
