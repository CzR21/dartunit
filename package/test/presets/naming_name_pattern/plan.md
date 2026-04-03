# namingNamePattern Preset — Test Plan

## Purpose
Classes in each folder must have names matching a regex pattern.
Internally uses `NameMatchesPatternPredicate`.

## Valid Cases
| # | Scenario |
|---|----------|
| 1 | Bloc/Cubit pattern — Bloc |
| 2 | Bloc/Cubit pattern — Cubit |
| 3 | Abstract prefix pattern |
| 4 | Versioned entity pattern |
| 5 | Simple literal pattern |
| 6 | Anchored exact match |

## Invalid Cases
| # | Scenario |
|---|----------|
| 1 | Name doesn't match Bloc/Cubit |
| 2 | Name doesn't match abstract prefix |
| 3 | Pattern in message |
| 4 | Anchored pattern fails substring |
| 5 | "must match pattern" in message |
| 6 | Case-sensitive mismatch |
