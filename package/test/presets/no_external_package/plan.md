# noExternalPackage Preset — Test Plan

## Purpose
Classes in specified folders must not import any of the listed packages.
Internally uses `NotPredicate(DependOnPackagePredicate(pkg))`.

## Valid Cases (passes — package not imported)
| # | Scenario |
|---|----------|
| 1 | No imports at all |
| 2 | Only allowed packages imported |
| 3 | Only internal imports |
| 4 | Similar package name but not exact |
| 5 | Empty imports list |
| 6 | Relative path (no `package:` scheme) |

## Invalid Cases (fails — forbidden package imported)
| # | Scenario |
|---|----------|
| 1 | Forbidden http package imported |
| 2 | Forbidden dio package imported |
| 3 | Package name in failure message |
| 4 | Forbidden package among others |
| 5 | Deep path from forbidden package |
| 6 | Failure message is non-empty |
