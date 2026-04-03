---
title: classSizeLimitPreset
description: Limit the number of methods and/or fields per class. Prevents God classes from accumulating too many responsibilities over time.
sidebar:
  order: 9
---

`classSizeLimitPreset` enforces an upper bound on the number of methods and/or fields a class may declare. It targets one of the most persistent and damaging architectural anti-patterns in any codebase: the God class.

## What is a God Class?

A God class is a class that has grown to know too much and do too much. It starts innocently — perhaps as a `UserService` that handles login and registration. Over months, it absorbs password reset logic, profile management, notification preferences, audit logging, and avatar uploads. Each addition seems small and justified in isolation. The result is a class with 40+ methods, hundreds of fields, thousands of lines, and no clear conceptual boundary.

God classes are characterized by:

- **Multiple, unrelated reasons to change.** When a class handles both authentication and profile updates, a change in either domain forces edits to the same file. The class violates the Single Responsibility Principle at a structural level.
- **Dependency magnetism.** Every module that needs anything from the class — even a single utility method — must import the entire class, pulling in all its transitive dependencies. In Flutter, this means importing database logic into widgets that only need a display name.
- **Untestable in isolation.** A class with 30 methods has an interaction surface that grows combinatorially. Testing that a password reset doesn't accidentally break notification preferences requires understanding every field the two methods share. Unit tests for God classes tend to be either superficial or enormous.
- **Merge conflict concentration.** When three developers are each working on features that touch the same God class, merge conflicts are inevitable and dangerous. Resolving them correctly requires understanding the entire class in detail.
- **Cognitive overload.** Human short-term memory handles roughly 7 ± 2 chunks simultaneously (Miller's Law). A class with 40 methods exceeds any single developer's ability to hold it in mind at once. Every bug fix requires re-reading the entire class to avoid introducing regressions.

## The Mathematics of Complexity

The number of potential interactions between methods in a class grows with the square of the number of methods. A class with 10 methods has at most 45 pairs that could interact. A class with 30 methods has 435 potential interaction pairs — nearly 10 times more complexity for 3 times more methods.

Consider what this means for debugging. When a bug is reported in a class with 10 methods, you read 10 methods to find the source. When a bug appears in a class with 30 methods, you must consider 30 methods and their 435 pairwise interactions. The cognitive cost is not linear — it is quadratic.

This is why "just add one more method" is never truly free. Every addition multiplies the complexity of the entire class.

## Flutter-Specific Context

Flutter projects develop characteristic God class patterns that are worth understanding explicitly.

**God Widgets.** A `StatefulWidget` that manages its own network calls, business logic, local state, navigation, and rendering is doing far too much. Each `setState()` call triggers a rebuild of the entire subtree. A widget with 20 fields and 15 methods will rebuild dozens of children unnecessarily on every state change. Beyond performance, the widget becomes impossible to test — you cannot test the data-fetching logic in isolation because it is entangled with the widget lifecycle.

**God BLoC classes.** A BLoC that handles 25 different events becomes a state machine too complex to reason about. The `on<Event>` handlers share fields on the state object, and changing how one event transitions state can silently break another event's expected behavior. BLoC classes should ideally handle one domain of events (authentication events, shopping cart events) — not everything a screen might need.

**God repositories.** A `DataRepository` that wraps both local SQLite operations and remote REST calls for an entire domain aggregates different data access patterns. Local reads are synchronous and cheap; remote calls are asynchronous and fallible. Mixing them makes it impossible to stub either in tests without bringing in the other.

**God service classes.** In apps using get_it or injectable for DI, services frequently absorb new methods rather than spawning new classes, because creating a new class requires registration boilerplate. The result is a `AppService` or `UtilsService` that becomes a miscellaneous drawer.

## Recommended Limits

Several heuristics from software engineering literature give guidance on practical upper bounds:

- **The 7 ± 2 rule (Miller's Law):** A developer can hold roughly 7 chunks in working memory. A class with more than 7–9 methods starts to exceed comprehensibility in a single reading.
- **The SOLID guideline:** A class following the Single Responsibility Principle rarely needs more than 5–7 public methods. More than that is a sign that multiple responsibilities have merged.
- **The Clean Code recommendation:** Robert Martin suggests that a class should be small enough to have a single, concise description without the words "and" or "or." In practice, such classes rarely exceed 10–12 methods.
- **The pragmatic Flutter guideline:** Widgets should have 1–3 public methods (typically just `build()` and lifecycle overrides). BLoC classes benefit from a limit of 8–10 event handlers. Repositories can be slightly larger but should stay under 15 methods.

A sensible starting point for a brownfield project is 20–25 methods. This will flag only the most egregious God classes. Once those are refactored, lower the limit progressively.

## Function Signature

```dart
ArchitectureRule classSizeLimitPreset({
  int? maxMethods,
  int? maxFields,
  List<String> folders = const [],
  Severity severity = Severity.error,
  List<String> exceptions = const [],
})
```

## Parameters

### `maxMethods`

**Type:** `int?` — optional, but at least one of `maxMethods` or `maxFields` must be provided.

The maximum number of methods (instance methods, static methods, getters, setters, and operators) a class may declare. Any class that declares strictly more than this number will produce a violation.

When counting methods, DartUnit counts all declared members that are callable: instance methods, static methods, `get` and `set` accessors, and operator overloads. Constructors are not counted as methods. Abstract method declarations in abstract classes are counted.

```dart
// maxMethods: 3 — this class has 4 methods (login, logout, register, refreshToken)
// VIOLATION
class AuthService {
  Future<User> login(String email, String password) async { ... }
  Future<void> logout() async { ... }
  Future<User> register(String email, String password) async { ... }
  Future<String> refreshToken(String token) async { ... }
}
```

### `maxFields`

**Type:** `int?` — optional, but at least one of `maxMethods` or `maxFields` must be provided.

The maximum number of instance fields (non-static, non-final constant fields) a class may declare. Classes that carry too many fields are often managing too much state — a signal that the class should be split.

Counted: instance fields declared with `var`, `final` (instance-level), `late`, and typed declarations.
Not counted: `static` fields, `const` fields, enum values.

```dart
// maxFields: 3 — this class has 5 fields
// VIOLATION
class CheckoutState {
  List<Item> items;
  double subtotal;
  double taxAmount;
  double shippingCost;
  PromoCode? appliedPromo;
}
```

### `folders`

**Type:** `List<String>` — default `[]`

A list of folder paths (relative to the project root) that the rule applies to. When empty, the rule applies to every Dart file in the project.

When specified, only classes found within the given folders (and their subdirectories) are checked. Multiple calls to `classSizeLimitPreset` with different `folders` and different limits allow different thresholds for different layers.

```dart
// Only applies to files under lib/blocs/
classSizeLimitPreset(maxMethods: 8, folders: ['lib/blocs'])
```

### `severity`

**Type:** `Severity` — default `Severity.error`

Controls how violations are reported:

- `Severity.error` — the `dart run dartunit analyze` command exits with a non-zero code. Suitable for CI gates.
- `Severity.warning` — violations are reported but the command exits with code 0. Useful during incremental adoption when you want visibility without blocking builds.
- `Severity.info` — violations are reported at informational level. Use this for metrics gathering.

### `exceptions`

**Type:** `List<String>` — default `[]`

A list of class names to exclude from the rule. Useful for known legacy classes that cannot be immediately refactored, or for framework base classes that are intentionally large.

```dart
classSizeLimitPreset(
  maxMethods: 15,
  exceptions: ['LegacyUserService', 'GeneratedRouterBase'],
)
```

## Usage

### Setting Up the Rule File

Create a file in the `arch_test/` directory. Each rule file has the following structure:

```dart
// arch_test/class_size.dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(args, classSizeLimitPreset(
  maxMethods: 15,
));
```

Run with:

```
dart run dartunit analyze
```

## Examples

### Example 1: Global Method Limit

The simplest form: no class in the entire project may exceed 15 methods. This is a good starting point for a project that has never enforced class size limits. It will surface the worst offenders without being overly strict.

```dart
// arch_test/global_class_size.dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(
  args,
  classSizeLimitPreset(
    maxMethods: 15,
    severity: Severity.warning, // Start as warning during adoption
  ),
);
```

When run, DartUnit scans every `.dart` file under `lib/` and reports any class with more than 15 declared methods:

```
VIOLATION [warning] classSizeLimitPreset
  File: lib/services/user_service.dart
  Class: UserService
  Methods declared: 23 (max allowed: 15)
  Exceeded by: 8 methods

VIOLATION [warning] classSizeLimitPreset
  File: lib/features/checkout/checkout_bloc.dart
  Class: CheckoutBloc
  Methods declared: 19 (max allowed: 15)
  Exceeded by: 4 methods
```

### Example 2: BLoC Size Limit

BLoC classes that accumulate too many event handlers are a common Flutter problem. Each `on<Event>` handler is a method, and a BLoC with 20+ handlers is handling too many domain events. Limiting BLoC classes to 10 methods (roughly 7–8 handlers plus a few helpers) forces appropriate domain decomposition.

```dart
// arch_test/bloc_size.dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(
  args,
  classSizeLimitPreset(
    maxMethods: 10,
    folders: ['lib/blocs', 'lib/cubits', 'lib/features'],
    severity: Severity.error,
  ),
);
```

A BLoC that exceeds this limit likely conflates multiple domains. For example, a `UserBloc` that handles both authentication events (`LoginEvent`, `LogoutEvent`, `RegisterEvent`) and profile events (`UpdateNameEvent`, `ChangeAvatarEvent`, `UpdatePreferencesEvent`) should be split into `AuthBloc` and `ProfileBloc`.

### Example 3: Widget Field Limit

Widgets with many fields are carrying state they shouldn't. A `StatefulWidget` with 10+ fields in its `State` class is managing too much local state — some of it should be lifted to a BLoC or ChangeNotifier, and some of the widget should be extracted into sub-widgets.

```dart
// arch_test/widget_size.dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(
  args,
  classSizeLimitPreset(
    maxFields: 7,
    folders: ['lib/ui', 'lib/widgets', 'lib/screens', 'lib/pages'],
    severity: Severity.error,
    exceptions: ['AnimationControllerMixin'], // Known legitimate use
  ),
);
```

This catches widgets like:

```dart
// VIOLATION: 9 fields
class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool isLoading = false;
  bool isFavorited = false;
  bool isInCart = false;
  int quantity = 1;
  String? selectedColor;
  String? selectedSize;
  ScrollController scrollController = ScrollController();
  TabController? tabController;
  GlobalKey<FormState> reviewFormKey = GlobalKey();
}
```

The violation message tells you exactly what to fix:

```
VIOLATION [error] classSizeLimitPreset
  File: lib/screens/product_detail_screen.dart
  Class: _ProductDetailScreenState
  Fields declared: 9 (max allowed: 7)
  Exceeded by: 2 fields
```

### Example 4: Repository Size Limit

Repositories that handle both remote API calls and local cache management tend to grow large. A limit on repository classes encourages splitting into a remote data source, a local data source, and a thin repository that coordinates them.

```dart
// arch_test/repository_size.dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(
  args,
  classSizeLimitPreset(
    maxMethods: 12,
    maxFields: 5,
    folders: ['lib/data/repositories'],
    severity: Severity.error,
  ),
);
```

Applying both `maxMethods` and `maxFields` simultaneously means a class violates if it exceeds either limit. This catches repositories that have a moderate number of methods but carry excessive internal state (caches, retry counters, flag fields).

### Example 5: Different Limits for Different Folders

Different architectural layers have different natural sizes. Domain entities are tiny; framework integration classes may legitimately be larger. Use multiple rule files to apply layer-appropriate limits:

```dart
// arch_test/domain_size.dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(
  args,
  classSizeLimitPreset(
    maxMethods: 8,
    maxFields: 4,
    folders: ['lib/domain'],
    severity: Severity.error,
  ),
);
```

```dart
// arch_test/application_size.dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(
  args,
  classSizeLimitPreset(
    maxMethods: 15,
    maxFields: 8,
    folders: ['lib/application', 'lib/blocs'],
    severity: Severity.error,
  ),
);
```

```dart
// arch_test/infrastructure_size.dart
import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(
  args,
  classSizeLimitPreset(
    maxMethods: 20,
    folders: ['lib/infrastructure', 'lib/data'],
    severity: Severity.warning, // Infrastructure can be larger
  ),
);
```

This layered approach acknowledges reality: infrastructure code (database mappers, HTTP clients, generated code wrappers) is inherently more verbose than domain logic.

### Example 6: Incremental Adoption with Exceptions

When introducing this preset to a large existing project, start permissively and tighten over time. Begin by excepting known large legacy classes while still flagging new violations:

```dart
// arch_test/class_size_phase1.dart
import 'package:dartunit/dartunit.dart';

// Phase 1: Flag the worst offenders only (>25 methods)
// Add known legacy classes to exceptions while they are being refactored
void main(List<String> args) => archTest(
  args,
  classSizeLimitPreset(
    maxMethods: 25,
    severity: Severity.warning,
    exceptions: [
      'LegacyUserService',    // Tracked in issue #142 — refactor Q1
      'OldCheckoutManager',   // Tracked in issue #156 — refactor Q2
      'AppRouter',            // Generated code, excluded permanently
    ],
  ),
);
```

After the refactors in the exceptions list are complete, lower the limit and reduce or remove exceptions:

```dart
// arch_test/class_size_phase2.dart
import 'package:dartunit/dartunit.dart';

// Phase 2: Tighter limit, exceptions removed as classes are refactored
void main(List<String> args) => archTest(
  args,
  classSizeLimitPreset(
    maxMethods: 15,
    severity: Severity.error, // Now blocking in CI
    exceptions: [
      'AppRouter', // Permanently excluded — generated code
    ],
  ),
);
```

## Violation Message Format

When a class exceeds the configured limit, DartUnit reports:

```
VIOLATION [error] classSizeLimitPreset
  File: lib/features/auth/auth_bloc.dart
  Class: AuthBloc
  Methods declared: 18 (max allowed: 10)
  Exceeded by: 8 methods
```

For a fields violation:

```
VIOLATION [error] classSizeLimitPreset
  File: lib/ui/screens/home_screen.dart
  Class: _HomeScreenState
  Fields declared: 11 (max allowed: 7)
  Exceeded by: 4 fields
```

When both `maxMethods` and `maxFields` are configured and both are exceeded, DartUnit emits separate violation entries for each:

```
VIOLATION [error] classSizeLimitPreset
  File: lib/services/legacy_service.dart
  Class: LegacyService
  Methods declared: 28 (max allowed: 15)
  Exceeded by: 13 methods

VIOLATION [error] classSizeLimitPreset
  File: lib/services/legacy_service.dart
  Class: LegacyService
  Fields declared: 12 (max allowed: 8)
  Exceeded by: 4 fields
```

## Incremental Adoption Strategy

Introducing `classSizeLimitPreset` to an existing codebase should be done in phases to avoid blocking the team while still making architectural progress:

**Phase 1 — Visibility (week 1–2):** Set `severity: Severity.warning` with a generous limit (e.g., `maxMethods: 30`). Do not block CI. Let the team see what's flagged. Discuss the worst offenders in architecture reviews.

**Phase 2 — Commitment (week 3–4):** Change to `severity: Severity.error` but add the largest offenders to `exceptions` with GitHub issue links in comments. Now CI blocks on new violations but not on pre-existing ones. New God classes cannot be introduced.

**Phase 3 — Reduction (ongoing):** As exceptions are refactored and removed, lower the limit in increments of 5. Move from 30 to 25, then to 20, then to 15. Each reduction is a milestone that reflects real architectural improvement.

**Phase 4 — Stabilization:** Set the final limit appropriate to your team's standards (typically 10–15 methods) with `severity: Severity.error`. The exceptions list should be empty or contain only permanently excluded classes (generated code, framework base classes).

This approach prevents the common failure mode where a strict rule is introduced, causes immediate CI failures across the board, is then either reverted or riddled with exceptions from day one, and is never enforced meaningfully.

## Pairing With Other Presets

`classSizeLimitPreset` is most effective when used alongside:

- **`layerDependencyPreset`** — ensures that classes extracted from a God class don't end up in the wrong layer
- **`namingConventionPreset`** — when splitting a `UserService` into `AuthService`, `ProfileService`, and `NotificationService`, naming conventions ensure the new classes follow the project's established patterns
- **`noPublicFieldsPreset`** — God classes often expose internal state as public fields; after splitting, this rule ensures the new smaller classes maintain proper encapsulation

## Related Presets

- [`noPublicFieldsPreset`](/presets/no-public-fields) — Enforce encapsulation after reducing class size
- [`layerDependencyPreset`](/presets/layer) — Ensure extracted classes land in the correct layer
- [`namingConventionPreset`](/presets/naming) — Consistent naming for newly created classes
