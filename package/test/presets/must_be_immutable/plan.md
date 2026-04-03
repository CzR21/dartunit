# mustBeImmutable Preset — Test Plan

## Purpose
All instance fields of classes in specified folders must be `final`.
Internally uses `HasAllFinalFieldsPredicate`.

## Valid Cases
| # | Scenario |
|---|----------|
| 1 | Entity with all final fields |
| 2 | Value object with single final field |
| 3 | Entity with no instance fields |
| 4 | Only static fields (excluded) |
| 5 | Domain event with finals |
| 6 | Mix of final instance and static |

## Invalid Cases
| # | Scenario |
|---|----------|
| 1 | Mutable field present |
| 2 | Single mutable field |
| 3 | Class name in message |
| 4 | "mutable instance fields" in message |
| 5 | Multiple mutable fields |
| 6 | Mutable coexists with finals |
