# layerCanOnlyDependOn Preset — Test Plan

## Purpose
Classes in a layer may ONLY import from the listed allowed folders.
Internally uses `OnlyDependOnFoldersPredicate`.

## Test Approach
Test via `OnlyDependOnFoldersPredicate` directly.

## Valid Cases
| # | Scenario |
|---|----------|
| 1 | No imports |
| 2 | All imports within allowed layers |
| 3 | Single import in allowed layer |
| 4 | Pure domain layer self-referencing |
| 5 | Imports matching multiple allowed layers |
| 6 | Same-layer import |

## Invalid Cases
| # | Scenario |
|---|----------|
| 1 | Domain imports from UI layer |
| 2 | One import outside allowed |
| 3 | "disallowed" in message |
| 4 | Bloc depending on UI |
| 5 | Allowed folders listed in message |
| 6 | All imports from forbidden layers |
