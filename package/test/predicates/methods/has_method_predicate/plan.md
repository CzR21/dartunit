# HasMethodPredicate — Test Plan

## Purpose
Passes if the class declares a method with the exact required name.

## Valid Cases (passes)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | Method found | `methods: [method('fetchUser')]` |
| 2 | Method among several | `[load, save, delete]`, predicate: `'save'` |
| 3 | Private method match | `methods: [method('_validate')]` |
| 4 | Method named "build" | Flutter widget method |
| 5 | Single matching method | `methods: [method('execute')]` |
| 6 | Any return type | `method('getUser', returnType: 'Future<User>')` |

## Invalid Cases (fails)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | No methods | `methods: []` |
| 2 | Different methods | `[createUser, deleteUser]`, predicate: `'fetchUser'` |
| 3 | Class name in message | Verify class name |
| 4 | Method name in quotes in message | `"execute"` in message |
| 5 | Similar but not exact | `fetchUsers` doesn't match `fetchUser` |
| 6 | Empty methods list + message check | "must declare a method named" |

## Edge Cases
- Exact string equality on method name
- Return type is not considered

## Notes
- Message format: `ClassName must declare a method named "methodName"`
