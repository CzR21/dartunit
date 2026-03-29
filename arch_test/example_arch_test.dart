// arch_test/example_rule.dart
//
// Architecture rule: UI layer must not access data layer directly.
//
// Run with:
//   flutter test arch_test/example_rule.dart
//   dart test arch_test/example_rule.dart
//   dartunit analyze

import 'package:dartunit/dartunit.dart';

void main() => testArch(
      ArchitectureRule(
        description: 'UI layer must not access the data layer directly',
        severity: RuleSeverity.error,
        selector: ClassSelector(folder: 'lib/ui'),
        predicate: NotPredicate(DependOnFolderPredicate('lib/data')),
      ),
    );
