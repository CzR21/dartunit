# NotPredicate — Test Plan

## Purpose
Passes when the inner predicate FAILS (logical negation).
When the inner predicate passes, this predicate fails and reuses the inner's pass message as the violation detail.

## Valid Cases (passes — inner predicate fails)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | Inner AnnotatedWith fails — no annotation | Class has no annotations |
| 2 | Inner NameEndsWith fails — wrong suffix | Class ends with 'Repository' not 'Service' |
| 3 | Inner IsAbstract fails — concrete class | `isAbstract: false` |
| 4 | Inner IsMixin fails — plain class | `isMixin: false` |
| 5 | Inner DependOnFolder fails — no matching imports | Class imports from domain only |
| 6 | Inner AnnotatedWith fails — empty annotations | `annotations: []` |

## Invalid Cases (fails — inner predicate passes)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | Inner AnnotatedWith passes — annotation present | `annotations: ['injectable']` |
| 2 | Inner NameEndsWith passes — correct suffix | Class ends with 'Service' |
| 3 | Inner IsAbstract passes — abstract class | `isAbstract: true` |
| 4 | Inner DependOnFolder passes — matching import found | `imports: ['lib/data/repo.dart']` |
| 5 | Failure message reuses inner's pass message | DependOnFolderPredicate pass message used as violation |
| 6 | Failure message non-empty when inner pass message empty | Fallback to "must NOT satisfy" message |

## Edge Cases
- When inner pass message is empty (const PredicateResult.pass()), the fallback message is used
- When inner pass message is non-empty (e.g., DependOnFolderPredicate), it is reused as the violation detail

## Notes
- Key tool for enforcement rules like "domain must NOT depend on data"
- The reuse of inner pass messages produces informative violation details
