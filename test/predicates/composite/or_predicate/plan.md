# OrPredicate — Test Plan

## Purpose
Passes when AT LEAST ONE inner predicate passes (logical OR with short-circuit evaluation).
When all fail, the combined failure message lists all individual reasons.

## Valid Cases (passes — at least one inner predicate passes)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | First of two passes | `NameEndsWith('Bloc')` passes |
| 2 | Second of two passes | `NameEndsWith('Cubit')` passes |
| 3 | Both pass | Both naming predicates satisfied |
| 4 | Single predicate passes | One predicate list, predicate passes |
| 5 | Last of three passes | First two fail, last passes |
| 6 | First of three passes (short-circuit) | First passes immediately |

## Invalid Cases (fails — all inner predicates fail)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | Both predicates fail | Neither 'Bloc' nor 'Cubit' suffix |
| 2 | Message contains "None of the OR conditions" | Verify message format |
| 3 | Message includes all failure reasons | Both individual messages present |
| 4 | Single predicate fails | One predicate, does not pass |
| 5 | Three predicates all fail | All three conditions unmet |
| 6 | Combined message from all predicates | Both failure messages concatenated |

## Edge Cases
- Short-circuit: once one passes, remaining are not evaluated
- All failures are collected and combined in the failure message

## Notes
- Useful for "class must end with Bloc OR Cubit" type rules
- Failure message format: "None of the OR conditions were met:\n  <reasons>"
