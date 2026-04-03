# NameEndsWithPredicate — Test Plan

## Purpose
Passes if the subject's name ends with the given suffix (case-sensitive, uses `String.endsWith`).

## Valid Cases (passes)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | Name ends with suffix | `UserRepository` ends with `Repository` |
| 2 | Suffix equals full name | `Service` ends with `Service` |
| 3 | Single char suffix | `Controller` ends with `r` |
| 4 | Flutter Widget suffix | `UserProfileWidget` ends with `Widget` |
| 5 | "Bloc" suffix | `UserBloc` ends with `Bloc` |
| 6 | "ViewModel" suffix | `LoginViewModel` ends with `ViewModel` |

## Invalid Cases (fails)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | Wrong suffix | `UserService` doesn't end with `Repository` |
| 2 | Class name in message | Verify |
| 3 | Case mismatch | `service` vs `UserService` |
| 4 | Suffix in middle | `ServiceWrapper` doesn't end with `Service` |
| 5 | Suffix at start | `ServiceBase` doesn't end with `Service` |
| 6 | "must end with" in message | Verify format |

## Notes
- Message format: `ClassName must end with "suffix"`
