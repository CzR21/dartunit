# mustBeAbstract Preset — Test Plan

## Purpose
All classes in specified folders must be declared `abstract`.
Internally uses `IsAbstractPredicate`.

## Valid Cases
| # | Scenario |
|---|----------|
| 1 | Repository interface is abstract |
| 2 | Use case is abstract |
| 3 | Abstract class with methods |
| 4 | Abstract with annotations |
| 5 | Abstract with implemented interfaces |
| 6 | Abstract marker interface (no members) |

## Invalid Cases
| # | Scenario |
|---|----------|
| 1 | Concrete repository implementation |
| 2 | Concrete class with methods |
| 3 | Class name in message |
| 4 | "must be abstract" in message |
| 5 | Mixin (not abstract by default) |
| 6 | Enum |
