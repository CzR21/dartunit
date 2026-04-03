# layerCannotDependOn Preset — Test Plan

## Purpose
Classes in a layer must NOT import from listed forbidden layers.
Internally uses `NotPredicate(DependOnFolderPredicate(target))`.

## Test Approach
Test via `NotPredicate(DependOnFolderPredicate(...))` directly.

## Valid Cases (passes — no forbidden imports)
| # | Scenario |
|---|----------|
| 1 | Domain class, no data imports |
| 2 | No imports at all |
| 3 | Only domain imports |
| 4 | Imports from shared, not forbidden |
| 5 | Imports avoid UI layer |
| 6 | Multiple clean imports |

## Invalid Cases (fails — forbidden import found)
| # | Scenario |
|---|----------|
| 1 | Domain imports from data layer |
| 2 | Domain imports from UI layer |
| 3 | Folder in failure message |
| 4 | One bad import among clean ones |
| 5 | Matches import path substring |
| 6 | Inner pass message reused as violation detail |
