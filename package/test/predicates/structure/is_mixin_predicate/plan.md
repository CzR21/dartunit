# IsMixinPredicate — Test Plan

## Purpose
Passes if `cls.isMixin == true`.

## Valid Cases
| # | Scenario | Setup |
|---|----------|-------|
| 1 | Simple mixin | `isMixin: true` |
| 2 | Mixin with typical name | `DisposableMixin` |
| 3 | Mixin with methods | `isMixin: true, methods: [method('log')]` |
| 4 | Mixin with annotations | `isMixin: true, annotations: ['deprecated']` |
| 5 | Other flags false, isMixin true | `isMixin: true` |

## Invalid Cases
| # | Scenario | Setup |
|---|----------|-------|
| 1 | Regular class | `isMixin: false` |
| 2 | Abstract class | `isAbstract: true` |
| 3 | Enum | `isEnum: true` |
| 4 | Extension | `isExtension: true` |
| 5 | Class name in message | Verify |
| 6 | "must be declared as a mixin" in message | Verify |

## Notes
- Message format: `ClassName must be declared as a mixin`
