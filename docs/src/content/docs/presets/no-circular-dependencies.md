---
title: noCircularDependencies
description: Detect files participating in circular import chains. Circular dependencies break testing isolation, increase change blast radius, and can cause runtime initialization errors.
sidebar:
  order: 8
---

`noCircularDependencies` analyzes the entire project's import graph and reports every file that participates in a circular import chain. It requires no configuration — by default it inspects all Dart files and flags any cycle it finds.

Circular dependencies are among the most structurally damaging problems a Dart codebase can accumulate. Unlike a failed test or a type error, they do not fail loudly at a single moment. They grow silently as import chains lengthen, and by the time they cause visible problems, they are deeply embedded in the architecture.

---

## What a circular dependency is

A circular dependency occurs when a set of files form a closed import loop. Every file in the loop depends on at least one other file in the same loop.

### The simplest case: two files

```
file_a.dart  imports  file_b.dart
file_b.dart  imports  file_a.dart
```

`file_a.dart` and `file_b.dart` cannot exist independently. Each one needs the other to be loaded before it can be loaded itself. There is no valid loading order.

### A three-file cycle

```
auth_bloc.dart       imports  auth_repository.dart
auth_repository.dart imports  auth_service.dart
auth_service.dart    imports  auth_bloc.dart
```

In this cycle, none of the three files can be analyzed, compiled, or tested without loading all three simultaneously. The cycle creates a single, indivisible compilation unit disguised as three separate files.

### Cycles through barrel files

Barrel files — `index.dart` or `exports.dart` that re-export multiple symbols — are particularly dangerous participants in cycles. One barrel file re-exporting twenty classes pulls all twenty classes into every cycle it participates in:

```
domain/index.dart       exports  cart_repository.dart, order_repository.dart, ...
data/cart_repository_impl.dart  imports  domain/index.dart
domain/cart_repository.dart     imports  data/cart_repository_impl.dart  ← bug
```

This cycle, created by one incorrect import in `cart_repository.dart`, now involves every class exported by `domain/index.dart`. A cycle between two files becomes a cycle between twenty files overnight.

### Cycles through inheritance

Circular dependencies are not always direct import chains. They can emerge through class inheritance and mixin composition:

```dart
// lib/a/type_a.dart
import 'package:myapp/b/type_b.dart';
class TypeA extends TypeB { ... }

// lib/b/type_b.dart
import 'package:myapp/a/type_a.dart';
class TypeB {
  TypeA createA() => TypeA();
}
```

Here the cycle is: `type_a.dart` → `type_b.dart` → `type_a.dart`. It was introduced by a convenient method on `TypeB` that should never have known about `TypeA`.

---

## Why circular dependencies are harmful

### Build and analysis tools assume a DAG

The Dart analyzer, the Dart compiler, and the flutter build tool all process files by walking the import graph. They assume the graph is a **Directed Acyclic Graph (DAG)** — a graph with no cycles. Every node (file) can be processed once its dependencies have been processed.

A cycle breaks this assumption:

- The analyzer may report spurious "undefined name" errors because it reaches a file in the cycle before the types it depends on have been resolved.
- The analyzer can enter an infinite resolution loop, causing it to hang or crash on large cycles.
- The Dart compiler's incremental build invalidation grows quadratically: a change to any file in a cycle invalidates the entire cycle.
- Flutter's hot reload can fail to apply changes correctly if the changed file is in a cycle that has not been fully reloaded.

These failures are often reported as "strange" analyzer errors that disappear when the project is cleaned and rebuilt. If your team regularly runs `flutter clean` to fix IDE errors, a cycle may be the underlying cause.

### Testing becomes impossible in isolation

Unit tests are fast because they isolate the unit under test from its dependencies. You mock the dependencies and test the unit alone.

A circular dependency makes isolation impossible at the file level. To test `AuthBloc`, you need `AuthRepository` to be loaded. But `AuthRepository` imports `AuthService`, which imports `AuthBloc`. To load `AuthBloc`, you need `AuthBloc` — which is what you are trying to test.

In practice, what happens is that developers write "unit tests" that actually instantiate the entire cycle. These are integration tests masquerading as unit tests: they are slow, they depend on external services, and they fail for reasons unrelated to the class being tested. When a mock is needed, the mock must implement all types in the cycle — a combinatorial explosion of setup code.

