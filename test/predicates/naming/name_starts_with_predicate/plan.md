# NameStartsWithPredicate — Test Plan

## Purpose
Passes if the subject's name starts with the given prefix (case-sensitive, uses `String.startsWith`).

## Valid Cases (passes)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | Name starts with prefix | `AbstractRepository` starts with `Abstract` |
| 2 | Prefix equals full name | `User` starts with `User` |
| 3 | Single char prefix | `IRepository` starts with `I` |
| 4 | Underscore prefix | `_PrivateHelper` starts with `_` |
| 5 | Multi-word prefix | `BaseUseCase` starts with `Base` |
| 6 | Exact match | `MyClass` starts with `My` |

## Invalid Cases (fails)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | Prefix not present at start | `UserRepository` doesn't start with `Abstract` |
| 2 | Class name in message | Verify class name |
| 3 | Case mismatch | `abstract` vs `AbstractRepo` |
| 4 | Prefix in middle | `AbstractBase` doesn't start with `Base` |
| 5 | Prefix at end | `ServiceBase` doesn't start with `Base` |
| 6 | "must start with" in message | Verify message format |

## Notes
- Message format: `ClassName must start with "prefix"`
