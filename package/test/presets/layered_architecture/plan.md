# layeredArchitecture Preset — Test Plan

## Purpose
Declares layers with allowed dependencies and generates forbidden-pair rules automatically.
Uses `OnlyDependOnFoldersPredicate` and `NotPredicate(DependOnFolderPredicate(...))`.

## Test Approach
Test via the underlying predicates: `OnlyDependOnFoldersPredicate` and `NotPredicate(DependOnFolderPredicate(...))`.

## Valid Cases
| # | Scenario |
|---|----------|
| 1 | Domain class only imports from domain |
| 2 | UI allowed to import from bloc |
| 3 | Bloc allowed to import from domain |
| 4 | Data allowed to import from domain interfaces |
| 5 | Domain not depending on data |
| 6 | Domain not depending on UI |

## Invalid Cases
| # | Scenario |
|---|----------|
| 1 | Domain imports data (forbidden) |
| 2 | Domain imports UI (forbidden) |
| 3 | Data imports UI (forbidden) |
| 4 | Bloc imports data (forbidden) |
| 5 | UI imports data (skips architecture) |
| 6 | Failure shows disallowed import path |
