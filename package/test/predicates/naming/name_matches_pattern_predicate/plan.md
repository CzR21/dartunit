# NameMatchesPatternPredicate — Test Plan

## Purpose
Passes if the subject's name matches the given regex pattern (uses `RegExp.hasMatch`).

## Valid Cases (passes)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | OR pattern — first alternative | `UserBloc` matches `.*(Bloc|Cubit)$` |
| 2 | OR pattern — second alternative | `UserCubit` matches `.*(Bloc|Cubit)$` |
| 3 | Prefix anchor | `AbstractRepository` matches `^Abstract.*` |
| 4 | Wildcard pattern | `UserService` matches `User\w+` |
| 5 | Literal substring pattern | `UserService` matches `Service` |
| 6 | Exact anchored match | `UserRepository` matches `^UserRepository$` |

## Invalid Cases (fails)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | Name not matching | `UserViewModel` fails `.*(Bloc|Cubit)$` |
| 2 | Pattern in message | Failure message contains pattern string |
| 3 | Anchored pattern partial | `UserRepositoryImpl` fails `^UserRepository$` |
| 4 | "must match pattern" in message | Verify format |
| 5 | Case-sensitive mismatch | `service` pattern vs `UserService` |
| 6 | Anchored exact: substring fails | `UserRepository` fails `^Repository$` |

## Edge Cases
- `RegExp.hasMatch` — returns true if pattern matches anywhere in name unless anchored
- Case-sensitive by default; use `(?i)` flag for case-insensitive

## Notes
- Pattern is compiled once at construction time
- Message format: `ClassName must match pattern "pattern"`
