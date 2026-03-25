const String initAlreadyExists = 'Dartunit is already initialised in this project.\n'
    '  Run  dartunit analyze  to check your architecture.';

const String initSuccess = 'Project initialised successfully!';

const List<String> initNextSteps = [
  'Open    arch_test/example_arch_test.dart  and customise the rule.',
  'Run     dartunit analyze              to check your architecture.',
  'Run     dartunit generate <name>      to scaffold a new rule.',
];

List<String> initTemplateNextSteps(String templateLabel, int ruleCount) => [
  'Review the $ruleCount $templateLabel rule(s) created in arch_test/.',
  'Adjust folder paths in each rule to match your project structure.',
  'Run     dartunit analyze              to check your architecture.',
  'Run     dartunit generate <name>      to scaffold additional rules.',
];

const String exampleRule = r'''
// arch_test/example_arch_test.dart
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
''';
