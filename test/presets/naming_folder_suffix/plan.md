# namingFolderSuffix Preset — Test Plan

## Purpose
Classes in each folder must end with the capitalised folder basename.
Example: `lib/service` → suffix `Service`.
Internally uses `NameEndsWithPredicate`.

## Valid Cases
| # | Scenario |
|---|----------|
| 1 | UserService in lib/service |
| 2 | UserRepository in lib/repository |
| 3 | AuthBloc in lib/bloc |
| 4 | UserCardWidget in lib/widget |
| 5 | Suffix equals class name |
| 6 | Abstract class with correct suffix |

## Invalid Cases
| # | Scenario |
|---|----------|
| 1 | Missing suffix |
| 2 | Wrong suffix |
| 3 | Class name in message |
| 4 | Case mismatch |
| 5 | Suffix in middle |
| 6 | "must end with" in message |
