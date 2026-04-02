# noCircularDependencies Preset — Test Plan

## Purpose
No file in the project may participate in a circular import chain.
Internally uses `HasCircularDependencyPredicate`.

## Test Approach
Test via `HasCircularDependencyPredicate` directly with manually built `DependencyGraph`.

## Valid Cases (passes — no cycle)
| # | Scenario |
|---|----------|
| 1 | Empty graph |
| 2 | Subject not in any cycle |
| 3 | Linear chain |
| 4 | Cycle elsewhere, subject not in it |
| 5 | Outgoing edge but no cycle |

## Invalid Cases (fails — subject in cycle)
| # | Scenario |
|---|----------|
| 1 | Two-node cycle |
| 2 | Both nodes in cycle fail |
| 3 | Three-node cycle |
| 4 | Failure message contains subject name |
| 5 | Self-referential import |

## Notes
- Predicate PASSES when NOT in cycle (safe state)
- Predicate FAILS when IN a cycle (violation)
