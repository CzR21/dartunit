// arch_test/example_rule.dart
//
// Architecture rule: UI layer must not access data layer directly.
// Run "dartunit analyze" to analyze this rule against your project.
// Run "dartunit generate <name>" to scaffold additional rules.

import 'package:dartunit/dartunit.dart';

void main(List<String> args) => archTest(
      args,
      ArchitectureRule(
        description: 'UI layer must not access the data layer directly',
        severity: RuleSeverity.error,
        selector: ClassSelector(folder: 'lib/ui'),
        predicate: NotPredicate(DependOnFolderPredicate('lib/data')),
      ),
    );
