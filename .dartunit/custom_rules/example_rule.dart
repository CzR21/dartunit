// example_rule.dart
//
// This file demonstrates how to implement a custom architecture rule.
// Custom rules give you full Dart flexibility beyond what YAML allows.
//
// To create a new rule, run:
//   dartunit generate <rule_name>
//
// Then implement the CustomArchitectureRule interface below.

import 'package:dartunit/dartunit.dart';

/// Example: Ensures that no class in lib/ui imports from lib/data directly.
///
/// This enforces a separation layer between the UI and data layers so that
/// all data access goes through the domain layer.
class ExampleNoDirectDataAccessRule implements CustomArchitectureRule {
  @override
  String get id => 'EXAMPLE_NO_DIRECT_DATA_ACCESS';

  @override
  String get description =>
      'UI layer must not access the data layer directly';

  @override
  ArchitectureRule build() {
    // TODO: Customise selector and predicate for your project.
    return ArchitectureRule(
      id: id,
      description: description,
      severity: RuleSeverity.error,
      selector: ClassSelector(folder: 'lib/ui'),
      predicate: NotPredicate(
        DependOnFolderPredicate('lib/data'),
      ),
    );
  }
}
