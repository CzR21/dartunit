# noPublicFields Preset — Test Plan

## Purpose
Classes in specified folders must not expose public instance fields.
Internally uses `HasNoPublicFieldsPredicate`.

## Valid Cases
| # | Scenario |
|---|----------|
| 1 | No fields |
| 2 | All private fields |
| 3 | Only static fields |
| 4 | Private final fields |
| 5 | Mix of private and static |
| 6 | Empty fields list |

## Invalid Cases
| # | Scenario |
|---|----------|
| 1 | Single public field |
| 2 | Public among private |
| 3 | Class name in message |
| 4 | "public instance fields" in message |
| 5 | Public final field (final != private) |
| 6 | Multiple public fields |