Teams with circular dependencies often abandon unit testing for the affected code entirely, citing difficulty in setup as the reason. The difficulty is architectural, not conceptual.

### The change blast radius grows

In a healthy DAG-shaped codebase, changing a file affects only the files that import it (directly or transitively). The blast radius is bounded by the shape of the dependency tree.

In a cycle, the blast radius is the entire cycle. Changing one line in `AuthBloc` may require coordinated changes to `AuthRepository` and `AuthService` — not because the change logically affects them, but because they are all compiled as a single unit. Code reviews for one class now review three files. Branch merges that affect the same cycle produce conflicts across all files in the cycle. What should be a contained, reviewable change becomes a sprawling, risky modification.

As cycles grow — from three files to five to ten — the blast radius grows with them. Large cycles are the reason some codebases have a rule "never change X without scheduling a team review" — the implicit acknowledgment that X is in a cycle and touching it is dangerous.

### Runtime initialization errors

Dart initializes static fields in import order. When module A is imported, its top-level variables and static fields are initialized. Then module B's statics are initialized. The order is determined by the import graph.

With a circular import, there is no valid initialization order. Dart's runtime resolves this with **late initialization**: when a module is encountered in a cycle, its static fields are initialized lazily, on first access.

This is fine for simple cases, but creates `LateInitializationError` when:

```dart
// file_a.dart
import 'file_b.dart';
final dependsOnB = B.value;  // initialized at module load time

// file_b.dart
import 'file_a.dart';
final String value = A.dependsOnB ?? 'default';  // also at module load time
```

When `file_a.dart` is loaded, it tries to initialize `dependsOnB`. To do so, it accesses `B.value`, which requires `file_b.dart` to be initialized first. But `file_b.dart` imports `file_a.dart`, creating a cycle. The runtime has to choose an order, and whichever file is initialized "second" will find the other's static fields in an uninitialized state.

The result is either a `LateInitializationError` at runtime (if a late field is read before assignment) or a silently incorrect `null` value (if a nullable field is read before it has been set). These bugs are particularly difficult to diagnose because they are non-deterministic: the initialization order can vary across platforms, build modes (debug vs release), and hot reload cycles.

### Barrel files amplify the problem

Barrel files are a common Flutter/Dart pattern for simplifying imports:

```dart
// lib/domain/index.dart
export 'repositories/cart_repository.dart';
export 'repositories/order_repository.dart';
export 'entities/cart.dart';
export 'entities/order.dart';
export 'usecases/get_cart_usecase.dart';
// ... 20 more exports
```

A barrel file's dependencies are the union of all its exported files' dependencies. When a barrel file participates in a cycle, every file it exports is part of that cycle.

Consider: `barrel.dart` exports `TypeA`. `TypeB` imports `barrel.dart` to use `TypeA`. Then `TypeA` imports `TypeB` for some reason. The cycle is `TypeA → TypeB → barrel.dart → TypeA`. But `barrel.dart` also exports `TypeC`, `TypeD`, `TypeE`. Now those files are also in the cycle — even though they have no logical relationship to the problem.

This is why a single misplaced import in a large codebase with barrel files can seemingly "corrupt" the entire architecture. DartUnit reports the cycle path, which shows you exactly how the barrel file is involved.

### Dead code removal suffers

Dart's tree-shaker removes code that is provably unreachable. It starts from the app entry point, follows all references, and removes everything not reached. The tree-shaker requires the dependency graph to be a DAG — it needs to determine which parts of each file are "used" by examining the file's callers.

In a cycle, every file in the cycle is mutually dependent. The tree-shaker cannot determine that any part of any file in the cycle is unused, because any part might be needed by any other part of the cycle. The entire cycle is retained in the output, even if 90% of it is dead code.

In a large app with significant cycle involvement, this increases the compiled binary size and slows down startup time.

---

## How DartUnit detects cycles

DartUnit reads every `.dart` file in the project and builds a directed dependency graph: each node is a file, and each edge is an import statement. After building the graph, it runs a depth-first search (DFS) to detect cycles.

During DFS, each node is in one of three states:
- **Unvisited**: not yet processed
- **In progress**: currently being visited (in the current DFS path)
- **Done**: fully visited, no cycle found from this node

When the DFS traverses an edge to a node that is currently "in progress", a cycle has been found. The cycle path is the portion of the current DFS stack from the "in progress" node to the current node.

All files in any cycle are reported as violations. If a file participates in multiple cycles, it is reported once per cycle.

