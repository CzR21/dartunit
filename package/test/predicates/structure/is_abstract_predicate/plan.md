# IsAbstractPredicate — Test Plan

## Purpose
Passes if `cls.isAbstract == true`.

## Valid Cases (passes)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | Abstract class | `isAbstract: true` |
| 2 | Abstract with methods | `isAbstract: true, methods: [...]` |
| 3 | Abstract with annotations | `isAbstract: true, annotations: ['sealed']` |
| 4 | Abstract with implements | `isAbstract: true, implementedTypes: [...]` |
| 5 | Abstract with no members | `isAbstract: true` |

## Invalid Cases (fails)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | Concrete class | `isAbstract: false` (default) |
| 2 | Class name in message | Verify class name |
| 3 | Concrete with methods | `isAbstract: false, methods: [...]` |
| 4 | Mixin | `isMixin: true` (not abstract) |
| 5 | Enum | `isEnum: true` |
| 6 | "must be abstract" in message | Verify format |

## Notes
- Message format: `ClassName must be abstract`
- Mixin and enum flags don't set `isAbstract`
