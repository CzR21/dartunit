# IsEnumPredicate — Test Plan

## Purpose
Passes if `cls.isEnum == true`.

## Valid Cases
| # | Scenario | Setup |
|---|----------|-------|
| 1 | Simple enum | `isEnum: true` |
| 2 | Enum with typical name | `UserStatus, isEnum: true` |
| 3 | Enum with annotations | `isEnum: true, annotations: ['deprecated']` |
| 4 | Enum in specific path | `filePath: 'lib/core/priority.dart'` |
| 5 | Other flags false, isEnum true | `isEnum: true, isAbstract: false` |

## Invalid Cases
| # | Scenario | Setup |
|---|----------|-------|
| 1 | Regular class | `isEnum: false` (default) |
| 2 | Abstract class | `isAbstract: true` |
| 3 | Mixin | `isMixin: true` |
| 4 | Class name in message | Verify |
| 5 | "must be declared as an enum" in message | Verify |
| 6 | Explicit false | `isEnum: false` |

## Notes
- Message format: `ClassName must be declared as an enum`
