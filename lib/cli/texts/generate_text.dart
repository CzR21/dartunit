String generateMissingArchTest(String projectRoot) =>
    'arch_test/ not found in $projectRoot — run  dartunit init  first.';

String generateCreatedFile(String fileName) => 'Created  arch_test/$fileName';

List<String> generateNextSteps(String fileName) => [
      'Open    arch_test/$fileName',
      'Implement the rule inside the  archTest()  call.',
      'Run     dartunit analyze',
    ];

String ruleTemplate(String ruleName) => '''
import 'package:dartunit/dartunit.dart';

/// ${_toDescription(ruleName)}
///
/// TODO: Describe what this rule enforces and why.
void main(List<String> args) => archTest(
      args,
      ArchitectureRule(
        description: '${_toDescription(ruleName)}',
        severity: RuleSeverity.error, // TODO: choose appropriate severity
        selector: ClassSelector(
          folder: 'lib/', // TODO: restrict to the correct folder
        ),
        predicate: MaxMethodsPredicate(10), // TODO: replace with actual predicate
        // exceptions: ['lib/legacy/', 'lib/generated/'], // optional: paths to ignore
      ),
    );
''';

String _toDescription(String ruleName) {
  return ruleName
      .split(RegExp(r'[_\-\s]+'))
      .map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1))
      .join(' ');
}
