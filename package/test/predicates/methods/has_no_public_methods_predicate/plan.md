# HasNoPublicMethodsPredicate — Test Plan

## Purpose
Passes when all methods are private (name starts with `_`), or no methods exist.

## Valid Cases (passes)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | No methods | `methods: []` |
| 2 | All private | `[method('_doWork'), method('_validate')]` |
| 3 | Single private | `[method('_compute')]` |
| 4 | Multiple privates | `_step1`, `_step2`, `_step3` |
| 5 | Double underscore | `method('__init')` |
| 6 | Empty list | `methods: []` |

## Invalid Cases (fails)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | Single public method | `[method('fetchUser')]` |
| 2 | Public among privates | `[_private, publicMethod]` |
| 3 | Class name in message | Verify |
| 4 | "exposes public methods" in message | Verify message format |
| 5 | Multiple public methods listed | `create, read, update` in message |
| 6 | Public method any return type | `getAll: List<User>` still public |

## Edge Cases
- Privacy determined by `_` prefix only
- Return type does not affect public/private determination

## Notes
- Message format: `ClassName exposes public methods: a, b`
