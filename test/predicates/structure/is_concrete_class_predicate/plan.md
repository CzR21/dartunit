# IsConcreteClassPredicate — Test Plan

## Purpose
Passes if the class is concrete: not abstract, not a mixin, not an enum, not an extension.

## Valid Cases (passes)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | Plain class | All flags false (default) |
| 2 | Concrete with members | `methods` and `fields` present |
| 3 | Concrete with implements | `implementedTypes: ['UserRepo']` |
| 4 | Concrete with extends | `extendedType: 'BaseService'` |
| 5 | All structural flags false | `isAbstract: false, isMixin: false, isEnum: false, isExtension: false` |

## Invalid Cases (fails)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | Abstract class | `isAbstract: true` |
| 2 | Mixin | `isMixin: true` |
| 3 | Enum | `isEnum: true` |
| 4 | Extension | `isExtension: true` |
| 5 | Class name in message | Verify |
| 6 | "must be a concrete class" in message | Verify format |

## Notes
- Message format: `ClassName must be a concrete class (not abstract, mixin, enum, or extension)`
