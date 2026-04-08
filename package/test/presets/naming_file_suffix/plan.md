# namingFileSuffix Preset — Test Plan

## Purpose
Files in each folder must end with a suffix derived from the folder basename in
snake_case (e.g. `lib/services` → `_services.dart`).
Supports explicit `suffix`, `prefix`, and raw `namePattern` overrides.
Internally uses `NameMatchesPatternPredicate`.

## Valid Cases
| # | Scenario |
|---|----------|
| 1 | user_service.dart in lib/services (auto-suffix) |
| 2 | user_repository.dart in lib/repositories (auto-suffix) |
| 3 | auth_bloc.dart in lib/bloc (auto-suffix) |
| 4 | Explicit suffix override (_service) |
| 5 | Prefix + suffix combination |
| 6 | Raw namePattern override |
| 7 | File name equals suffix only |

## Invalid Cases
| # | Scenario |
|---|----------|
| 1 | Wrong suffix (helper instead of service) |
| 2 | Suffix appears in middle of name |
| 3 | Case mismatch on suffix |
| 4 | Missing suffix entirely |
| 5 | File name in violation message |
| 6 | Explicit suffix — wrong file name |
| 7 | Prefix present but suffix missing |
