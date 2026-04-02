# DependOnPackagePredicate — Test Plan

## Purpose
Passes if the class has at least one import starting with `package:<packageName>/`.
Useful for detecting external package usage, positive condition.

## Valid Cases (passes)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | Single import from the package | `imports: ['package:flutter/material.dart']` |
| 2 | One of multiple imports matches | Mixed imports including target package |
| 3 | Deep path within package | `package:dio/src/dio.dart` |
| 4 | Pass message contains package name | Verify message format |
| 5 | Package with underscore | `shared_preferences` |
| 6 | Multiple imports from same package | Two `package:rxdart/` imports |

## Invalid Cases (fails)
| # | Scenario | Setup |
|---|----------|-------|
| 1 | No imports | `imports: []` |
| 2 | Imports from different packages | Only `package:http/` when looking for `dio` |
| 3 | Package name is prefix of another | `http` vs `http_parser` — correctly fails |
| 4 | Failure message contains class name | Verify class name in message |
| 5 | Relative path without `package:` | `flutter/material.dart` (no scheme) |
| 6 | Empty imports, informative message | `does not import from package` |

## Edge Cases
- Prefix matching: `package:http/` must start exactly, so `http_parser` is not confused with `http`
- Only `package:` URIs are matched, not relative paths

## Notes
- CRITICAL: This predicate PASSES when the dependency IS found (positive condition)
- Use `NotPredicate(DependOnPackagePredicate(...))` to enforce "must NOT use package"
- The `noExternalPackage` preset uses this via `doesNotDependOnPackage` matcher
