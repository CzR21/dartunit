const String initAlreadyExists = 'Dartunit is already initialised in this project.\n'
    '  Run  dartunit analyze  to check your architecture.';

const String initSuccess = 'Project initialised successfully!';

const List<String> initNextSteps = [
  'Open    test_arch/example_test_arch.dart  and customise the rule.',
  'Run     dartunit analyze              to check your architecture.',
  'Run     dartunit generate <name>      to scaffold a new rule.',
];

List<String> initTemplateNextSteps(String templateLabel, int ruleCount) => [
  'Review the $ruleCount $templateLabel rule(s) created in test_arch/.',
  'Adjust folder paths in each rule to match your project structure.',
  'Run     dartunit analyze              to check your architecture.',
  'Run     dartunit generate <name>      to scaffold additional rules.',
];

const String exampleRule = '''
// test_arch/example_test_arch.dart
//
// Architecture rule: UI layer must not access data layer directly.
//
// Run with:
//   dart test test_arch/example_test_arch.dart
//   dartunit analyze

import 'package:dartunit/dartunit.dart';
import 'package:test/test.dart';

void main() => testArch('UI layer must not access the data layer directly',
    (arch) {
  final ui = arch.classes(folder: 'lib/ui');
  expect(ui, doesNotDependOn('lib/data'));
});
''';
