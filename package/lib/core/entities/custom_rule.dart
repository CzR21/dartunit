import 'rule.dart';

/// Interface that all custom rules must implement.
///
/// Custom rules live in `.dartunit/custom_rules/` and are loaded by the engine.
/// Because Dart does not support dynamic class loading without `dart:mirrors`
/// or native isolate compilation, custom rules are loaded via a generated
/// registry file (`custom_rules_registry.dart`) that the `generate` command
/// maintains automatically.
///
/// Example implementation:
/// ```dart
/// class NoRepositoryInUIRule implements CustomArchitectureRule {
///   @override
///   String get id => 'CUSTOM_NO_REPO_IN_UI';
///
///   @override
///   String get description => 'UI must not access repositories directly';
///
///   @override
///   ArchitectureRule build() {
///     return ArchitectureRule(
///       id: id,
///       description: description,
///       severity: RuleSeverity.error,
///       selector: ClassSelector(folder: 'lib/ui'),
///       predicate: NotPredicate(DependOnFolderPredicate('lib/data')),
///     );
///   }
/// }
/// ```
abstract class CustomRule {
  String get id;
  String get description;
  Rule build();
}