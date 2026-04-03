# NotAnnotatedWithPredicate — Test Plan

## Purpose
Passes if the subject class does NOT carry the given annotation name.
Designed for rules like "UI classes must not carry @injectable".

## Valid Cases (passes)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | Class has no annotations | `annotations: []` |
| 2 | Class has different annotation | `annotations: ['immutable']`, predicate: `'injectable'` |
| 3 | Forbidden annotation absent among others | `annotations: ['injectable', 'singleton']`, predicate: `'deprecated'` |
| 4 | Abstract class without forbidden annotation | `isAbstract: true, annotations: ['sealed']` |
| 5 | Similar casing — case sensitive mismatch | `annotations: ['Injectable']`, predicate: `'injectable'` |
| 6 | Empty annotation list | `annotations: []` |

## Invalid Cases (fails)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | Class has exactly the forbidden annotation | `annotations: ['injectable']` |
| 2 | Forbidden annotation among several | `annotations: ['injectable', 'deprecated']`, predicate: `'deprecated'` |
| 3 | Single forbidden annotation 'deprecated' | `annotations: ['deprecated']` |
| 4 | Abstract class with forbidden annotation | `isAbstract: true, annotations: ['injectable']` |
| 5 | Only the forbidden annotation present | `annotations: ['singleton']`, predicate: `'singleton'` |
| 6 | Failure message contains 'NOT' | verifies message format |

## Edge Cases
- Case sensitivity: `'Injectable'` does NOT match `'injectable'`
- Failure message contains `must NOT be annotated with @<annotation>`

## Notes
- This is the inverse of `AnnotatedWithPredicate`
- Useful for enforcing that UI or domain layers don't accidentally acquire DI annotations
