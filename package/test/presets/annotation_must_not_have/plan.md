# annotationMustNotHave Preset — Test Plan

## Purpose
Enforces that classes in specified folders do NOT carry a given annotation.
Internally uses `NotAnnotatedWithPredicate`.

## Test Approach
Test via `NotAnnotatedWithPredicate` directly.

## Valid Cases (passes — annotation absent)
| # | Scenario |
|---|----------|
| 1 | No annotations |
| 2 | Different annotations |
| 3 | UI class without DI annotation |
| 4 | Domain class without infrastructure annotation |
| 5 | Empty annotations list |
| 6 | Case mismatch (effectively absent) |

## Invalid Cases (fails — annotation present)
| # | Scenario |
|---|----------|
| 1 | Forbidden annotation present |
| 2 | Forbidden among multiple |
| 3 | UI class with DI annotation |
| 4 | Class name in message |
| 5 | "NOT" in message |
| 6 | Only forbidden annotation |
