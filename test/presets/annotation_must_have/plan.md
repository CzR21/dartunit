# annotationMustHave Preset — Test Plan

## Purpose
Enforces that all classes in specified folders carry a given annotation.
Internally uses `AnnotatedWithPredicate`.

## Test Approach
Test via `AnnotatedWithPredicate` directly since the preset is a thin wrapper.

## Valid Cases (passes — annotation present)
| # | Scenario |
|---|----------|
| 1 | Class has the required annotation |
| 2 | Annotation among multiple |
| 3 | @immutable on value object |
| 4 | @entity in domain layer |
| 5 | Abstract class with annotation |
| 6 | Any annotation that matches exactly |

## Invalid Cases (fails — annotation missing)
| # | Scenario |
|---|----------|
| 1 | Empty annotation list |
| 2 | Different annotation present |
| 3 | Case mismatch |
| 4 | No annotations at all |
| 5 | Substring match only |
| 6 | Class name and annotation in failure message |
