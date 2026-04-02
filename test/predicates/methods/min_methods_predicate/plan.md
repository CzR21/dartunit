# MinMethodsPredicate — Test Plan

## Purpose
Passes if the class has at least `minMethods` methods (count >= min).

## Valid Cases (passes)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | Count equals min | 2 methods, min = 2 |
| 2 | Count exceeds min | 3 methods, min = 2 |
| 3 | Min = 0, no methods | `methods: []`, min = 0 |
| 4 | Min = 0, several methods | Always passes |
| 5 | Min = 1, one method | 1 method, min = 1 |
| 6 | Large min satisfied | 10 methods, min = 5 |

## Invalid Cases (fails)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | No methods, min = 1 | `methods: []`, min = 1 |
| 2 | Count below min | 2 methods, min = 5 |
| 3 | Class name in message | Verify |
| 4 | "minimum required" in message | Verify format |
| 5 | Exactly one below min | 3 methods, min = 4 |
| 6 | Actual count and min in message | `1 methods — minimum required is 5` |

## Notes
- Message format: `ClassName has N methods — minimum required is M`
