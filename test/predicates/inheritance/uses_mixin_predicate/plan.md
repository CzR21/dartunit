# UsesMixinPredicate — Test Plan

## Purpose
Passes if the subject class uses the required mixin (exact match in `mixinTypes` list).

## Valid Cases (passes)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | Single mixin matches | `mixinTypes: ['EquatableMixin']` |
| 2 | Required mixin among several | `mixinTypes: ['DisposableMixin', 'LoggingMixin']` |
| 3 | Abstract class with mixin | `isAbstract: true, mixinTypes: ['Comparable']` |
| 4 | Single mixin, exact match | `mixinTypes: ['ChangeNotifierMixin']` |
| 5 | Mixin named 'Mixin' | `mixinTypes: ['Mixin']` |

## Invalid Cases (fails)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | No mixins | `mixinTypes: []` |
| 2 | Different mixins used | `['LoggingMixin']`, predicate: `'EquatableMixin'` |
| 3 | Class name in message | Verify class name |
| 4 | Required mixin in message | Message contains "mixin EquatableMixin" |
| 5 | Empty mixinTypes | `mixinTypes: []` |
| 6 | Substring not matching | `['Equatable']` doesn't match `'EquatableMixin'` |

## Edge Cases
- Uses `List.contains` — exact string equality

## Notes
- Message format: `ClassName must use mixin MixinName`
