# IsExtensionPredicate — Test Plan

## Purpose
Passes if `cls.isExtension == true`.

## Valid Cases
| # | Scenario | Setup |
|---|----------|-------|
| 1 | Simple extension | `isExtension: true` |
| 2 | Extension with typical name | `DateTimeExtension` |
| 3 | Extension with annotations | `isExtension: true, annotations: ['deprecated']` |
| 4 | Extension with methods | `isExtension: true, methods: [...]` |
| 5 | Other flags false, isExtension true | `isExtension: true` |

## Invalid Cases
| # | Scenario | Setup |
|---|----------|-------|
| 1 | Regular class | `isExtension: false` (default) |
| 2 | Abstract class | `isAbstract: true` |
| 3 | Mixin | `isMixin: true` |
| 4 | Enum | `isEnum: true` |
| 5 | Class name in message | Verify |
| 6 | "must be declared as an extension" in message | Verify |

## Notes
- Message format: `ClassName must be declared as an extension`
