# HasCircularDependencyPredicate — Test Plan

## Purpose
Passes when the subject's file is NOT involved in any circular dependency.
Fails when the subject's file path appears in a detected cycle.

## Valid Cases (passes — no cycle involving the subject)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | Empty dependency graph | `emptyCtx()` |
| 2 | Subject not connected to graph | Graph has edges between b and c only |
| 3 | Linear chain, subject at root | a→b→c (no cycle) |
| 4 | Subject has outgoing edge, no cycle | a→b |
| 5 | Cycle exists elsewhere, subject not in it | b↔c cycle, subject is a |

## Invalid Cases (fails — subject is in a cycle)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | Two-node cycle, subject is node A | a→b, b→a |
| 2 | Two-node cycle, subject is node B | a→b, b→a |
| 3 | Three-node cycle | a→b→c→a, subject is b |
| 4 | Message contains "circular dependency" | verify message text |
| 5 | Self-referential import | a→a |

## Edge Cases
- File path normalization: backslashes are converted to forward slashes before lookup
- Subject is identified by `filePath`, not by class name

## Notes
- Predicate semantics: PASSES = no cycle (safe state), FAILS = cycle detected
- Use `NotPredicate(HasCircularDependencyPredicate())` with caution — see known issue in project
- Graph must be built with `DependencyGraph.addEdge(from, to)` before passing to context