---

## How to fix circular dependencies

### Strategy 1: Extract the shared dependency

The most common cause of circular dependencies is two files that each need something from the other. The fix is to extract the shared piece into a third file that both can import:

**Before (cycle):**
```
order.dart     imports  cart.dart   (needs CartItem)
cart.dart      imports  order.dart  (needs OrderStatus)
```

**After (no cycle):**
```
types.dart     defines  CartItem, OrderStatus
order.dart     imports  types.dart
cart.dart      imports  types.dart
```

The key insight is to ask: "What does each file actually need from the other?" Usually it's a type definition, a constant, or a utility function — something that can live in a shared, dependency-free module.

### Strategy 2: Use dependency injection to break compile-time coupling

Sometimes a file needs to call methods on a class from another file, but the dependency should be injected rather than imported directly:

**Before (cycle):**
```dart
// auth_bloc.dart
import 'auth_service.dart';
class AuthBloc {
  final AuthService _service;
  // ...
}

// auth_service.dart
import 'auth_bloc.dart';
class AuthService {
  void notifyBloc(AuthBloc bloc) { /* ... */ }  // wrong: service knows about bloc
}
```

**After (no cycle):**
```dart
// auth_service.dart — no import of auth_bloc.dart
class AuthService {
  final void Function(AuthEvent) _notify;
  AuthService(this._notify);
  void someOperation() {
    _notify(AuthSuccessEvent());
  }
}

// auth_bloc.dart
import 'auth_service.dart';
class AuthBloc {
  late final AuthService _service = AuthService((event) => add(event));
}
```

The service no longer imports the bloc. The callback type is a Dart function type — no import needed.

### Strategy 3: Apply Dependency Inversion

Define an abstract interface in the file that needs to call the other. The caller depends on the abstract interface, not the concrete class. The concrete class implements the interface without the original file knowing about it:

**Before (cycle):**
```
notification_service.dart  imports  user_preferences.dart
user_preferences.dart      imports  notification_service.dart
```

**After (no cycle):**
```
notification_listener.dart  defines  abstract class NotificationListener
notification_service.dart   imports  notification_listener.dart only
user_preferences.dart       imports  notification_listener.dart and implements it
```

`notification_service.dart` knows only the abstract `NotificationListener`. `user_preferences.dart` knows the abstract listener interface. Neither knows the other directly.

### Strategy 4: Move the offending code

Sometimes a file imports another only for one small piece of code. If that piece logically belongs elsewhere, moving it eliminates the import:

```dart
// cart.dart imports order.dart only for the formatOrderId() function
// Solution: move formatOrderId() to a shared utilities file
// cart.dart and order.dart both import utilities.dart — no cycle
```

---

## Function signature

```dart
void noCircularDependencies({
  RuleSeverity severity = RuleSeverity.error,
  List<String> exceptions = const [],
})
```

## Parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `severity` | `RuleSeverity` | `RuleSeverity.error` | Violation severity. Defaults to `error` because circular dependencies are structural violations. |
| `exceptions` | `List<String>` | `const []` | File paths exempt from cycle detection. Useful for generated files or intentionally coupled legacy code. |

Note that `noCircularDependencies` takes no `folders` parameter. It analyzes the entire project. There is no safe subset of files that can be excluded from cycle detection: a cycle crossing the boundary of an excluded folder would be missed entirely.

---

## Examples

### Example 1 — Apply globally (recommended default)

The simplest and most complete configuration. Run on every CI build:

```dart title="test_arch/no_circular_dependencies_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() => noCircularDependencies(),
);
```

No parameters required. DartUnit walks the entire project's import graph, identifies all cycles, and reports every participating file.

### Example 2 — Excluding generated files

Code generators like `freezed`, `json_serializable`, and `build_runner` can produce import patterns that look like cycles due to `part`/`part of` declarations. These are not real import cycles — they are file splitting for a single logical compilation unit — but they may appear in the cycle detection output.

Exclude generated files by path suffix:

```dart title="test_arch/no_circular_dependencies_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() => noCircularDependencies(
    severity: RuleSeverity.error,
    exceptions: [
      // Freezed-generated files
      'cart_state.freezed.dart',
      'user_model.freezed.dart',
      // JSON serialization-generated files
      'cart_state.g.dart',
      'user_model.g.dart',
    ],
  ),
);
```

