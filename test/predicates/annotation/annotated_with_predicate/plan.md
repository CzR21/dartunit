# AnnotatedWithPredicate — Test Plan

## Purpose
Passes if the subject class carries the given annotation name (without the leading `@`).

## Valid Cases (passes)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | Annotation exactly matches | `annotations: ['immutable']`, predicate: `'immutable'` |
| 2 | Multiple annotations, target present | `annotations: ['injectable', 'singleton']`, predicate: `'injectable'` |
| 3 | Annotation named 'override' | `annotations: ['override']` |
| 4 | Annotation named 'deprecated' | `annotations: ['deprecated']` |
| 5 | Only one annotation in list | `annotations: ['entity']` |
| 6 | Abstract class with matching annotation | `isAbstract: true, annotations: ['sealed']` |

## Invalid Cases (fails)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | No annotations at all | `annotations: []` |
| 2 | Different annotation present | `annotations: ['injectable']`, predicate: `'immutable'` |
| 3 | Annotation is substring, not exact | `annotations: ['mutable']`, predicate: `'immutable'` |
| 4 | Case mismatch | `annotations: ['immutable']`, predicate: `'Immutable'` |
| 5 | Abstract class missing required annotation | `isAbstract: true, annotations: ['injectable']`, predicate: `'sealed'` |
| 6 | Empty annotations list | `annotations: []`, any predicate |

## Edge Cases
- Case sensitivity is strict (exact string match via `List.contains`)
- Substring containment does not trigger a pass

## Notes
- The annotation name is passed without the leading `@`
- Failure message includes the class name and `@annotationName`
