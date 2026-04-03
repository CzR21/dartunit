# AndPredicate — Test Plan

## Purpose
Passes only when ALL inner predicates pass (logical AND with short-circuit evaluation).

## Valid Cases (passes)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | Both predicates pass | `NameEndsWith('Service')` + `AnnotatedWith('injectable')`, both satisfied |
| 2 | Single predicate passes | One predicate in list, passing |
| 3 | Three predicates all pass | Three naming + annotation predicates all satisfied |
| 4 | Abstract + naming both pass | `IsAbstract` + `NameEndsWith('Repository')`, abstract class ending in Repository |
| 5 | Two naming predicates both satisfied | `NameStartsWith` + `NameContains` both match |
| 6 | Empty predicates list | No predicates → always passes |

## Invalid Cases (fails)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | First predicate fails | Wrong suffix, correct annotation |
| 2 | Second predicate fails | Correct suffix, missing annotation |
| 3 | Both fail — first failure returned | Short-circuit: message from first failing predicate |
| 4 | Middle of three fails | First and last pass, middle fails |
| 5 | Concrete class fails IsAbstractPredicate | `isAbstract: false`, predicate requires abstract |
| 6 | Short-circuit behavior | First fails → second not evaluated (message confirms) |

## Edge Cases
- Empty list always passes
- Short-circuit: once a predicate fails, remaining are not evaluated
- The returned failure is the message from the first failing predicate

## Notes
- Use when a class must simultaneously satisfy multiple conditions
- Order matters for short-circuit — put cheapest/most-selective predicates first
