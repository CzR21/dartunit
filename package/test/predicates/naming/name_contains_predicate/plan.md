# NameContainsPredicate — Test Plan

## Purpose
Passes if the subject's name contains the given substring (case-sensitive, uses `String.contains`).

## Valid Cases (passes)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | Substring in middle | `UserRepositoryImpl` contains `Repository` |
| 2 | Substring at start | `UserService` contains `User` |
| 3 | Substring at end | `UserService` contains `Service` |
| 4 | Substring equals full name | `Service` contains `Service` |
| 5 | Single char substring | `XmlParser` contains `X` |
| 6 | Substring appears multiple times | `UserUserHelper` contains `User` |

## Invalid Cases (fails)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | Substring absent | `UserService` doesn't contain `Repository` |
| 2 | Class name in message | Verify class name |
| 3 | Case mismatch | `service` vs `UserService` |
| 4 | Completely different name | `Repository` doesn't contain `ViewModel` |
| 5 | "must contain" in message | Verify format |
| 6 | Quoted substring in message | `"ViewModel"` in message |

## Notes
- Message format: `ClassName must contain "substring"`
- Case-sensitive substring matching via `String.contains`
