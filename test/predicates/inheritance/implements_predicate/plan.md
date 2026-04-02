# ImplementsPredicate — Test Plan

## Purpose
Passes if the subject class implements the required interface (exact match in `implementedTypes` list).

## Valid Cases (passes)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | Single implementation matches | `implementedTypes: ['UserRepository']` |
| 2 | Required type among multiple | `implementedTypes: ['Entity', 'Serializable']`, predicate: `'Serializable'` |
| 3 | Abstract class implements | `isAbstract: true, implementedTypes: ['Repository']` |
| 4 | Only one interface, matches | `implementedTypes: ['Comparable']` |
| 5 | With other interfaces | `['Disposable', 'Loggable']`, predicate: `'Disposable'` |

## Invalid Cases (fails)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | Empty implementedTypes | `implementedTypes: []` |
| 2 | Different interfaces | `['Loggable', 'Disposable']`, predicate: `'UserRepository'` |
| 3 | Class name in message | Verify class name |
| 4 | Required interface in message | Verify interface name in message |
| 5 | Empty list fails | No interfaces |
| 6 | Substring not exact match | `['Repository']` doesn't match `'UserRepository'` |

## Edge Cases
- Uses `List.contains` — exact string equality
- `implementedTypes: null` is not possible given the helper default is `[]`

## Notes
- Message format: `ClassName must implement InterfaceName`
