# classSizeLimit Preset — Test Plan

## Purpose
Limits the number of methods and/or fields per class.
Internally uses `MaxMethodsPredicate` and/or `MaxFieldsPredicate`.

## Test Approach
Test via `MaxMethodsPredicate` and `MaxFieldsPredicate` directly.

## Valid Cases (passes)
| # | Predicate | Scenario |
|---|-----------|----------|
| 1 | MaxMethods | Count within limit |
| 2 | MaxFields | Count within limit |
| 3 | MaxMethods | Count equals max |
| 4 | MaxFields | Count equals max |
| 5 | MaxMethods | No methods |
| 6 | Both | Class within both limits |

## Invalid Cases (fails)
| # | Predicate | Scenario |
|---|-----------|----------|
| 1 | MaxMethods | Count exceeds max |
| 2 | MaxFields | Count exceeds max |
| 3 | MaxMethods | Class name in message |
| 4 | MaxFields | "maximum allowed" in message |
| 5 | MaxMethods | Exactly one over |
| 6 | MaxFields | Zero max with fields |
