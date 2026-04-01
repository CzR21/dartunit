String generateMissingArchTest(String projectRoot) =>
    'test_arch/ not found in $projectRoot — run  dartunit init  first.';

String generateCreatedFile(String fileName) => 'Created  test_arch/$fileName';

List<String> generateNextSteps(String fileName) => [
      'Open    test_arch/$fileName',
      'Add selectors and matchers inside the  testArch()  body.',
      'Run     dartunit analyze',
    ];

String ruleTemplate(String ruleName) => '''
import 'package:dartunit/dartunit.dart';
import 'package:test/test.dart';

/// ${_toDescription(ruleName)}
///
/// TODO: Describe what this rule enforces and why.
///
/// Run with:
///   dart test test_arch/${ruleName}_arch_test.dart
///   dartunit analyze
void main() => testArch('${_toDescription(ruleName)}', (arch) {
  final subject = arch.classes(
    folder: 'lib/', // TODO: restrict to the correct folder
  );
  expect(subject, hasMaxMethods(10)); // TODO: replace with actual matcher
});
''';

String _toDescription(String ruleName) {
  return ruleName
      .split(RegExp(r'[_\-\s]+'))
      .map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1))
      .join(' ');
}