If you have many generated files, consider a naming convention that makes them easy to identify (all generated files end in `.g.dart` or `.freezed.dart`) and add them to exceptions as they are created.

### Example 3 — Using as a gate in CI

The most impactful configuration: run `noCircularDependencies` as part of the CI pipeline and block merges when a cycle is introduced.

```dart title="test_arch/ci_gate_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() => noCircularDependencies(
    severity: RuleSeverity.critical,  // CRITICAL: blocks CI unconditionally
  ),
);
```

In your CI configuration (GitHub Actions, GitLab CI, Bitrise, etc.):

```yaml title=".github/workflows/architecture.yml"
- name: Run architecture tests
  run: dart run dartunit analyze
```

When `noCircularDependencies` reports a `critical` violation, DartUnit exits with a non-zero code. The CI step fails. The pull request cannot be merged until the cycle is resolved.

This is the recommended configuration for teams that want to guarantee no new cycles are ever introduced. The cost is that every PR must pass the cycle check — the benefit is that cycles never accumulate silently.

---

## What the violation report shows

When a cycle is detected, DartUnit reports every file in the cycle, along with the full cycle path:

```
ERROR | Circular dependency detected
      | lib/bloc/auth_bloc.dart
      | Participates in cycle: auth_bloc.dart → auth_repository.dart → auth_service.dart → auth_bloc.dart

ERROR | Circular dependency detected
      | lib/repository/auth_repository.dart
      | Participates in cycle: auth_bloc.dart → auth_repository.dart → auth_service.dart → auth_bloc.dart

ERROR | Circular dependency detected
      | lib/service/auth_service.dart
      | Participates in cycle: auth_bloc.dart → auth_repository.dart → auth_service.dart → auth_bloc.dart
```

Each file in the cycle is reported as a separate violation, and each violation includes the full cycle path. This means:

- You see the complete cycle in each violation entry, so you don't need to aggregate violations to understand the structure.
- The file path on the second line identifies which specific file to navigate to first.
- The cycle path shows the exact import chain, which points to the specific imports that need to be changed.

For a cycle involving a barrel file:

```
ERROR | Circular dependency detected
      | lib/domain/index.dart
      | Participates in cycle: cart_repository.dart → index.dart → cart_repository.dart

      Note: index.dart exports 23 files. All 23 files participate in this cycle
      because they are re-exported by the barrel file in the chain.
```

---

## Incremental adoption: what to do with existing cycles

If you add DartUnit to an existing project, `noCircularDependencies` may report dozens of existing cycles. Do not try to fix them all at once.

**Step 1**: Run the preset with `RuleSeverity.warning` and add all currently-violating files to `exceptions`. This gives you a baseline: the current known cycles are documented in the exception list.

```dart title="test_arch/no_circular_dependencies_test_arch.dart"
import 'package:dartunit/dartunit.dart';

void main() => noCircularDependencies(
    severity: RuleSeverity.error,
    exceptions: [
      // Known existing cycles — fix these incrementally
      'lib/legacy/order_manager.dart',
      'lib/legacy/cart_manager.dart',
      'lib/legacy/product_manager.dart',
    ],
  ),
);
```

**Step 2**: The CI gate now blocks any *new* cycles from being introduced, while the existing ones are documented. New code is held to the higher standard.

**Step 3**: Gradually remove files from `exceptions` as you fix the underlying cycles. The exception list shrinks over time, tracking your architectural improvement progress.

---

## Common gotchas

### `part` and `part of` are not import cycles

Dart's `part`/`part of` mechanism splits one logical library across multiple physical files. A file with `part 'cart_state.g.dart'` and a file with `part of 'cart_state.dart'` are not a cycle — they are two halves of one file. DartUnit excludes `part` declarations from cycle detection.

### Transitive cycles are still cycles

A cycle does not require a direct import between the same two files. If `A → B → C → A`, all three files are in a cycle even though `A` does not directly import `C`. DartUnit detects cycles of any length.

### Package imports can create cross-package cycles

If your project uses path-based package imports to reference other packages in a monorepo, cycles can cross package boundaries. DartUnit follows path-based imports across package boundaries and detects cross-package cycles.

---

## Related presets

- [`layeredArchitecture`](/presets/layer/) — defines which layers can import which other layers. Layer violations often indicate conditions that lead to circular dependencies.
- [`layerCannotDependOn`](/presets/layer/) — targeted import prohibition; use as a preventive measure against known cycle-prone paths.
