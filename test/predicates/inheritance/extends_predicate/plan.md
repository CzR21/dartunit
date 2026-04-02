# ExtendsPredicate — Test Plan

## Purpose
Passes if the subject class extends the required type (exact string match on `extendedType`).

## Valid Cases (passes)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | Extends Flutter widget | `extendedType: 'StatelessWidget'` |
| 2 | Extends custom base class | `extendedType: 'BaseRepository'` |
| 3 | Extends ChangeNotifier | `extendedType: 'ChangeNotifier'` |
| 4 | Abstract class extends base | `isAbstract: true, extendedType: 'AbstractMapper'` |
| 5 | Exact match | `extendedType: 'ValueNotifier'` |

## Invalid Cases (fails)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | Extends nothing (null) | `extendedType: null` — message says "nothing" |
| 2 | Extends different type | `extendedType: 'StatefulWidget'`, expects `'StatelessWidget'` |
| 3 | Class name in message | Verify class name |
| 4 | Required type in message | Verify expected type name |
| 5 | Null extendedType message says "nothing" | Message: "currently extends: nothing" |
| 6 | Case mismatch | `extendedType: 'statelessWidget'` vs `'StatelessWidget'` |

## Edge Cases
- Comparison is exact string equality
- `extendedType: null` produces message "currently extends: nothing"

## Notes
- Message format: `ClassName must extend TypeName (currently extends: X or nothing)`
